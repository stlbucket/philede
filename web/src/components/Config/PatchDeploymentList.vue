<template>
  <div>
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
      </template>
    </v-list>        
  </div>
</template>

<script>
export default {
  name: "PatchDeploymentList",
  computed: {
    focusReleaseId () {
      return this.$store.state.focusReleaseId
    }
  },
  methods: {
    selected (patch) {
      this.$store.commit('focusPatchId', { focusPatchId: patch.id })
    },
    getCssClass(patch) {
      return (patch.id === this.focusPatchId) ? 'v-list__tile--active' : 'v-list__tile'
    },
    patchStatusColor(patch) {
      return patch.devDeployment ? (patch.devDeployment.status === 'DEPLOYED' ? 'green' : 'red') : 'yellow'
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
  }
}
</script>
