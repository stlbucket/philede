<template>
  <div>
    <h1>New Patch</h1>
    <p>minor id: {{ minorId }}</p>
    <!-- <v-text-field
      v-model="patchName"
    ></v-text-field> -->
    <v-btn @click="create" :disabled="newDisabled">Create</v-btn>
    <v-btn @click="cancel">Cancel</v-btn>
  </div>
</template>

<script>
import createPatch from '../../gql/mutation/createPatch.gql'

export default {
  name: "NewPatch",
  components: {
  },
  props: {
    minorId: {
      type: String,
      require: true
    }
  },
  computed: {
    newDisabled () {
      return this.patchName === ''
    }
  },
  methods: {
    create () {
    //   this.$apollo.mutate({
    //     mutation: createPatch,
    //     variables: {
    //       name: this.patchName
    //     }
    //   })
    //   .then(result => {
    //     console.log('result', result)
    //     // this.$router.
    //   })
    //   .catch(error => {
    //     alert ('ERROR')
    //     console.log(error)
    //   })
    },
    cancel () {
      this.$router.go(-1)
    }
  },
  apollo: {
  },
  data () {
    return {
      patchName: ''
    }
  },
}
</script>