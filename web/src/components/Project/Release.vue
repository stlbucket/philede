<template>
  {{ releaseTitle }}
</template>

<script>
import MinorList from '../ProjectNavigator/MinorList'

export default {
  name: "Release",
  components: {
    MinorList,
  },
  methods: {
  },
  computed: {
    releaseTitle () {
      const release = this.release
      return release ? `${release.number}: ${release.name}` : `slot empty`
    },
    releaseName () {
      const release = this.release
      return release ? release.name : 'slot empty'
    }
  },
  props: {
    release: {
      type: Object,
      required: false
    }
  },
  data () {
    return {
    }
  },
}
</script>
