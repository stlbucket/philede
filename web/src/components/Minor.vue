<template>
  <div>
    <v-toolbar dark>
      <v-toolbar-side-icon @click="toggleMinorHidden()"></v-toolbar-side-icon>
      <v-toolbar-title>{{ `${minor.number.split('.')[1]}-${minor.name}` }}</v-toolbar-title>
      <v-btn>New Patch</v-btn>
    </v-toolbar>
    <v-tabs
      dark
      slider-color="yellow"
      :hidden="hidden"
    >
      <v-tab
        key="Patches"
        ripple
      >
        Patches
      </v-tab>
      <v-tab-item
        key="Patches"
      >
        <minor-patch-list
          :minor="minor"
        ></minor-patch-list>
      </v-tab-item>
      <v-tab
        key="Artifacts"
        ripple
      >
        Artifacts
      </v-tab>
      <v-tab-item
        key="Artifacts"
      >
        <minor-artifact-tree
          :minor="minor"
          :allArtifactTypes="allArtifactTypes"
        ></minor-artifact-tree>
      </v-tab-item>
      <v-tab
        key="Tests"
        ripple
      >
        Tests
      </v-tab>
      <v-tab-item
        key="Tests"
      >
        <minor-test-suite
          :minor="minor"
        ></minor-test-suite>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import MinorPatchList from './MinorPatchList'
import MinorArtifactTree from './MinorArtifactTree'
import MinorTestSuite from './MinorTestSuite'

export default {
  name: "Minor",
  components: {
    MinorPatchList,
    MinorArtifactTree,
    MinorTestSuite
  },
  methods: {
    toggleMinorHidden (minorId) {
      this.hidden = !this.hidden
    }
  },
  props: {
    minor: {
      type: Object,
      required: true
    },
    allArtifactTypes: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      panel: [],
      expand: true,
      hidden: false
    }
  },
}
</script>
