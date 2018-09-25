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
          projectId: this.projectId,
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
    // schemas () {
    //   if (this.project) {
    //     const schemas = this.project.releases.nodes.reduce(
    //       (acc, release) => {
    //         return acc.concat(release.minors.nodes.reduce(
    //           (acc, minor) => {
    //             return acc.concat(minor.patches.nodes.reduce(
    //               (acc, patch) => {
    //                 const schema = acc.find(s => s.id === patch.artifact.schema.id)
    //                 if (schema) {
    //                   return acc
    //                 } else {
    //                   return acc.concat([patch.artifact.schema])
    //                 }
    //               }, []
    //             ))
    //           }, []
    //         ))
    //       }, []
    //     ).reduce(
    //       (acc, schema) => {
    //         const existing = acc.find(s => s.id === schema.id)
    //         if (existing) {
    //           return acc
    //         } else {
    //           return acc.concat([schema])
    //         }
    //       }, []
    //     )
    //     return schemas
    //   } else {
    //     return []
    //   }
    // }
  },
  props: {
    projectId: {
      type: String,
      required: true
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.projectId
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
