require('./.env')
const {ApolloEngine} = require('apollo-engine');
const express = require("express");
const {postgraphile} = require("postgraphile");
const proxy = require('http-proxy-middleware');
const pm2 = require('pm2')


const plugins = [
  require('./src/graphile-extensions/pm2Status'),
  require('postgraphile-plugin-connection-filter'),
  require('./src/graphile-extensions/devDeploy')
]

const port = process.env.PORT
const connection = process.env.POSTGRES_CONNECTION
const schemas = process.env.POSTGRAPHILE_SCHEMAS.split(',')
const dynamicJson = process.env.DYNAMIC_JSON === 'true'
// const pgDefaultRole = process.env.DEFAULT_ROLE
// const jwtSecret = process.env.JWT_SECRET
// const jwtPgTypeIdentifier = process.env.JWT_PG_TYPE_IDENTIFIER
const extendedErrors = process.env.EXTENDED_ERRORS
const disableDefaultMutations = process.env.DISABLE_DEFAULT_MUTATIONS === 'false'
const enableApolloEngine = process.env.ENABLE_APOLLO_ENGINE === 'true'
const apolloApiKey = process.env.APOLLO_ENGINE_API_KEY
const watchPg = process.env.WATCH_PG === 'true'

const app = express();
const engine = new ApolloEngine({
  apiKey: apolloApiKey
});

app.use(postgraphile(
  connection
  ,schemas
  ,{
    dynamicJson: dynamicJson
    // ,pgDefaultRole: pgDefaultRole
    // ,jwtSecret: jwtSecret
    // ,jwtPgTypeIdentifier: jwtPgTypeIdentifier
    ,showErrorStack: true
    ,extendedErrors: ['severity', 'code', 'detail', 'hint', 'positon', 'internalPosition', 'internalQuery', 'where', 'schema', 'table', 'column', 'dataType', 'constraint', 'file', 'line', 'routine']
    ,disableDefaultMutations: disableDefaultMutations
    ,appendPlugins: plugins
    ,watchPg: watchPg
    // ,classicIds: true
  }
));

// pm2.start(`../api-dev/server.js`, {
//   name: 'pde-under-development',
//   cwd: '../api-dev',
//   env: {
//     APOLLO_ENGINE_API_KEY: "service:stlbucket-4863:E1JvHPJjVn04vWxTF9w2PQ",
//     POSTGRAPHILE_SCHEMAS: "cards",
//     POSTGRES_CONNECTION: "postgres://postgres:1234@0.0.0.0/dev_phile",
//     DEFAULT_ROLE: "app_anonymous",
//     JWT_SECRET: "SUPERSECRET",
//     JWT_PG_TYPE_IDENTIFIER: "auth.jwt_token",
//     EXTENDED_ERRORS: "hint, detail, errcode",
//     DISABLE_DEFAULT_MUTATIONS: "true",
//     DYNAMIC_JSON: "true",
//     ENABLE_APOLLO_ENGINE: "false",
//     PORT: 5001
//   }
// }, function(error, result){

//   if (error) {
//     throw error
//   } else {
//     app.use('/dev-graphql', proxy({
//       target: 'http://localhost:5001',
//       changeOrigin: true,
//       logLevel: 'debug',
//       pathRewrite: {'/dev-graphql' : '/graphql'}
//     }));      
//   }
// })


if (enableApolloEngine) {
  engine.listen({
    port: port,
    expressApp: app
  });
} else {
  app.listen(port)
}

console.log(`listening on ${port}`)