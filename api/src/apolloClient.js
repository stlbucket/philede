const clog = require('fbkt-clog')
const Promise = require('bluebird')
const ApolloClient = require('apollo-client').ApolloClient;
const HttpLink = require('apollo-link-http').HttpLink;
const InMemoryCache = require('apollo-cache-inmemory').InMemoryCache;
const fetch = require('node-fetch')
const gql = require('graphql-tag')

let _client;
let _clientInitializer;

const _graphqlEndpoint = process.env.GRAPHQL_API_ENDPOINT
const _auth = process.env.GRAPHQL_AUTH;
const _username = process.env.GRAPHQL_USERNAME;
const _password = process.env.GRAPHQL_PASSWORD;

if (_graphqlEndpoint === null || _graphqlEndpoint === undefined || _graphqlEndpoint === '') {
  throw new Error('GRAPHQL_API_ENDPOINT process variable must be defined');
}


if (_auth && (!_username || !_password)) {
  throw new Error('GRAPHQL AUTH ENABLED WITH NO EMAIL OR PASSWORD');
}

const signinUserMutation = gql(`mutation Authenticate(
  $username: String!
  $password: String!
  ){
  authenticate(input: {
    username: $username,
    password: $password
  }) {
    clientMutationId
    jwtToken
  }
}
`)

function initAuthClient () {
  if (_clientInitializer) {
    return Promise.resolve(_clientInitializer);
  } else {
    const _initClient = new ApolloClient({
      // By default, this client will send queries to the
      //  `/graphql` endpoint on the same host
      link: new HttpLink({uri: _graphqlEndpoint, fetch: fetch}),
      cache: new InMemoryCache()
    });

    console.log('username', _username)
    _clientInitializer = _initClient.mutate({
      mutation: signinUserMutation,
      variables: {
        username: _username,
        password: _password
      }
    })
      .then(result => {
        clog('SIGNIN RESULT', result);

        const token = result.data.authenticate.jwtToken;

        const headers = {
          'authorization': `Bearer ${token}`
        };

        clog('HEADERS', headers);

        _client = new ApolloClient({
          // By default, this client will send queries to the
          //  `/graphql` endpoint on the same host
          link: new HttpLink({uri: _graphqlEndpoint, fetch: fetch, headers: headers}),
          cache: new InMemoryCache()
        });

        return _client;
      })
      .catch(error => {
        clog.error('UNABLE TO AUTH APOLLO CLIENT', {
          error: error,
          username: _username
        });
        throw error;
      })

    return Promise.resolve(_clientInitializer);
  }
}

function initNoAuthClient () {
  _client = new ApolloClient({
    // By default, this client will send queries to the
    //  `/graphql` endpoint on the same host
    link: new HttpLink({uri: _graphqlEndpoint, fetch: fetch}),
    cache: new InMemoryCache()
  });

  return Promise.resolve(_client);
}

function connect () {

  if (_client) {
    return Promise.resolve(_client)
  } else if (_auth) {
    return initAuthClient();
  } else {
    clog("NO AUTH - THAT'S NOT REALLY COOL");
    return initNoAuthClient();
  }
}

function disconnect() {
  _client = null
  _clientInitializer = null

  clog('APOLLO CLIENT DISCONNECTED', {
    _client: _client,
    _clientInitializer: _client
  })
}

module.exports = {
  connect: connect,
  disconnect: disconnect
};