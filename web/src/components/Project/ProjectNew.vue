<template>
  <div>
    <h1>New Project</h1>
    <v-text-field
      v-model="projectName"
    ></v-text-field>
    <v-btn @click="createProject" :disabled="newDisabled">Create</v-btn>
    <v-btn @click="cancel">Cancel</v-btn>
  </div>
</template>

<script>
import createPdeProject from '../../gql/mutation/createPdeProject.gql'
import execSql from '../../gql/mutation/execSql.gql'

export default {
  name: "NewProject",
  components: {
  },
  props: {
  },
  computed: {
    newDisabled () {
      return this.projectName === ''
    }
  },
  methods: {
    createProject () {
      this.$apollo.mutate({
        mutation: createPdeProject,
        variables: {
          name: this.projectName
        }
      })
      .then(result => {
        this.$store.commit('focusProjectId', { focusProjectId: result.data.createPdeProject.pdeProject.id})
        this.$store.commit('focusReleaseId', { focusReleaseId: result.data.createPdeProject.pdeProject.releases.nodes.find(r => r.status === 'DEVELOPMENT').id })
      })
      .catch(error => {
        alert ('ERROR')
        console.log(error)
      })
    },
    cancel () {
      this.$router.go(-1)
    }
  },
  // created () {
  //   this.$apollo.mutate({
  //     client: 'b',
  //     mutation: execSql,
  //     variables: {
  //       sql: `
  //         SELECT schema_name
  //         FROM information_schema.schemata
  //         WHERE schema_name NOT LIKE 'pg_%'
  //         AND schema_name != 'public'
  //         AND schema_name != 'information_schema'
  //         ;
  //         `
  //     }
  //   })
  //   .then(result => {
  //     console.log('result', result)
  //   })
  //   .catch(error => {
  //     alert('ERROR')
  //     console.log(error)
  //   })
  // },
  data () {
    this.$store.commit('clearFocus')
    return {
      projectName: ''
    }
  },
}
</script>