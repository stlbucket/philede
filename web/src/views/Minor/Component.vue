<template>
  <div>
    <v-list
      v-for="(minor) in minors"
      :key="minor.id"
    >
      <v-toolbar dark>
        <v-toolbar-side-icon @click="minorSelected(minor.id)"></v-toolbar-side-icon>
        <v-toolbar-title>{{ minor.number }}</v-toolbar-title>
      </v-toolbar>
      <v-tabs
        dark
        slider-color="yellow"
        :hidden="minorHidden(minor.id)"
      >
        <v-tab
          key="Patches"
          ripple
        >
          Patches
        </v-tab>
        <v-tab-item
          key="Patches"
        >
          <minor-patch-list
            :minor="minor"
            :focusArtifactId="focusArtifactId"
          ></minor-patch-list>
        </v-tab-item>
        <v-tab
          key="Artifacts"
          ripple
        >
          Artifacts
        </v-tab>
        <v-tab-item
          key="Artifacts"
        >
          <minor-artifact-tree
            :minor="minor"
            :focusArtifactId="focusArtifactId"
            :allArtifactTypes="allArtifactTypes"
          ></minor-artifact-tree>
        </v-tab-item>
      </v-tabs>
    </v-list>        
  </div>
</template>

<script>
import releasePatchTree from './releasePatchTree.gql'
import MinorPatchList from '../../components/MinorPatchList/Component'
import MinorArtifactTree from '../../components/MinorArtifactTree/Component'

export default {
  name: "PatchTree",
  components: {
    MinorPatchList,
    MinorArtifactTree
  },
  methods: {
    minorSelected (minorId) {
      if (this.hiddenMinors.indexOf(minorId) > -1) {
        this.hiddenMinors = this.hiddenMinors.filter(id => id !== minorId)
      } else {
        this.hiddenMinors = this.hiddenMinors.concat([minorId])
      }
    },
    patchSelected (patch) {
      console.log('patch', patch)
      this.$router.push({ name: 'artifact', params: { id: patch.artifact.id }})
    },
    toggleMinor (minor) {
      console.log('toggleMinor', minor)
    },
    minorHidden (minorId) {
      return this.hiddenMinors.indexOf(minorId) > -1
    },
  },
  computed: {
    minors () {
      return this.release.minors.nodes
    },
    focusPatchId () {
      if (this.focusArtifactId)
        return this.release.minors.nodes.find(p => p.artifact.id === this.focusArtifactId).id
      return null
    }
  },
  watch: {
    releaseId () {
      this.$apollo.query({
        query: releasePatchTree,
        variables: {
          id: this.releaseId
        },
      })
      .then(result => {
        this.release = result.data.release
        this.allArtifactTypes = result.data.allArtifactTypes.nodes
      })
    }
  },
  props: {
    releaseId: {
      type: String,
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
      release: {
        minors: {
          nodes: []
        }
      },
      selectedMinor: null,
      hiddenMinors: [],
      pdeProject: null,
      allArtifactTypes: []
    }
  },
}
</script>
