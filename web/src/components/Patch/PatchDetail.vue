<template>
  <v-layout justify-center>
    <v-flex xs12 sm12>
      <v-toolbar color="indigo" dark>
        <v-toolbar-side-icon></v-toolbar-side-icon>
        <v-toolbar-title>
          <v-text-field
            v-model="artifactName"
          ></v-text-field>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn 
          @click="save"
          :disabled="disableCommit"
          v-shortkey.once="['ctrl', 'd']" 
          @shortkey="theAction()"
        >Keep Changes
        </v-btn>
        <v-btn 
          @click="revert"
          :disabled="disableRevert"
        >Discard Changes
        </v-btn>
      </v-toolbar>
      <v-toolbar :hidden="errorHidden" color="red">
        {{ errorMessage }}
        {{ cursorPosition }}
      </v-toolbar>
      <v-card>
        <v-container
          fluid
          grid-list-md
        >
          <v-layout row wrap>
            <v-flex
              v-bind="{ [`xs12`]: true }"
              key="editorUp"
            >
              <v-tabs
                dark
                slider-color="yellow"
              >
                <v-tab
                  key="ddl-up"
                  ripple
                >
                  Up DDL
                </v-tab>
                <v-tab-item
                  key="ddl-up"
                >
                  <v-card>
                    <editor
                      ref="editorUp" 
                      v-model="ddlUp" 
                      @init="editorInit" 
                      lang="pgsql" 
                      theme="tomorrow_night_bright"
                      width="100%" 
                      height="750"
                      readonly="readonly"
                    ></editor>

                    <v-card-actions><fieldset></fieldset>
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
                </v-tab-item>
                <v-tab
                  key="ddl-down"
                  ripple
                >
                  Down DDL
                </v-tab>
                <v-tab-item
                  key="ddl-down"
                >
                  <v-card>
                    <editor
                      ref="editorDown" 
                      v-model="ddlDown" 
                      @init="editorInit" 
                      lang="pgsql" 
                      theme="tomorrow_night_bright"
                      width="100%" 
                      height="750"
                      readonly="readonly"
                    ></editor>

                    <v-card-actions><fieldset></fieldset>
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
                </v-tab-item>
                <v-tab
                  key="dependencies"
                  ripple
                >
                  Dependencies
                </v-tab>
                <v-tab-item
                  key="dependencies"
                >
                  <v-card>
                    <h1>NOT IMPLEMENTED</h1>
                    <h2>Dependencies: </h2>
                    <h2>Dependent On: </h2>
                    <v-card-actions><fieldset></fieldset>
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
                </v-tab-item>
              </v-tabs>
            </v-flex>
          </v-layout>
        </v-container>
      </v-card>
    </v-flex>
  </v-layout>
</template>

<script>
//todo: rename artifact - done
//todo: vuex current contents
//todo: artifact down ddl
//todo: release up ddl - detail page - done
//todo: release down ddl - detail page - done

import patchById from '../../gql/query/patchById.gql'
import updateArtifact from '../../gql/mutation/updateArtifact.gql'
import updatePatch from '../../gql/mutation/updatePatch.gql'
import devDeployRelease from '../../gql/mutation/devDeployRelease.gql'
import gql from 'graphql-tag'
import ace from 'brace'

export default {
  name: "PatchDetail",
  components: {
    editor: require('vue2-ace-editor'),
  },
  props: {
    id: String
  },
  methods: {
    theAction (event) {
      console.log('theAction', event)
    },
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
    save () {
      return this.$apollo.mutate({
        mutation: updatePatch,
        variables: {
          id: this.patch.id,
          ddlUp: this.ddlUp,
          ddlDown: this.ddlDown
        },
        fetchPolicy: 'no-cache'
        })
        .then(result => {
          this.patch = result.data.updatePatchById.patch
          return this.$apollo.mutate({
            mutation: updateArtifact,
            variables: {
              id: this.patch.artifact.id,
              name: this.artifactName
            },
            fetchPolicy: 'no-cache'
          })
        .then(result => {
          console.log('this.patch', this.patch.minor.releaseId)
          return this.$apollo.mutate({
            mutation: devDeployRelease,
            variables: {
              releaseId: this.patch.minor.releaseId
            },
            fetchPolicy: 'no-cache'
          })
        })
        .then(result => {
          this.errorMessage = ''
        })
        .catch(error => {
          const errObj = JSON.parse(error.toString().replace('Error: GraphQL error:', ''))
          console.log(errObj)
          console.log('PATCH BITCH', this.patch.ddlUp.split('\n'))
          const errorLocation = this.patch.ddlUp.split('\n').reduce(
            (acc, line) => {
              console.log('line', line.length)
              if (acc.totalPosition >= errObj.position) {
                console.log('case 1')
                return acc
              } else {
                if ((acc.totalPosition + line.length) >= errObj.position) {
                  console.log('case 2')
                  return {
                    row: acc.row + 1,
                    position: errObj.position - acc.totalPosition,
                    totalPosition: acc.totalPosition + line.length
                  }
                } else {
                console.log('case 3')
                return {
                    row: acc.row + 1,
                    position: 0,
                    totalPosition: acc.totalPosition + line.length
                  }
                }
              }
            }, {
              row: 0,
              position: 0,
              totalPosition: 0
            }
          )
          console.log('errorLocation', errorLocation)
          this.errorMessage = errObj.message
        })
        .finally(() => {
          this.$refs.editorUp.focus()
          this.$apollo.queries.loadPatch.refetch()
          this.$eventHub.$emit('patchUpdated', this.patch)
        })
      })
    },
    revert () {
      this.ddlUp = this.patch.ddlUp
      this.ddlDown = this.patch.ddlDown
    }
  },
  apollo: {
    loadPatch: {
      fetchPolicy: 'network-only',
      query: patchById,
      variables () {
        return {id: this.focusPatchId}
      },
      skip () {
        return this.focusPatchId === ''
      },
      update (data) {
        this.patch = data.patchById || {}
        this.artifact = this.patch.artifact || {}
        this.artifactName = this.artifact.name
        this.ddlUp = this.patch.ddlUp || 'N/A'
        this.ddlDown = this.patch.ddlDown || 'N/A'
      }
    }
  },
  watch: {
    patch () {
      this.$store.commit('focusPatchId', {focusPatchId: this.patch.id})
    },
    // ddlUp () {
    //   console.log(this.$refs.editorUp.getCursorPosition())
    // }
  },
  computed: {
    focusPatchId () {
      return this.$store.state.focusPatchId
    },
    disableCommit () {
      const disabled = 
        this.ddlUp === this.patch.ddlUp && 
        this.ddlDown === this.patch.ddlDown && 
        this.artifactName === this.artifact.name
      return disabled
    },
    disableRevert () {
      const disabled = 
      this.ddlUp === this.patch.ddlUp && 
      this.ddlDown === this.patch.ddlDown && 
      this.artifactName === this.artifact.name
      return disabled
    },
    readonly () {
      return false  // Todo: this
    },
    errorHidden () {
      return this.errorMessage === ''
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
      patch: {},
      artifact: {},
      artifactName: '',
      errorMessage: '',
      cursorPosition: {}
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
