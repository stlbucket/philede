<template>
  <div>
    <v-toolbar>
      <v-select 
        label="Current Project"
        :items="projects"
        item-text="name"
        item-value="id"
        :value="selectedProjectId"
        @change="projectSelected"
      ></v-select>
      <v-btn @click="manageProject">Manage</v-btn>
      <v-btn @click="newProject">New</v-btn>
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
      }
    }
  },
  computed: {
    selectedProjectId () {
      return this.$store.state.selectedProjectId
    }
  },
  watch: {
    selectedProjectId () {
      this.$apollo.queries.init.refetch()
    }
  },
  methods: {
    projectSelected (pdeProjectId) {
      if (pdeProjectId) {
        this.$store.commit('selectedProjectId', { projectId: pdeProjectId})
        this.$eventHub.$emit('projectSelected', pdeProjectId)
      }
    },
    newProject () {
      this.$eventHub.$emit('newProject')
    },
    manageProject () {
      this.$eventHub.$emit('manageProject', this.pdeProjectId)
    },
  },
  data () {
    return {
      projects: [],
      pdeProjectId: ''
    }
  },
}
</script>
