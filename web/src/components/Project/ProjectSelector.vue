<template>
  <div>
    <v-toolbar>
      <v-select 
        label="Current Project"
        :items="projects"
        item-text="name"
        item-value="id"
        v-model="selectedProjectId"
      ></v-select>
      <v-spacer></v-spacer>
    </v-toolbar>
  </div>
</template>

<script>
import allProjects from '../../gql/query/allProjects.gql'

export default {
  name: "ProjectSelector",
  components: {
  },
  apollo: {
    init: {
      query: allProjects,
      networkPolicy: 'fetch-only',
      update (result) {
        this.projects = result.allPdeProjects.nodes
        this.selectedProjectId = this.focusProjectId
      }
    }
  },
  computed: {
    focusProjectId () {
      return this.$store.state.focusProjectId
    }
  },
  watch: {
    focusProjectId () {
      this.$apollo.queries.init.refetch()
    },
    selectedProjectId () {
      this.$store.commit('focusProjectId', { focusProjectId: this.selectedProjectId})
      // this.$eventHub.$emit('projectSelected', this.pdeProjectId)
    }
  },
  methods: {
    projectImported (projectId) {
      this.$apollo.queries.init.refetch()
      this.$store.commit('focusProjectId', projectId)
    },
   },
  data () {
    return {
      projects: [],
      pdeProjectId: '',
      selectedProjectId: ''
    }
  },
  created () {
    this.$eventHub.$on('projectImported', this.projectImported)
  },
  beforeDestroy() {
    this.$eventHub.$off('projectImported')
  }
}
</script>
