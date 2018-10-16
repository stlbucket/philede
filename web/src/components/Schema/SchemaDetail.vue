<template>
  <div>
    <h1>NOT IMPLEMENTED - Schema: {{ schemaName }}</h1>
    <h2>cumulative artifact tree</h2>
  </div>
</template>

<script>
import schemaById from '../../gql/query/schemaById.gql'
// import updateSchema from '../../gql/mutation/updateSchema.gql'

export default {
  name: "SchemaDetail",
  components: {
  },
  props: {
  },
  methods: {
    save () {
      // return this.$apollo.mutate({
      //   mutation: updatePatch,
      //   variables: {
      //     id: this.currentPatch.id,
      //     ddlUp: this.ddlUp,
      //     ddlDown: this.ddlDown
      //   },
      //   fetchPolicy: 'no-cache'
      //   })
      //   .then(result => {
      //     this.currentPatch = result.data.updatePatchById.patch
      //     return this.$apollo.mutate({
      //       mutation: updateSchema,
      //       variables: {
      //         id: this.currentPatch.schema.id,
      //         name: this.schemaName
      //       },
      //       fetchPolicy: 'no-cache'
      //     })
      //   .then(result => {
      //     this.$refs.editorUp.focus()
      //     this.$eventHub.$emit('patchUpdated', this.currentPatch)
      //   })
      //   .catch(error => {
      //     alert('ERROR')
      //     console.log('error', error)
      //   })
      // })
    },
    revert () {
      // this.ddlUp = this.currentPatch.ddlUp
      // this.ddlDown = this.currentPatch.ddlDown
    }
  },
  apollo: {
    loadSchema: {
      fetchPolicy: 'network-only',
      query: schemaById,
      variables () {
        return {
          id: this.schemaId
        }
      },
      // skip () {
      //   this.schemaId === ''
      // },
      update (data) {
        this.schema = data.schemaById
      }
    }
  },
  computed: {
    schemaId () {
      console.log('this.$store.state.focusSchemaId', this.$store.state.focusSchemaId)
      return this.$store.state.focusSchemaId
    },
    schemaName () {
      return this.schema ? this.schema.name : 'N/A'
    }
    // disableCommit () {
    //   const disabled = 
    //     this.ddlUp === this.currentPatch.ddlUp && 
    //     this.ddlDown === this.currentPatch.ddlDown && 
    //     this.schemaName === this.schema.name
    //   return disabled
    // },
    // disableRevert () {
    //   const disabled = 
    //   this.ddlUp === this.currentPatch.ddlUp && 
    //   this.ddlDown === this.currentPatch.ddlDown && 
    //   this.schemaName === this.schema.name
    //   return disabled
    // },
    // readonly () {
    //   return false  // Todo: this
    // }
  },
  // beforeRouteUpdate (to, from, next) {
  //   this.$emit('schema-route', to.params.id)
  //   this.captureWorkingDdl()
  //   .then(result => {
  //     next()
  //   })
  // },
  // beforeRouteLeave (to, from, next) {
  //   this.captureWorkingDdl()
  //   .then(result => {
  //     next()
  //   })
  // },
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
      schema: {
        schemaType: {
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
