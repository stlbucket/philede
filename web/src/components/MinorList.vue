<template>
  <div>
    <v-list
      v-for="(minor) in minors"
      :key="minor.id"
    >
      <minor
        :minor="minor"
        :allArtifactTypes="allArtifactTypes"
      ></minor>
    </v-list>        
  </div>
</template>

<script>
import releasePatchTree from '../gql/query/releasePatchTree.gql'
import Minor from './Minor'

export default {
  name: "MinorList",
  components: {
    Minor
  },
  methods: {
  },
  computed: {
    minors () {
      return this.release.minors.nodes
    }
  },
  watch: {
    releaseId () {
      if (this.releaseId !== '') {
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
    }
  },
  props: {
    releaseId: {
      type: String,
      required: true
    }
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
      allArtifactTypes: [],
      focusItem: {}
    }
  },
}
</script>
