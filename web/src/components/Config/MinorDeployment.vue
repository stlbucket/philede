<template>
  <div>
    <v-toolbar dark>
      <v-toolbar-side-icon @click="toggleMinorHidden()"></v-toolbar-side-icon>
      <h3>{{ `${minor.number.split('.')[1]}-${minor.name}` }}</h3>
      <v-spacer></v-spacer>
    </v-toolbar>
    <patch-deployment-list
      :minor="minor"
    ></patch-deployment-list>
 </div>
</template>

<script>
import PatchDeploymentList from './PatchDeploymentList'

export default {
  name: "MinorDeployment",
  components: {
    PatchDeploymentList,
  },
  methods: {
    toggleMinorHidden (minorId) {
      this.hidden = !this.hidden
    }
  },
  computed: {
  },
  props: {
    minor: {
      type: Object,
      required: true
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
