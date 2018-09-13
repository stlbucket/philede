<template>
  <v-app dark>
    <v-navigation-drawer
      persistent
      :mini-variant="miniVariant"
      :clipped="clipped"
      v-model="drawer"
      enable-resize-watcher
      fixed
      app
    >
    <release-navigator 
      :pdeProjectId="pdeProjectId"
      :focusArtifactId="focusArtifactId" 
    ></release-navigator>
    </v-navigation-drawer>
    <v-toolbar
      app
      :clipped-left="clipped"
    >
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <v-toolbar-title v-text="title"></v-toolbar-title>
      <v-spacer></v-spacer>
      <v-select 
        label="Project"
        :items="projects"
        item-text="name"
        item-value="id"
        v-model="selectedProject"
      ></v-select>
      <v-spacer></v-spacer>
      <v-btn icon @click.stop="rightDrawer = !rightDrawer">
        <v-icon>menu</v-icon>
      </v-btn>
    </v-toolbar>
    <v-content>
      <v-container
        fluid
        justify-start
      >
        <router-view @artifact-route="artifactRoute" ></router-view>
      </v-container>
    </v-content>
    <v-navigation-drawer
      temporary
      :right="right"
      v-model="rightDrawer"
      fixed
      app
    >
      <v-list>
        <v-list-tile @click="right = !right">
          <v-list-tile-action>
            <v-icon>compare_arrows</v-icon>
          </v-list-tile-action>
          <v-list-tile-title>Switch drawer (click me)</v-list-tile-title>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-footer :fixed="fixed" app>
      <span>&copy; 2017</span>
    </v-footer>
  </v-app>
</template>

<script>
import AllProjects from './graphql/query/AllProjects.gql'
import ReleaseNavigator from './views/ReleaseNavigator/Component'

export default {
  name: 'App',
  components: { 
    ReleaseNavigator
  },
  data () {
    return {
      pdeProjectId: "",
      clipped: true,
      drawer: true,
      fixed: false,
      items: [],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'phile-de',
      projects: [],
      selectedProject: null,
      focusArtifactId: null,
    }
  },
  methods: {
    artifactRoute (id) {
      this.focusArtifactId = id
    }
  },
  watch: {
    selectedProject () {
      this.pdeProjectId = this.selectedProject
    }
  },
  apollo: {
    allProjects: {
      query: AllProjects,
      update (result) {
        this.projects = result.allPdeProjects.nodes
        this.selectedProject = (this.projects[0] || {id: ""}).id
      }
    }
  }
}
</script>

<style lang="css">
  .treeview-label {
    background-color: #494544;
  }
</style>