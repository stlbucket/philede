<template>
  <div>
    <v-select 
      label="Release"
      :items="releases"
      item-text="name"
      item-value="id"
      v-model="selectedReleaseId"
    ></v-select>
    <patch-tree
      :releaseId="selectedReleaseId"
      :focusArtifactId="focusArtifactId" 
    ></patch-tree>
    <!-- <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="Artifacts"
        ripple
      >
        Artifacts
      </v-tab>
      <v-tab-item
        key="Artifacts"
      >
        <artifact-tree
          :pdeProjectId="pdeProjectId"
          :focusArtifactId="focusArtifactId"
        ></artifact-tree>
      </v-tab-item>
      <v-tab
        key="Patches"
        ripple
      >
        Patches
      </v-tab>
      <v-tab-item
        key="Patches"
      >
        <patch-tree
          :releaseId="selectedReleaseId"
          :focusArtifactId="focusArtifactId" 
        ></patch-tree>
      </v-tab-item>
    </v-tabs> -->
  </div>
</template>

<script>
import ArtifactTree from '../ArtifactTree/Component'
import PatchTree from '../PatchTree/Component'
import projectReleaseTree from './projectReleaseTree.gql'

export default {
  name: "ReleaseNavigator",
  components: {
    ArtifactTree,
    PatchTree
  },
  apollo: {
    init: {
      query: projectReleaseTree,
      variables () {
        return {
          id: `${this.pdeProjectId}`
        }
      },
      networkPolicy: 'fetch-only',
      skip () {
        return this.pdeProjectId === ''
      },
      update (result) {
        this.pdeProject = result.pdeProjectById
        this.releases = this.pdeProject.releases.nodes
        this.selectedReleaseId = (this.releases[0] || {}).id
      }
    }
  },
  props: {
    pdeProjectId: {
      type: String,
      required: true
    },
    focusArtifactId: String
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      releases: [],
      selectedReleaseId: '',
      pdeProject: null
    }
  },
}
</script>
