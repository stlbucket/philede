<template>
  <div>
    <v-btn>New PgTap Test</v-btn>
    <v-list>
      <template v-for="(test, index) in tests">
        <v-list-tile
          :key="test.id"
          ripple
          @click="selected(test)"
          :class="test.id === focusItem.id ? 'v-list__tile--active' : 'v-list__tile'"
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
  name: "TestListPgTap",
  components: {
  },
  methods: {
    selected (test) {
      this.$eventHub.$emit('pgtTestSelected', test)
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
      focusItem: {}
    }
  },
}
</script>
