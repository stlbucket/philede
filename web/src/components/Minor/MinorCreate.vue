<template>
  <div>
    <h1>New Minor Patch Set - {{ releaseId }}</h1>
    <v-text-field
      label="Name"
    ></v-text-field>
    <v-btn @click="cancel">Cancel</v-btn>
  </div>
</template>

<script>

export default {
  name: "MinorCreate",
  components: {
  },
  methods: {
    cancel () {
      this.$router.go(-1)
    }
  },
  computed: {
  },
  props: {
    releaseId: {
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
