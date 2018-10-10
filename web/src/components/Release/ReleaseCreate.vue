<template>
  <div>
    <h1>New Release - {{ projectId }}</h1>
    <v-btn @click="cancel">Cancel</v-btn>
    <v-btn @click="create" :disabled="createDisabled" >Create</v-btn>
    <v-text-field
      label="Name"
      v-model="releaseName"
    ></v-text-field>
  </div>
</template>

<script>
import pdeProjectById from '../../gql/query/pdeProjectById.gql'
import buildDevelopmentRelease from '../../gql/mutation/buildDevelopmentRelease.gql'

export default {
  name: "ReleaseCreate",
  components: {
  },
  methods: {
    cancel () {
      this.$router.go(-1)
    },
    create () {
      this.$apollo.mutate({
        mutation: buildDevelopmentRelease,
        variables: {
          projectId: this.$store.state.focusProjectId  ,
          name: this.releaseName
        }
      })
      .then(result => {
        console.log('result', result)
        this.$eventHub.$emit('newDevelopmentReleaseCreated', result.data.buildDevelopmentRelease.release)
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    }
  },
  computed: {
    createDisabled () {
      return this.releaseName === ''
    },
  },
  props: {
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.$store.state.focusProjectId
        }
      },
      update (result) {
        this.project = result.pdeProjectById
      }
    }

  },
  data () {
    return {
      releaseName: '',
    }
  },
}
</script>
