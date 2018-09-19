<template>
  <div>
    <h1>Project: {{ project.name }}</h1>
    <v-btn @click="save" :disabled="saveDisabled">Save</v-btn>
    <release-manager
      :releases="releases"
    ></release-manager>
  </div>
</template>

<script>
import pdeProjectById from '../../gql/query/pdeProjectById.gql'
import ReleaseManager from './ReleaseManager'

export default {
  name: "ProjectDetail",
  components: {
    ReleaseManager
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
    },
    releases () {
      return this.project.releases.nodes
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
        console.log('pdeProject result', result)
        this.project = result.pdeProjectById
        this.projectName = this.project.name
        this.$eventHub.$emit('projectFocus', this.project.id)
      }
    }
  },
  data () {
    return {
      projectName: '',
      project: {
        releases: {
          nodes: []
        }
      }
    }
  },
}
</script>