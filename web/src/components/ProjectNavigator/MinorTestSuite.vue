<template>
  <div>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="PgTap"
        ripple
      >
        PgTap
      </v-tab>
      <v-tab-item
        key="PgTap"
      >
        <test-list-pg-tap
          :tests="pgtTests"
        ></test-list-pg-tap>
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
        <test-list-graph-q-l
          :tests="gqlTests"
        ></test-list-graph-q-l>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import TestListGraphQL from './TestListGraphQL'
import TestListPgTap from './TestListPgTap'

export default {
  name: "MinorTestSuite",
  components: {
    TestListGraphQL,
    TestListPgTap
  },
  methods: {
  },
  computed: {
    gqlTests () {
      return this.minor.gqlTests.nodes
    },
    pgtTests () {
      return this.minor.pgtTests.nodes
    }
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
