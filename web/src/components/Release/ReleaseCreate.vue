<template>
  <div>
    <h1>New Release - {{ projectId }}</h1>
    <v-btn @click="cancel">Cancel</v-btn>
    <v-btn @click="create" :disabled="createDisabled" >Create</v-btn>
    <v-text-field
      label="Name"
      v-model="releaseName"
    ></v-text-field>
    <v-text-field
      label="First Feature Name"
      v-model="firstFeatureName"
    ></v-text-field>
    <v-text-field
      label="First Patch Name"
      v-model="firstPatchName"
    ></v-text-field>
  </div>
</template>

<script>

export default {
  name: "ReleaseCreate",
  components: {
  },
  methods: {
    cancel () {
      this.$router.go(-1)
    },
    create () {
      console.log('releaseName', this.releaseName)
      console.log('firstFeatureName', this.firstFeatureName)
      console.log('firstPatchName', this.firstPatchName)      
    }
  },
  computed: {
    createDisabled () {
      return this.releaseName === '' || this.firstFeatureName === '' || this.firstPatchName === ''
    }
  },
  props: {
    projectId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      releaseName: '',
      firstFeatureName: '',
      firstPatchName: ''
    }
  },
}
</script>
