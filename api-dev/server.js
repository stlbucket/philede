// require('./.env')
const {ApolloEngine} = require('apollo-engine');
const express = require("express");
const {postgraphile} = require("postgraphile");
// var proxy = require('http-proxy-middleware');


const plugins = [
  require('./src/graphile-extensions/execSql'),
  require('postgraphile-plugin-connection-filter')
]

const port = process.env.PORT
const connection = process.env.POSTRGRES_CONNECTION
const schemas = process.env.POSTGRAPHILE_SCHEMAS.split(',')
const dynamicJson = process.env.DYNAMIC_JSON === 'true'
// const pgDefaultRole = process.env.DEFAULT_ROLE
// const jwtSecret = process.env.JWT_SECRET
// const jwtPgTypeIdentifier = process.env.JWT_PG_TYPE_IDENTIFIER
const extendedErrors = process.env.EXTENDED_ERRORS
const disableDefaultMutations = process.env.DISABLE_DEFAULT_MUTATIONS === 'false'
const enableApolloEngine = process.env.ENABLE_APOLLO_ENGINE === 'true'
const apolloApiKey = process.env.APOLLO_ENGINE_API_KEY

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
    ,watchPg: true
    // ,classicIds: true
  }
));

if (enableApolloEngine) {
  engine.listen({
    port: port,
    expressApp: app
  });
} else {
  app.listen(port)
}

console.log(`listening on ${port}`)
console.log('this dev server will be controlled by the main pde api server via pm2')
console.log('when a new schema is added, the server has to restart')
console.log('other changes are picked up by postgraphile watcher')