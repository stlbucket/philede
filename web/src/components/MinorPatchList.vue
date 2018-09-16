<template>
  <div>
     <v-list>
      <template v-for="(patch, index) in minor.patches.nodes">
        <v-list-tile
          :key="patch.id"
          ripple
          @click="selected(patch)"
          :class="patch.artifact.id === focusItem.id ? 'v-list__tile--active' : 'v-list__tile'"
        >
          <v-list-tile-content>
            <v-list-tile-sub-title class="text--primary">{{ `${patch.number.split('.')[2]} - ${patch.artifact.name}` }}</v-list-tile-sub-title>
          </v-list-tile-content>

        </v-list-tile>
        <v-divider
          v-if="index + 1 < items.length"
          :key="index"
        ></v-divider>
      </template>
    </v-list>        
  </div>
</template>

<script>
export default {
  name: "MinorPatchList",
  computed: {
  },
  methods: {
    selected (patch) {
      this.$eventHub.$emit('patchSelected', patch)
    }
  },
  props: {
    minor: {
      type: Object,
      required: true
    },
    focusItem: Object
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      panel: [],
      expand: true,
      pdeProject: null
    }
  },
}
</script>
