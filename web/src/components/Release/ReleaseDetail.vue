<template>
  <div>
    <h1>Release - {{ releaseNumber }}</h1>
    <v-btn @click="done">Done</v-btn>
  </div>
</template>

<script>

export default {
  name: "ReleaseDetail",
  components: {
  },
  methods: {
    done () {
      this.$router.go(-1)
    }
  },
  computed: {
    releaseNumber () {
      return this.release ? this.release.number : 'N/A'
    }
  },
  props: {
    id: {
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
