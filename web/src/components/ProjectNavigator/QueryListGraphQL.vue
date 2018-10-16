<template>
  <div>
    <v-btn
      @click="newQuery"
    >New GraphQL Query</v-btn>
    <h2>this will be a list of named graph ql queries to later be used in tests and selectively published to the whitelist</h2>
    <!-- <v-btn>New GraphQL Test</v-btn>
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
    </v-list>         -->
  </div>
</template>

<script>

export default {
  name: "QueryListGraphQL",
  components: {
  },
  methods: {
    newQuery () {
      this.$eventHub.$emit('newGraphQLQuery')
    }
    // selected (test) {
    // }
  },
  computed: {
  },
  watch: {
  },
  props: {
    // tests: {
    //   type: Array,
    //   required: true
    // }
  },
  data () {
    return {
      focusPatch: {}
    }
  },
}
</script>
