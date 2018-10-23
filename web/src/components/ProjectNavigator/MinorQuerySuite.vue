<template>
  <div>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="Psql"
        ripple
      >
        Psql
      </v-tab>
      <v-tab-item
        key="Psql"
      >
        <query-list-psql
          :minorId="minor.id"
        ></query-list-psql>
      </v-tab-item>
      <v-tab
        key="GraphQL"
        ripple
      >
        GraphQL
      </v-tab>
      <v-tab-item
        key="GraphQL"
      >
        <query-list-graph-q-l
        ></query-list-graph-q-l>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import QueryListGraphQL from './QueryListGraphQL'
import QueryListPsql from './QueryListPsql'

export default {
  name: "MinorQuerySuite",
  components: {
    QueryListGraphQL,
    QueryListPsql
  },
  methods: {
  },
  computed: {
    // gqlTests () {
    //   return this.minor.gqlTests.nodes
    // },
    // pgtTests () {
    //   return this.minor.pgtTests.nodes
    // }
  },
  watch: {
  },
  props: {
    minor: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
    }
  },
}
</script>
