<template>
  <div>
     <v-list>
      <template v-for="(patch, index) in minor.patches.nodes">
        <v-list-tile
          :key="patch.id"
          ripple
          @click="patchSelected(patch)"
          :class="patch.artifact.id === focusArtifactId ? 'v-list__tile--active' : 'v-list__tile'"

        >
          <v-list-tile-content>
            <v-list-tile-sub-title class="text--primary">{{ `${patch.number} - ${patch.artifact.name}` }}</v-list-tile-sub-title>
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
import releasePatchTree from './releasePatchTree.gql'

export default {
  name: "PatchList",
  methods: {
    patchSelected (patch) {
      console.log('patch', patch)
      this.$router.push({ name: 'artifact', params: { id: patch.artifact.id }})
    }
  },
  props: {
    minor: {
      type: Object,
      required: true
    },
    focusArtifactId: String
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
