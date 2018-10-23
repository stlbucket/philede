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
  watch: {
    $route (to, from){
        console.log('HEY ROUTE', to, from)
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.$store.state.focusProjectId
        }
      },
      fetchPolicy: 'network-only',
      skip () {
        return this.$store.state.focusProjectId === ''
      },
      update (result) {
        this.project = result.pdeProjectById || {
          releases: {
            nodes: []
          }
        }
        console.log('this.project', this.project)
        this.$store.commit('focusReleaseId', { focusReleaseId: (this.project.releases.nodes[0] || {id: ''}).id })
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
  },
  beforeDestroy() {
    this.$eventHub.$off('releaseToTesting')
    this.$eventHub.$off('releaseToStaging')
    this.$eventHub.$off('releaseToCurrent')
  }
}
</script>