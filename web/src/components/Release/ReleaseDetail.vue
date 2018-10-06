<template>
  <div>
    <h1>Release - {{ release.number }}</h1>
    <v-btn @click="done">Done</v-btn>
    <v-textarea
      :value="release.ddlUp"
      auto-grow
      readonly
    ></v-textarea>
  </div>
</template>

<script>
import releasePatchTree from '../../gql/query/releasePatchTree.gql'

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
    focusReleaseId () {      
      return this.$store.state.focusReleaseId
    }
  },
  apollo: {
    init: {
      query: releasePatchTree,
      variables () {
        return {
          id: this.focusReleaseId
        }
      },
      skip () {
        return this.focusReleaseId === ''
      },
      fetchPolicy: 'network-only',
      update (result) {
        this.release = result.release
        console.log('this.release', this.release.ddlUp)
        // this.allArtifactTypes = result.allArtifactTypes.nodes
      }
    }

  },
  data () {
    return {
      release: {}
    }
  },
}
</script>
