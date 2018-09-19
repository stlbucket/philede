<template>
  <div>
    <h1>Project: {{ project.name }}</h1>
    <release-manager
      :releases="releases"
    ></release-manager>
  </div>
</template>

<script>
import pdeProjectById from '../../gql/query/pdeProjectById.gql'
import ReleaseManager from './ReleaseManager'

export default {
  name: "ProjectDetail",
  components: {
    ReleaseManager
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  computed: {
    saveDisabled () {
      return this.projectName === this.project.name
    },
    releases () {
      return this.project.releases.nodes
    }
  },
  methods: {
    releaseToTesting (release) {
      this.$apollo.queries.init.refetch()
    },
    moveToStaging (release) {
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
        this.project = result.pdeProjectById
        this.projectName = this.project.name
        this.$eventHub.$emit('projectFocus', this.project.id)
      }
    }
  },
  data () {
    return {
      projectName: '',
      project: {
        releases: {
          nodes: []
        }
      }
    }
  },
  created () {
    this.$eventHub.$on('releaseToTesting', this.releaseToTesting)  
    this.$eventHub.$on('moveToStaging', this.releaseToTesting)  
  },
  beforeDestroy() {
    this.$eventHub.$off('releaseToTesting')
    this.$eventHub.$off('moveToStaging')
  }
}
</script>