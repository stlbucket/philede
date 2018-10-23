const Promise = require('bluebird')
const clog = require('fbkt-clog')
const { makeExtendSchemaPlugin, gql } = require("graphile-utils");
const camelCase = require('camelcase')
const execDDL = require('../gql/execDDL')

async function rollbackDevDeployment(args, pgClient) {
  const sql = `
    select * 
    from pde.dev_deployment 
    where id in (
      select dev_deployment_id 
      from pde.patch 
      where project_id = (
        select project_id from pde.release where id = ${args.input.releaseId}
      )
    )
    order by id desc
    ;`
  const devDeployments = await pgClient.query(sql, []);
  // clog('minors', minors)            

  for (let i = 0; i < devDeployments.rows.length; i++) {
    try {
      const devDeployment = devDeployments.rows[i]
      console.log('devDeployment', devDeployment)
      const devDeploymentResult = await execDDL(devDeployment.ddl_down)
      clog('devDeploymentResult', devDeploymentResult)

      const deleteSql = `
      delete from pde.dev_deployment where id = ${devDeployment.id};
      `
      clog('deleteSql', deleteSql)
      const deleteResult = await pgClient.query(deleteSql, []);
      clog('deleteResult', deleteResult)
    }
    catch (e) {
      throw e
    }
  }

  return {
    result: 'Deployment Rolled Back'
  }
}

async function executeDevDeployment(args, pgClient) {
  const release = (await pgClient.query(`select * from pde.release where id = ${args.input.releaseId} order by number asc;`, [])).rows[0]
  const inflectedRelease = Object.keys(release).reduce(
    (acc, key) => {
      return Object.assign(acc, {
        [camelCase(key)]: release[key]
      })
    }, {}
  )

  const sql = `select * from pde.minor where release_id = ${args.input.releaseId} order by revision asc;`
  const minors = await pgClient.query(sql, []);
  // clog('minors', minors)            

  for (let i = 0; i < minors.rows.length; i++) {
    const patches = await pgClient.query(`select * from pde.patch where minor_id = ${minors.rows[i].id} order by revision asc`, []);
    // clog('patches', patches)
    // loop thru patches
    for (let j = 0; j < patches.rows.length; j++) {
      const patch = patches.rows[j]
      try {
        clog('patch', patch)
        const patchResult = await execDDL(patch.ddl_up)
        clog('patchResult', patchResult)
        const devDeploymentSql = `
          WITH new_patch AS(
            insert into pde.dev_deployment(ddl_down, status)
            select '${patch.ddl_down}', 'DEPLOYED'
            RETURNING *
          )
          UPDATE pde.patch p
          SET dev_deployment_id = np.id
          FROM new_patch np
          WHERE p.id = ${patch.id}
        `
        const ddlSqlResult = await pgClient.query(devDeploymentSql, []);
        clog('ddlSqlResult', ddlSqlResult)
      }
      catch (e) {
        clog('DDL ERROR', e)
        const devDeploymentSql = `
          WITH new_patch AS(
            insert into pde.dev_deployment(ddl_down, status)
            select '', 'ERROR'
            RETURNING *
          )
          UPDATE pde.patch p
          SET dev_deployment_id = np.id
          FROM new_patch np
          WHERE p.id = ${patch.id}
        `
        await pgClient.query(devDeploymentSql, []);
        throw e
      }
    }
  }

  return {
    release: inflectedRelease
  }
}

const DevDeployPlugin = makeExtendSchemaPlugin(build => {
  const { pgSql: sql } = build;
  return {
    typeDefs: gql`
    input DevDeployInput {
      clientMutationId: String
      releaseId: BigInt!
    }

    type DevDeployPayload {
      release: Release
    }

    extend type Mutation {
      DevDeploy(input: DevDeployInput!): DevDeployPayload
    }
  `,
  resolvers: {
      Mutation: {
        DevDeploy: async (
          _mutation,
          args,
          context,
          resolveInfo,
          { selectGraphQLResultFromTable }
        ) => {
          const { pgClient } = context;

          try {
            const rollbackResult = await rollbackDevDeployment(args, pgClient)
            clog('rollbackResult', rollbackResult)

            return executeDevDeployment(args, pgClient)
          } catch (e) {
            // Oh noes! If at first you don't succeed,
            // destroy all evidence you ever tried.
            console.log('MAJOR ERROR', e)
            throw e;
          }
        },
      },
    },
  };
});

module.exports = DevDeployPlugin
