<template>
  <div>
    <h1>New Schema</h1>
    <h2>Project: {{ projectName }}</h2>
    <h2>Release: {{ releaseName }}</h2>
    <v-text-field
      v-model="schemaName"
    ></v-text-field>
    <v-btn @click="create" :disabled="newDisabled">Create</v-btn>
    <v-btn @click="cancel">Cancel</v-btn>
  </div>
</template>

<script>
import createSchema from '../../gql/mutation/createSchema.gql'

export default {
  name: "NewSchema",
  components: {
  },
  props: {
    releaseId: {
      type: String,
      required: true
    }
  },
  computed: {
    newDisabled () {
      return this.schemaName === ''
    },
    projectName () {
      return 'NOT IMPLEMENTED'
    },
    releaseName () {
      return 'NOT IMPLEMENTED'
    }
  },
  methods: {
    create () {
      this.$apollo.mutate({
        mutation: createSchema,
        variables: {
          releaseId: this.releaseId,
          name: this.schemaName
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
      schemaName: ''
    }
  },
}
</script>