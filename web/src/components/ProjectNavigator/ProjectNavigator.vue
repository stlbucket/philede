<template>
  <div>
    <v-toolbar>
      <v-select 
        label="Project"
        :items="projects"
        item-text="name"
        item-value="id"
        v-model="selectedProjectId"
        @change="projectSelected"
      ></v-select>
      <v-btn @click="newProject">New</v-btn>
      <v-btn @click="manageProject">Manage</v-btn>
    </v-toolbar>
    <release-navigator 
      :pdeProjectId="pdeProjectId"
      :focusReleaseId="focusReleaseId"
    ></release-navigator>
  </div>
</template>

<script>
import ReleaseNavigator from './ReleaseNavigator'
import allProjects from '../../gql/query/allProjects.gql'

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
      this.$router.push({ name: 'projectDetail', params: { id: pdeProjectId }})
    },
    newProject () {
      this.$router.push({ name: 'newProject' })
    },
    manageProject () {
      this.$router.push({ name: 'projectDetail', params: { id: this.selectedProjectId }})
    },
    schemaSelected (schema) {
      this.$eventHub.$emit('focusItem', schema)
    },
    newSchema (release) {
      this.$router.push({ name: 'newSchema', params: { releaseId: release.id }})
    },
    newMinor (release) {
      this.$router.push({ name: 'newMinor', params: { releaseId: release.id }})
    },
    artifactTypeSelected (artifactType) {
      this.$eventHub.$emit('focusItem', artifactType)
    },
    artifactSelected (artifact) {
      this.$router.push({ name: 'artifact', params: { id: artifact.id }})
      this.$eventHub.$emit('focusItem', artifact)
    },
    patchSelected (patch) {
      this.$router.push({ name: 'artifact', params: { id: patch.artifact.id }})
      this.$eventHub.$emit('focusItem', patch)
    },
    newPatch (minor) {
      this.$router.push({ name: 'newPatch', params: { minorId: minor.id }})
    },
    pgtTestSelected (test) {
       this.$router.push({ name: 'test-pg-tap', params: { id: test.id }})
    },
    gqlTestSelected (test) {
      this.$router.push({ name: 'test-graph-ql', params: { id: test.id }})
    },
    exploreRelease (release) {
      this.focusReleaseId = release.id
      this.$router.push({ name: 'releaseDetail', params: { id: release.id }})
    },
    newDevelopmentRelease () {
      this.$router.push({ name: 'newDevelopmentRelease', params: { projectId: this.selectedProjectId }})
    },
    boom (sha) {
      console.log('boom', sha)
    }
  },
  data () {
    return {
      projects: [],
      pdeProjectId: '',
      selectedProjectId: null,
      focusReleaseId: null
    }
  },
  created () {
    this.$eventHub.$on('pgtTestSelected', this.pgtTestSelected)
    this.$eventHub.$on('gqlTestSelected', this.gqlTestSelected)
    this.$eventHub.$on('schemaSelected', this.schemaSelected)
    this.$eventHub.$on('artifactSelected', this.artifactSelected)
    this.$eventHub.$on('artifactTypeSelected', this.artifactTypeSelected)  
    this.$eventHub.$on('patchSelected', this.patchSelected)  
    this.$eventHub.$on('newPatch', this.newPatch)  
    this.$eventHub.$on('newSchema', this.newSchema)  
    this.$eventHub.$on('exploreRelease', this.exploreRelease)  
    this.$eventHub.$on('newDevelopmentRelease', this.newDevelopmentRelease)  
    this.$eventHub.$on('newMinor', this.newMinor)  
  },
  beforeDestroy() {
    this.$eventHub.$off('pgtTestSelected')
    this.$eventHub.$off('gqlTestSelected')
    this.$eventHub.$off('artifactSelected')
    this.$eventHub.$off('artifactTypeSelected')
    this.$eventHub.$off('patchSelected')
    this.$eventHub.$off('newPatch')
    this.$eventHub.$off('schemaSelected')
    this.$eventHub.$off('newSchema')
    this.$eventHub.$off('exploreRelease')
    this.$eventHub.$off('newDevelopmentRelease')
    this.$eventHub.$off('newMinor')
  }
}
</script>
