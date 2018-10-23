const express = require("express");
const path = require("path")
const {postgraphile} = require("postgraphile");

const plugins = [
  require('postgraphile-plugin-connection-filter'),
  require(`${__dirname}/graphile-extensions/devDeploy`),
  require(`${__dirname}/graphile-extensions/execSql`)
]

const port = process.env.PORT || 5001
const connection = process.env.POSTGRES_CONNECTION
const schemas = [ 'pde' ]
const disableDefaultMutations = false
const watchPg = false //process.env.WATCH_PG === 'true'

const app = express();

app.use(express.static(path.join(`${__dirname}`, `dist`)))

app.get('/', (req, res) => {
  console.log('wtf')
  res.redirect(`/dist/index.html`)
  // res.redirect(`${__dirname}/dist/index.html`)
})

app.use(postgraphile(
  connection
  ,schemas
  ,{
    dynamicJson: true
    ,showErrorStack: true
    ,extendedErrors: ['severity', 'code', 'detail', 'hint', 'positon', 'internalPosition', 'internalQuery', 'where', 'schema', 'table', 'column', 'dataType', 'constraint', 'file', 'line', 'routine']
    ,disableDefaultMutations: disableDefaultMutations
    ,appendPlugins: plugins
    ,watchPg: watchPg
  }
));

app.listen(port)

console.log(`listening on ${port}`)