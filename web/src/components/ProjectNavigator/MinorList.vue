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
      this.$apollo.queries.init.refetch()
    }
  },
  computed: {
    minors () {
      return this.release ? this.release.minors.nodes : []
    },
  },
  watch: {
  },
  apollo: {
    init: {
      query: releasePatchTree,
      variables () {
        return {
          id: this.focusReleaseId
        }
      },
      skip () {
        return this.focusReleaseId === null || this.focusReleaseId === undefined || this.focusReleaseId === ''
      },
      fetchPolicy: 'network-only',
      update (result) {
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
    this.$eventHub.$on('patchUpdated', this.queryRelease)
    this.$eventHub.$on('newMinorCreated', this.queryRelease)
    this.$eventHub.$on('devDeployCompleted', this.queryRelease)
  },
  beforeDestroy() {
    this.$eventHub.$off('minorDeferredToggled')
    this.$eventHub.$off('patchCreated')
    this.$eventHub.$off('patchUpdated')
    this.$eventHub.$off('newMinorCreated')
    this.$eventHub.$off('devDeployCompleted')
  }
}
</script>
