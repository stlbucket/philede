const clog = require('fbkt-clog')
const { makeExtendSchemaPlugin, gql } = require("graphile-utils");
const rollbackDevDeployment = require('./rollbackDevDeployment')
const executeDevDeployment = require('./executeDevDeployment')


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

          clog('LET US DEV DEPLOY')

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
