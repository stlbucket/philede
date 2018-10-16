<template>
  <div>
    <h1>Artifact: {{ artifactName }}</h1>
    <h2>Type: {{ artifactTypeName }}</h2>
    <h2>Patch History: </h2>
  </div>
</template>

<script>
import artifactById from '../../gql/query/artifactById.gql'
import updateArtifact from '../../gql/mutation/updateArtifact.gql'

export default {
  name: "ArtifactDetail",
  components: {
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  methods: {
    save () {
    },
    revert () {
    }
  },
  apollo: {
    loadArtifact: {
      fetchPolicy: 'network-only',
      query: artifactById,
      variables () {
        return {
          id: this.artifactId
        }
      },
      update (data) {
        this.artifact = data.artifactById
      }
    }
  },
  computed: {
    artifactId () {
      // console.log('this.$store.state.focusArtifactId', this.$store.state.focusArtifactId)
      // return this.$store.state.focusArtifactId
      return this.id
    },
    artifactName () {
      return this.artifact ? this.artifact.name : 'N/A'
    },
    artifactTypeName () {
      return this.artifact ? this.artifact.artifactType.name : 'N/A'
    }
  },
  data () {
    return {
      ddlUp: 'ddlUp',
      ddlDown: 'ddlDown',
      cmOptions: {
        // codemirror options
        tabSize: 2,
        mode: 'text/x-pgsql',
        theme: 'base16-dark',
        lineNumbers: true,
        line: true,
        // more codemirror options, 更多 codemirror 的高级配置...
      },
      artifact: {
        artifactType: {
          name: 'N/A'
        }
      },
      currentPatch: {}
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#codemirror {
  height: 100%;
}

#tree {
  width: 20%;
  float: left;
}

</style>
