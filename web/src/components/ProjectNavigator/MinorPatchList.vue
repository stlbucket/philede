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
            <v-list-tile-sub-title class="text--primary">
              <v-icon :color="patchStatusColor(patch)" small>fiber_manual_record</v-icon>
              {{ `Patch: ${patch.number.split('.')[2]} - ${patch.patchType.name} - ${patch.artifact.name}` }}
            </v-list-tile-sub-title>
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
    focusPatchId () {
      return this.$store.state.focusPatchId
    }
  },
  methods: {
    selected (patch) {
      this.$store.commit('focusPatchId', { focusPatchId: patch.id })
    },
    newPatch () {
      this.$eventHub.$emit('newPatch', this.minor)
    },
    getCssClass(patch) {
      return (patch.id === this.focusPatchId) ? 'v-list__tile--active' : 'v-list__tile'
    },
    patchStatusColor(patch) {
      return patch.devDeployment ? (patch.devDeployment.status === 'DEPLOYED' ? 'green' : 'red') : 'yellow'
    }
  },
  watch: {
    minor: {
      handler (val) {
        this.$forceUpdate()
      },
      deep: true
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
  }
}
</script>
