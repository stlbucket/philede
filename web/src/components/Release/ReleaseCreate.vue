<template>
  <div>
    <h1>New Release - {{ projectId }}</h1>
    <v-btn @click="cancel">Cancel</v-btn>
    <v-btn @click="create">Create</v-btn>
    <v-text-field
      label="Name"
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
      
    }
  },
  computed: {
  },
  props: {
    projectId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
    }
  },
}
</script>
