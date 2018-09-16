<template>
  <div>
    <h1>Project</h1>
    <v-text-field
      v-model="projectName"
    ></v-text-field>
    <v-btn @click="save" :disabled="saveDisabled">Save</v-btn>
  </div>
</template>

<script>
import pdeProjectById from '../gql/query/pdeProjectById.gql'

export default {
  name: "ProjectDetail",
  components: {
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  computed: {
    saveDisabled () {
      return this.projectName === this.project.name
    }
  },
  methods: {
    save () {
      // this.$apollo.query({
      //   query: pdeProjectById,
      //   variables: {
      //     id: this.id
      //   }
      // })
      // .then(result => {
      //   console.log('result', result)
      //   // this.$router.
      // })
      // .catch(error => {
      //   alert ('ERROR')
      //   console.log(error)
      // })
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.id
        }
      },
      skip () {
        return this.id === ''
      },
      update (result) {
        this.project = result.pdeProjectById
        this.projectName = this.project.name
        this.$eventHub.$emit('projectFocus', this.project.id)
      }
    }
  },
  data () {
    return {
      projectName: '',
      project: {}
    }
  },
}
</script>