<template>
  <div>
    <h1>Project: {{ projectName }}</h1>
    <release-manager
      :releases="releases"
    ></release-manager>
  </div>
</template>

<script>
import pdeProjectById from '../../gql/query/pdeProjectById.gql'
import ReleaseManager from '../Release/ReleaseManager'

export default {
  name: "ProjectDetail",
  components: {
    ReleaseManager
  },
  props: {
    id: {
      type: String,
      default: ''
    }
  },
  computed: {
    projectName () {
      return this.project ? this.project.name : 'N/A'
    },
    saveDisabled () {
      return this.projectName === this.project.name
    },
    releases () {
      return this.project ? this.project.releases.nodes : []
    }
  },
  methods: {
    releaseToTesting (release) {
      this.$apollo.queries.init.refetch()
    },
    releaseToStaging (release) {
      this.$apollo.queries.init.refetch()
    },
    releaseToCurrent (release) {
      this.$apollo.queries.init.refetch()
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.id
        }
      },
      fetchPolicy: 'network-only',
      skip () {
        return this.id === ''
      },
      update (result) {
        this.project = result.pdeProjectById || {
        releases: {
          nodes: []
        }
      }
        this.$eventHub.$emit('projectFocus', this.project.id)
      }
    }
  },
  data () {
    return {
      project: {
        releases: {
          nodes: []
        }
      }
    }
  },
  created () {
    this.$eventHub.$on('releaseToTesting', this.releaseToTesting)  
    this.$eventHub.$on('releaseToStaging', this.releaseToStaging)  
    this.$eventHub.$on('releaseToCurrent', this.releaseToCurrent)  
  },
  beforeDestroy() {
    this.$eventHub.$off('releaseToTesting')
    this.$eventHub.$off('releaseToStaging')
    this.$eventHub.$off('releaseToCurrent')
  }
}
</script>