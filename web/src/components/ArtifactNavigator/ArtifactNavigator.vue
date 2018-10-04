<template>
  <div>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="testNavigator"
        ripple
      >
        Test Navigator
      </v-tab>
      <v-tab-item
        key="testNavigator"
      >
        <test-navigator 
        ></test-navigator>
      </v-tab-item>
      <v-tab
        key="projectCumulativeSchema"
        ripple
      >
        Schema
      </v-tab>
      <v-tab-item
        key="projectCumulativeSchema"
      >
        <h1>treeview representation of all artifacts in the cumulative project history</h1>
      </v-tab-item>
    </v-tabs>

  </div>
</template>

<script>
import TestNavigator from '../TestNavigator/TestNavigator'

export default {
  name: "ArtifactNavigator",
  components: {
    TestNavigator
  },
}
</script>
