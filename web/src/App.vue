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
      <artifact-tree
        :pdeProjectId="pdeProjectId"
      ></artifact-tree>
    </v-navigation-drawer>
    <v-toolbar
      app
      :clipped-left="clipped"
    >
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <!-- <v-btn icon @click.stop="miniVariant = !miniVariant">
        <v-icon v-html="miniVariant ? 'chevron_right' : 'chevron_left'"></v-icon>
      </v-btn> -->
      <!-- <v-btn icon @click.stop="clipped = !clipped">
        <v-icon>web</v-icon>
      </v-btn>
      <v-btn icon @click.stop="fixed = !fixed">
        <v-icon>remove</v-icon>
      </v-btn> -->
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
        <router-view/>
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
import ArtifactTree from './views/ArtifactTree/Component'
import AllProjects from './graphql/query/AllProjects.gql'

export default {
  name: 'App',
  components: { 
    ArtifactTree
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
      selectedProject: null
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