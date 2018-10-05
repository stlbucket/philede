<template>
  <div>
    <release-navigator 
      :pdeProjectId="pdeProjectId"
      :focusReleaseId="focusReleaseId"
    ></release-navigator>
  </div>
</template>

<script>
import ReleaseNavigator from './ReleaseNavigator'
import allProjects from '../../gql/query/allProjects.gql'
const SELECTED_PROJECT_ID = 'selectedProjectId'

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
      }
    }
  },
  methods: {
    projectSelected (pdeProjectId) {
      if (pdeProjectId) {
      }
    },
    newProject () {
      this.$router.push({ name: 'newProject' })
    },
    projectCreated (project) {
      this.projectSelected(project.id)
      // this.$eventHub.$emit('projectSelected', project.id)
    },
    manageProject () {
      this.$router.push({ name: 'projectDetail', params: { id: this.selectedProjectId }})
    },
    graphQLSchema () {
      this.$router.push({ name: 'graphQLSchema' })
    },
    graphiql () {
      this.$router.push({ name: 'graphileiql' })
    },
    newPsqlQuery () {
      this.$router.push({ name: 'new-psql-query' })
    },
    newGraphQLQuery () {
      this.$router.push({ name: 'graphileiql' })
    },
    schemaSelected (schema) {
      this.$eventHub.$emit('focusPatch', schema)
    },
    newSchema (release) {
      this.$router.push({ name: 'newSchema', params: { releaseId: release.id }})
    },
    newMinor (release) {
      this.$router.push({ name: 'newMinor', params: { releaseId: release.id }})
    },
    newMinorCreated (minor) {
      this.focusReleaseId = minor.releaseId
      this.$router.push({ name: 'releaseDetail', params: { id: minor.releaseId }})
    },
    artifactTypeSelected (artifactType) {
      this.$eventHub.$emit('focusPatch', artifactType)
    },
    artifactSelected (artifact) {
      this.$router.push({ name: 'artifact', params: { id: artifact.id }})
      this.$eventHub.$emit('focusPatch', artifact)
    },
    patchSelected (patch) {
      this.$router.push({ name: 'artifact', params: { id: patch.artifact.id }})
      this.$eventHub.$emit('focusPatch', patch)
    },
    newPatch (minor) {
      this.$router.push({ name: 'newPatch', params: { minorId: minor.id }})
    },
    patchCreated (patch) {
      this.$router.push({ name: 'artifact', params: { id: patch.artifactId }})
      this.$eventHub.$emit('focusPatch', patch)
    },
    pgtTestSelected (test) {
       this.$router.push({ name: 'test-pg-tap', params: { id: test.id }})
    },
    newPgTapTest () {
      this.$router.push({ name: 'pg-tap-test', params: { id: 'N/A' }})
    },
    newGraphQLTest () {
      this.$router.push({ name: 'graph-ql-test', params: { id: 'N/A' }})
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
    this.$eventHub.$on('patchCreated', this.patchCreated)  
    this.$eventHub.$on('newSchema', this.newSchema)  
    this.$eventHub.$on('exploreRelease', this.exploreRelease)  
    this.$eventHub.$on('newDevelopmentRelease', this.newDevelopmentRelease)  
    this.$eventHub.$on('newMinor', this.newMinor)  
    this.$eventHub.$on('newGraphQLQuery', this.newGraphQLQuery)  
    this.$eventHub.$on('newPsqlQuery', this.newPsqlQuery)  
    this.$eventHub.$on('newPgTapTest', this.newPgTapTest)  
    this.$eventHub.$on('newGraphQLTest', this.newGraphQLTest)
    this.$eventHub.$on('graphQLSchema', this.graphQLSchema)
    this.$eventHub.$on('graphiql', this.graphiql)
    this.$eventHub.$on('newDevelopmentReleaseCreated', this.exploreRelease)
    this.$eventHub.$on('newProject', this.newProject)
    this.$eventHub.$on('manageProject', this.manageProject)
    this.$eventHub.$on('projectSelected', this.projectSelected)
    this.$eventHub.$on('newMinorCreated', this.newMinorCreated)
    this.$eventHub.$on('projectCreated', this.projectCreated)
  },
  beforeDestroy() {
    this.$eventHub.$off('pgtTestSelected')
    this.$eventHub.$off('gqlTestSelected')
    this.$eventHub.$off('artifactSelected')
    this.$eventHub.$off('artifactTypeSelected')
    this.$eventHub.$off('patchSelected')
    this.$eventHub.$off('newPatch')
    this.$eventHub.$off('patchCreated')
    this.$eventHub.$off('schemaSelected')
    this.$eventHub.$off('newSchema')
    this.$eventHub.$off('exploreRelease')
    this.$eventHub.$off('newDevelopmentRelease')
    this.$eventHub.$off('newMinor')
    this.$eventHub.$off('newGraphQLQuery')
    this.$eventHub.$off('newPsqlQuery')
    this.$eventHub.$off('newPgTapTest')
    this.$eventHub.$off('newGraphQLTest')
    this.$eventHub.$off('graphQLSchema')
    this.$eventHub.$off('graphiql')
    this.$eventHub.$off('newDevelopmentReleaseCreated')
    this.$eventHub.$off('newProject')
    this.$eventHub.$off('manageProject')
    this.$eventHub.$off('projectSelected')
    this.$eventHub.$off('newMinorCreated')
    this.$eventHub.$off('projectCreated')
  }
}
</script>
