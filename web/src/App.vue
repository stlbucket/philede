<template>
  <v-app dark>
    <v-navigation-drawer
      persistent
      :mini-variant="miniVariant"
      :clipped="clipped"
      v-model="drawer"
      enable-resize-watcher
      width="400"
      app
    >
    <project-navigator></project-navigator>
    </v-navigation-drawer>
    <v-toolbar
      app
      :clipped-left="clipped"
    >
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <project-selector></project-selector>
      <v-spacer></v-spacer>
      <div selectable>
        <v-toolbar-title selectable v-text="title" @click="home"></v-toolbar-title>
      </div>
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
        <router-view></router-view>
      </v-container>
    </v-content>
    <v-navigation-drawer
      persistent
      :mini-variant="miniVariant"
      :clipped="clipped"
      v-model="rightDrawer"
      :right="right"
      enable-resize-watcher
      width="400"
      app
    >
      <artifact-navigator></artifact-navigator>
    </v-navigation-drawer>
    <v-footer :fixed="fixed" app>
      <span>&copy; 2017</span>
    </v-footer>
  </v-app>
</template>

<script>
import ProjectSelector from './components/Project/ProjectSelector'
import ProjectNavigator from './components/ProjectNavigator/ProjectNavigator'
import ArtifactNavigator from './components/ArtifactNavigator/ArtifactNavigator'

export default {
  name: 'App',
  components: { 
    ProjectNavigator,
    ArtifactNavigator,
    ProjectSelector
  },
  methods: {
    home () {
      this.$router.push({ name: 'home' })
    }
 },
  data () {
    return {
      clipped: true,
      drawer: true,
      fixed: false,
      items: [],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'postgraphIle-DE'
    }
  }
}
</script>

<style lang="css">
  .treeview-label { background-color: #494544; }

  .selectable { cursor: pointer; }

  .v-content .container { height: 100%; }
  .v-content .container > .layout { height: 100%; }
  .v-content .container > .layout .v-card.theme--dark { 	height: 100%; }
  .v-content .container > .layout .v-card.theme--dark .grid-list-md .row.wrap.layout { 	height: 100%; }
  .graphiql-parent { 	height: 90%; }
</style>