<template>
  <div>
    <h1>ArtifactType: {{ artifactTypeName }}</h1>
    <h2> DDL: </h2>
  </div>
</template>

<script>
import artifactTypeById from '../../gql/query/artifactTypeById.gql'
import updateArtifact from '../../gql/mutation/updateArtifact.gql'

export default {
  name: "ArtifactTypeDetail",
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
    loadArtifactType: {
      fetchPolicy: 'network-only',
      query: artifactTypeById,
      variables () {
        return {
          id: this.artifactTypeId
        }
      },
      update (data) {
        console.log('whaiowfhj', data)
        this.artifactType = data.artifactTypeById
      }
    }
  },
  computed: {
    artifactTypeId () {
      // console.log('this.$store.state.focusArtifactId', this.$store.state.focusArtifactId)
      // return this.$store.state.focusArtifactId
      return this.id
    },
    artifactTypeName () {
      return this.artifactType ? this.artifactType.name : 'N/A'
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
      artifactType: {
        name: 'N/A'
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
