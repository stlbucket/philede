<template>
  <div>
    <h1>ALSO WORKING ON A BETTER VISUALIZATION HERE BASED ON D3 FORCE-DIRECTED GRAPH</h1>
    <voyager
      :introspection="introspectionProvider"
    ></voyager>
  </div>
</template>

<script>
import introspection from '../../gql/query/introspection.gql'
import {Voyager} from 'graphql-voyager';
import fetch from 'isomorphic-fetch';

export default {
  name: "GraphQLSchema",
  components: {
    Voyager
  },
  props: {
  },
  methods: {
    introspectionProvider(query) {
      // return fetch('http://localhost:8080/graphql', {
      // console.log('query', query)
      this.$store.commit('clearFocus')
      return fetch(window.location.origin + '/graphql', {
        method: 'post',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({query: query}),
      }).then(response => response.json())
      // {
      //   console.log('response', response)
      //   console.log('json', response.json())
      //   return response.json()
      // });
    }
  },
  apollo: {
    introspection: {
      fetchPolicy: 'network-only',
      query: introspection,
      update (data) {
        console.log('introspection', data)
      }
    }
  },
  computed: {
  }
}
</script>
