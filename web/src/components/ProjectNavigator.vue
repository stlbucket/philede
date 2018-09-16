<template>
  <div>
    <v-toolbar>
      <v-btn @click="newProject">New</v-btn>
      <v-select 
        label="Project"
        :items="projects"
        item-text="name"
        item-value="id"
        v-model="selectedProjectId"
        @change="projectSelected"
      ></v-select>
    </v-toolbar>
    <release-navigator 
      :pdeProjectId="pdeProjectId"
    ></release-navigator>
  </div>
</template>

<script>
import ReleaseNavigator from './ReleaseNavigator'
import allProjects from '../gql/query/allProjects.gql'

export default {
  name: "ProjectNavigator",
  components: {
    ReleaseNavigator
  },
  apollo: {
    init: {
      query: allProjects,
      networkPolicy: 'fetch-only',
      update (result) {
        this.projects = result.allPdeProjects.nodes
        this.pdeProjectId = (this.projects[0] || {}).id
        this.selectedProjectId = this.pdeProjectId
      }
    }
  },
  methods: {
    projectSelected (pdeProjectId) {
      this.pdeProjectId = pdeProjectId
      this.$router.push({ name: 'project', params: { id: pdeProjectId }})
    },
    newProject () {
      this.$router.push({ name: 'newProject' })
    },
    artifactTypeSelected (artifactType) {
      console.log('artifact', artifactType)
    },
    artifactSelected (artifact) {
      this.$router.push({ name: 'artifact', params: { id: artifact.id }})
    },
    patchSelected (patch) {
      this.$router.push({ name: 'artifact', params: { id: patch.artifact.id }})
    },
    pgtTestSelected (test) {
     console.log('pgts', test)
       this.$router.push({ name: 'test-pg-tap', params: { id: test.id }})
    },
    gqlTestSelected (test) {
      console.log('gqlts', test)
      this.$router.push({ name: 'test-graph-ql', params: { id: test.id }})
    },
    boom (sha) {
      console.log('boom', sha)
    }
  },
  data () {
    return {
      projects: [],
      pdeProjectId: '',
      selectedProjectId: null
    }
  },
  created () {
    this.$eventHub.$on('pgtTestSelected', this.pgtTestSelected);
    this.$eventHub.$on('gqlTestSelected', this.gqlTestSelected);
    this.$eventHub.$on('artifactSelected', this.artifactSelected);
    this.$eventHub.$on('artifactTypeSelected', this.artifactTypeSelected);  
    this.$eventHub.$on('patchSelected', this.patchSelected);  
  },
  beforeDestroy() {
    this.$eventHub.$off('pgtTestSelected');
    this.$eventHub.$off('gqlTestSelected');
    this.$eventHub.$off('artifactSelected');
    this.$eventHub.$off('artifactTypeSelected');
    this.$eventHub.$off('patchSelected');
  }
}
</script>
