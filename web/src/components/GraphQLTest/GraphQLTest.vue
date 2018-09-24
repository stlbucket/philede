<template>
  <v-layout justify-center>
    <v-flex xs12 sm12>
      <h1>GraphQL Test - NOT IMPLEMENTED</h1>
      <v-toolbar color="indigo" dark>
        <v-toolbar-side-icon></v-toolbar-side-icon>
        <v-toolbar-title>{{ artifact.name }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn 
          @click="captureWorkingDdl"
          :disabled="disableCapture"
        >Capture
        </v-btn>
        <v-btn 
          @click="commitWorkingDdl"
          :disabled="disableCommit"
        >Commit
        </v-btn>
        <v-btn 
          @click="revertWorkingDdl"
          :disabled="disableRevert"
        >Revert
        </v-btn>
      </v-toolbar>

      <v-card>
        <v-container
          fluid
          grid-list-md
        >
          <v-layout row wrap>
            <v-flex
              v-bind="{ [`xs12`]: true }"
              key="editor"
            >
              <v-card>
                <editor
                  ref="editor" 
                  v-model="ddlUp" 
                  @init="editorInit" 
                  lang="pgsql" 
                  theme="tomorrow_night_bright"
                  width="100%" 
                  height="750"
                  readonly="readonly"
                ></editor>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn icon>
                    <v-icon>favorite</v-icon>
                  </v-btn>
                  <v-btn icon>
                    <v-icon>bookmark</v-icon>
                  </v-btn>
                  <v-btn icon>
                    <v-icon>share</v-icon>
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-flex>
          </v-layout>
        </v-container>
      </v-card>
    </v-flex>
  </v-layout>
  <!-- <div
    justify-start
  >
    <h1>{{ artifact.name }}</h1>
    <v-btn 
      @click="captureWorkingDdl"
      :disabled="disableCapture"
    >Capture
    </v-btn>
    <v-btn 
      @click="commitWorkingDdl"
      :disabled="disableCommit"
    >Commit
    </v-btn>
    <v-btn 
      @click="revertWorkingDdl"
      :disabled="disableRevert"
    >Revert
    </v-btn>
    <div
    >
      <editor
        ref="editor" 
        v-model="ddlUp" 
        @init="editorInit" 
        lang="pgsql" 
        theme="tomorrow_night_bright"
        width="100%" 
        height="750"
        readonly="readonly"
      ></editor>
    </div>
  </div> -->
</template>

<script>
// import artifactById from '../../gql/query/artifactById.gql'
// import captureWorkingDdl from '../../gql/mutation/captureWorkingDdl.gql'
// import commitWorkingDdl from '../../gql/mutation/commitWorkingDdl.gql'
import ace from 'brace'

export default {
  name: "PsqlQuery",
  components: {
    editor: require('vue2-ace-editor'),
  },
  props: {
    id: String
  },
  methods: {
    editorInit: function () {
        require('brace/ext/language_tools') //language extension prerequsite...
        require('brace/mode/html')                
        require('brace/mode/javascript')    //language
        require('brace/mode/less')
        require('brace/theme/chrome')
        require('brace/snippets/javascript') //snippet
        require('brace/mode/pgsql')
        require('brace/theme/tomorrow_night_bright')
    },
    editName () {
      return true
    },
    captureWorkingDdl () {
      // if (this.ddlUp !== this.currentPatch.ddlUpWorking && this.currentPatch.id){
      //   console.log('this.currentPatch', this.currentPatch)
      //   return this.$apollo.mutate({
      //     mutation: captureWorkingDdl,
      //     variables: {
      //       patchId: this.currentPatch.id,
      //       ddlUpWorking: this.ddlUp
      //     },
      //     fetchPolicy: 'no-cache'
      //   })
      //   .then(result => {
      //     this.currentPatch = result.data.updatePatchById.patch
      //     this.$refs.editor.focus()
      //   })
      //   .catch(error => {
      //     alert('ERROR')
      //     console.log('error', error)
      //   })
      // } else {
      //   return Promise.resolve()
      // }

    },
    commitWorkingDdl () {
      // return this.$apollo.mutate({
      //   mutation: commitWorkingDdl,
      //   variables: {
      //     patchId: this.currentPatch.id,
      //     ddlUp: this.ddlUp
      //   },
      //   fetchPolicy: 'no-cache'
      // })
      // .then(result => {
      //   this.currentPatch = result.data.updatePatchById.patch
      //   this.$refs.editor.focus()
      // })
      // .catch(error => {
      //   alert('ERROR')
      //   console.log('error', error)
      // })
    },
    revertWorkingDdl () {

    }
  },
  // apollo: {
  //   loadArtifact: {
  //     fetchPolicy: 'network-only',
  //     query: artifactById,
  //     variables () {
  //       return {id: this.id}
  //     },
  //     update (data) {
  //       this.artifact = data.artifactById
  //       this.currentPatch = this.artifact.patches.nodes[0] || {ddlUp: null}
  //       this.ddlUp = this.currentPatch.ddlUpWorking
  //     }
  //   }

  // },
  computed: {
    disableCapture () {
      return false  // Todo: this
      // return this.ddlUp === this.currentPatch.ddlUpWorking
    },
    disableCommit () {
      return false  // Todo: this
      // return this.disableCapture ? this.currentPatch.ddlUp === this.currentPatch.ddlUpWorking : true
    },
    disableRevert () {
      return false  // Todo: this
      // return false
    },
    readonly () {
      return false  // Todo: this
    },
    isDirty () {
      return false  // Todo: this
      // return this.currentPatch.ddlUp !== this.currentPatch.ddlUpWorking
    }
  },
  // beforeRouteUpdate (to, from, next) {
  //   this.$emit('artifact-route', to.params.id)
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
      ddlUp: 'this will be a jest test that uses named queries defined in adjacent tab',
      cmOptions: {
        // codemirror options
        tabSize: 2,
        mode: 'text/x-pgsql',
        theme: 'base16-dark',
        lineNumbers: true,
        line: true,
        // more codemirror options, 更多 codemirror 的高级配置...
      },
      artifact: {},
      currentPatch: {}
    }
  },
}
</script>
