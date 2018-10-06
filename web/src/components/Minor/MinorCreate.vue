<template>
  <div>
    <h1>New Minor Patch Set</h1>
    <v-text-field
      label="Name"
      v-model="minorName"
    ></v-text-field>
    <v-btn @click="cancel">Cancel</v-btn>
    <v-btn @click="create" :disabled="createDisabled">Create</v-btn>
  </div>
</template>

<script>
import buildMinor from '../../gql/mutation/buildMinor.gql'

export default {
  name: "MinorCreate",
  components: {
  },
  methods: {
    cancel () {
      this.$router.go(-1)
    },
    create () {
      this.$apollo.mutate({
        mutation: buildMinor,
        variables: {
          releaseId: this.releaseId,
          name: this.minorName
        }
      })
      .then(result => {
        this.$eventHub.$emit('newMinorCreated', result.data.buildMinor.minor)
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    }
  },
  computed: {
    releaseId () {
      return this.$store.state.focusReleaseId
    },
    createDisabled () {
      return this.minorName === ''
    }
  },
  data () {
    return {
      minorName: ''
    }
  },
}
</script>
