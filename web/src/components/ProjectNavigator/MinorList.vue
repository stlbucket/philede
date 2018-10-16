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
import releasePatchTree from '../../gql/query/releasePatchTree.gql'
import Minor from './Minor'

export default {
  name: "MinorList",
  components: {
    Minor
  },
  methods: {
    queryRelease () {
      console.log('heyo')
      this.$apollo.queries.init.refetch()
    }
  },
  computed: {
    minors () {
      return this.release ? this.release.minors.nodes : []
    },
    // focusReleaseId () {
    //   return this.$store.state.focusReleaseId
    // }
  },
  watch: {
    // focusReleaseId () {
    //   console.log('booya', this.$store.state.focusReleaseId)
    //   this.queryRelease()
    // },
  },
  apollo: {
    init: {
      query: releasePatchTree,
      variables () {
        // console.log('store', this.$store.state, this.focusReleaseId)
        return {
          id: this.focusReleaseId
        }
      },
      skip () {
        // console.log('this.frl', this.focusReleaseId)
        return this.focusReleaseId === null || this.focusReleaseId === undefined || this.focusReleaseId === ''
      },
      fetchPolicy: 'network-only',
      update (result) {
        // console.log('result')
        this.release = result.release
        this.allArtifactTypes = result.allArtifactTypes.nodes
      }
    }

  },
  props: {
    focusReleaseId: {
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
      focusPatch: {}
    }
  },
  created () {
    this.$eventHub.$on('minorDeferredToggled', this.queryRelease)
    this.$eventHub.$on('patchCreated', this.queryRelease)
    this.$eventHub.$on('newMinorCreated', this.queryRelease)
  },
  beforeDestroy() {
    this.$eventHub.$off('minorDeferredToggled')
    this.$eventHub.$off('patchCreated')
    this.$eventHub.$off('newMinorCreated')
  }
}
</script>
