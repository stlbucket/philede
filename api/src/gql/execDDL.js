process.env.GRAPHQL_API_ENDPOINT = 'http://localhost:5001/graphql'
const client = require('../apolloClient')
const gql = require('graphql-tag')
const clog = require('fbkt-clog')

const mutation = gql`
mutation ExecDDL(
  $sql: String!
){
  ExecDDL(input: {
    sql: $sql
  }) {
    result
  }
}
`;

function ExecDDL(sql){
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
    return result.data.ExecDDL.result
  })
  .catch(error => {
    clog('ExecDDL error', error.toString().replace('Error: GraphQL error: ', ''))
    throw new Error(error.toString().replace('Error: GraphQL error: ', ''))
  })

}

module.exports = ExecDDL
