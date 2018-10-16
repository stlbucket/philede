<template>
  <div>
    <h2>a list of named graphQL-jest tests - these will all use the named whitelist queries</h2>
    <v-btn @click="newGraphQLTest">New GraphQL Test</v-btn>
     <v-list>
      <template v-for="(test, index) in tests">
        <v-list-tile
          :key="test.id"
          ripple
          @click="selected(test)"
          :class="test.id === focusPatch.id ? 'v-list__tile--active' : 'v-list__tile'"
        >
          <v-list-tile-content>
            <v-list-tile-sub-title class="text--primary">{{ `${test.name}` }}</v-list-tile-sub-title>
          </v-list-tile-content>

        </v-list-tile>
        <v-divider
          v-if="index + 1 < tests.length"
          :key="index"
        ></v-divider>
      </template>
    </v-list>        
  </div>
</template>

<script>

export default {
  name: "TestListGraphQL",
  components: {
  },
  methods: {
    newGraphQLTest () {
      this.$eventHub.$emit('newGraphQLTest')
    },
    selected (test) {
      this.$router.push({ name: 'test-graph-ql', params: { id: test.id }})
    }
  },
  computed: {
  },
  watch: {
  },
  props: {
    tests: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      focusPatch: {}
    }
  },
}
</script>
