<template>
  <div>
    <v-select 
      label="Release"
      :items="releases"
      item-text="name"
      item-value="id"
      v-model="selectedReleaseId"
    ></v-select>
    <minor
      :releaseId="selectedReleaseId"
      :focusArtifactId="focusArtifactId" 
    ></minor>
  </div>
</template>

<script>
import Minor from '../Minor/Component'
import projectReleaseTree from './projectReleaseTree.gql'

export default {
  name: "ReleaseNavigator",
  components: {
    Minor
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
