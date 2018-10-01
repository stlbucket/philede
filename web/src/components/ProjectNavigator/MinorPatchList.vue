<template>
  <div>
    <v-btn
      @click="newPatch"
      :disabled="newPatchDisabled"
    >New Patch</v-btn>
    <v-list>
      <template v-for="(patch, index) in minor.patches.nodes">
        <v-list-tile
          :key="patch.id"
          ripple
          @click="selected(patch)"
          :class="getCssClass(patch)"
        >
          <v-list-tile-content>
            <v-list-tile-sub-title class="text--primary">{{ `Patch: ${patch.number.split('.')[2]} - ${patch.artifact.name}` }}</v-list-tile-sub-title>
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
    newPatchDisabled () {
      return this.minor.locked
    }
  },
  methods: {
    selected (patch) {
      this.$eventHub.$emit('patchSelected', patch)
    },
    newPatch () {
      this.$eventHub.$emit('newPatch', this.minor)
    },
    focusPatchChanged (focusPatch) {
      this.focusPatch = focusPatch
    },
    getCssClass(patch) {
      return (patch.artifact.id === this.focusPatch.id) || patch.id === this.focusPatch.id ? 'v-list__tile--active' : 'v-list__tile'
    }
  },
  calculated: {

  },
  props: {
    minor: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      panel: [],
      expand: true,
      pdeProject: null,
      focusPatch: {
        artifact: {}
      }
    }
  },
  created () {
    this.$eventHub.$on('focusPatch', this.focusPatchChanged);
  },
  beforeDestroy() {
    this.$eventHub.$off('focusPatch');
  }
}
</script>
