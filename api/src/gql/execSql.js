process.env.GRAPHQL_API_ENDPOINT = 'http://localhost:5001/graphql'
const client = require('../apolloClient')
const gql = require('graphql-tag')

const mutation = gql`
mutation ExecSql(
  $sql: String!
){
  ExecSql(input: {
    sql: $sql
  }) {
    result
  }
}
`;

function execSql(sql){
  return client.connect()
  .then(client => {
    return client.mutate({
      mutation: mutation,
      variables: {
        sql: sql
      }
    })
  })
  .then(result => {
    // console.log('result', JSON.stringify(result,null,2))
    return result.data.ExecSql.result
  })
  .catch(error => {
    console.log('execSql error', error)
    throw error
  })

}

module.exports = execSql
