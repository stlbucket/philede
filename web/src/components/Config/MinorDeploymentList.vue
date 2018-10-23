<template>
  <div>
    <v-list
      v-for="(minor) in minors"
      :key="minor.id"
    >
      <minor-deployment
        :minor="minor"
      ></minor-deployment>
    </v-list>        
  </div>
</template>

<script>
import releasePatchTree from '../../gql/query/releasePatchTree.gql'
import MinorDeployment from './MinorDeployment'

export default {
  name: "MinorDeploymentList",
  components: {
    MinorDeployment
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
    focusReleaseId () {
      return this.$store.state.focusReleaseId
    }
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
      }
    }

  },
  props: {
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
      focusPatch: {}
    }
  }
}
</script>
