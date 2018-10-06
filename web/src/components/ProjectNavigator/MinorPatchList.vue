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
    },
    focusArtifactId () {
      return this.$store.state.focusArtifactId
    }
  },
  methods: {
    selected (patch) {
      console.log('patch', patch)
      this.$store.commit('focusArtifactId', { focusArtifactId: patch.artifactId })
    },
    newPatch () {
      this.$eventHub.$emit('newPatch', this.minor)
    },
    getCssClass(patch) {
      console.log('focus', this.focusArtifactId)
      return (patch.artifactId === this.focusArtifactId) ? 'v-list__tile--active' : 'v-list__tile'
    }
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
