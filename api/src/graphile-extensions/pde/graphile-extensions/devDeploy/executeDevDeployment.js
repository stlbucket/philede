const clog = require('fbkt-clog')
const execDDL = require('./execDDL')
const camelCase = require('camelcase')

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
        await pgClient.query("SAVEPOINT ddl");
        const patchResult = await execDDL(patch.ddl_up, pgClient)
        await pgClient.query("RELEASE SAVEPOINT ddl");
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
        clog('deploy ERROR', e)
        try{
          await pgClient.query("ROLLBACK TO SAVEPOINT ddl");
          const blah = `
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
          clog('blah', blah)
            const ddlSqlResult = await pgClient.query(blah, []);
          clog('ddlSqlResult', ddlSqlResult)
        } catch (e) {
          clog('wtf', e)
        }

        throw e
      }
    }
  }

  return {
    release: inflectedRelease
  }
}

module.exports = executeDevDeployment