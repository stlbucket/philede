<template>
  <div>
    <h1>New Project</h1>
    <v-text-field
      v-model="projectName"
    ></v-text-field>
    <v-btn @click="create" :disabled="newDisabled">Create</v-btn>
    <v-btn @click="cancel">Cancel</v-btn>
  </div>
</template>

<script>
import createPdeProject from '../gql/mutation/createPdeProject.gql'

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
    create () {
      this.$apollo.mutate({
        mutation: createPdeProject,
        variables: {
          name: this.projectName
        }
      })
      .then(result => {
        console.log('result', result)
        // this.$router.
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
  apollo: {
  },
  data () {
    return {
      projectName: ''
    }
  },
}
</script>