const clog = require('fbkt-clog')
const proxy = require('http-proxy-middleware');
const pm2 = require('pm2')
let loaded = false
let _pde = null

function PostgraphileDE(builder, options) {
  // clog('OPTIONS', options)

  options.app.use('/dev-graphql', proxy({
    target: 'http://localhost:5001',
    changeOrigin: true,
    logLevel: 'debug',
    pathRewrite: {'/dev-graphql' : '/graphql'}
  }));      
  
  options.app.use('/dev', proxy({
    target: 'http://localhost:5001',
    changeOrigin: true,
    logLevel: 'debug'
  }));      
  
  if (loaded === false) {
    pm2.start(`${__dirname}/pde/pde-api.js`, {
      name: 'pde-server',
      env: {
        POSTGRAPHILE_SCHEMAS: "pde",
        POSTGRES_CONNECTION: process.env.POSTGRES_CONNECTION,
        // DEFAULT_ROLE: "app_anonymous",
        // JWT_SECRET: "SUPERSECRET",
        // JWT_PG_TYPE_IDENTIFIER: "auth.jwt_token",
        EXTENDED_ERRORS: "hint, detail, errcode",
        DISABLE_DEFAULT_MUTATIONS: "true",
        DYNAMIC_JSON: "true",
        ENABLE_APOLLO_ENGINE: "false",
        PORT: 5001
      }
    }, function(error, result){
  
      _pde = result;
    })
    loaded = true
  }
}

module.exports = PostgraphileDE