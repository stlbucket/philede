<template>
  <v-layout justify-center>
    <v-flex xs12 sm12>
      <h1>PSQL Query</h1>
      <v-toolbar color="indigo" dark>
        <v-toolbar-side-icon></v-toolbar-side-icon>
        <v-text-field
          label="Name"
          v-model="name"
        ></v-text-field>
        <v-spacer></v-spacer>
        <v-btn 
          @click="saveQuery"
          :disabled="saveQueryDisabled"
        >Save Query
        </v-btn>
        <v-btn 
          @click="execSql"
        >Exec Sql
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
                  v-model="sql" 
                  @init="editorInit" 
                  lang="pgsql" 
                  theme="tomorrow_night_bright"
                  width="100%" 
                  height="400"
                  readonly="readonly"
                ></editor>
                <hr/>
                <editor
                  ref="results" 
                  v-model="results" 
                  @init="editorInit" 
                  theme="tomorrow_night_bright"
                  width="100%" 
                  height="400"
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
</template>

<script>
import ace from 'brace'
import execSql from '../../gql/mutation/execSql.gql'
import psqlQueryById from '../../gql/query/psqlQueryById.gql'
import createPsqlQuery from '../../gql/mutation/createPsqlQuery.gql'

export default {
  name: "PsqlQuery",
  components: {
    editor: require('vue2-ace-editor'),
  },
  props: {
    id: {
      type: String,
      required: false
    }
  },
  apollo: {

  },
  computed: {
    saveQueryDisabled () {
      return this.focusMinorId === '' || this.sql === ''
    },
    focusMinorId () {
      return this.$store.state.focusMinorId
    }
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
    execSql () {
      this.$apollo.mutate({
        client: 'b',
        mutation: execSql,
        variables: {
          sql: this.sql
        }
      })
      .then(result => {
        console.log('result', result)
        this.results = JSON.stringify(result.data.ExecSql.result)
        // this.results = result.data.ExecSql.result.rows
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    },
    saveQuery () {
      alert(`NOT IMPLEMENTED: ${this.focusMinorId}`)
    }
  },
  data () {
    this.$store.commit('clearFocus')
    return {
      sql: `drop schema cards cascade;
      `,
      results: 'results',
      name: ''
    }
  }
}
</script>
