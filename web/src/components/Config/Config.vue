<template>
  <div>
    <v-tabs
      dark
      slider-color="yellow"
      :hidden="hidden"
    >
      <v-tab
        key="dev-deployment-status"
        ripple
      >
        Dev Deployment Status
      </v-tab>
      <v-tab-item
        key="dev-deployment-status"
      >
      <v-toolbar>NOT IMPLEMENTED</v-toolbar>
      </v-tab-item>
      <v-tab
        key="patch-templates"
        ripple
      >
        Patch Templates
      </v-tab>
      <v-tab-item
        key="patch-templates"
      >
        <patch-template></patch-template>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import PatchTemplate from './PatchTemplate'

export default {
  name: "Config",
  components: {
    PatchTemplate
  },
  props: {
  },
  methods: {
    save () {
    },
    revert () {
    }
  },
  // apollo: {
  //   loadArtifact: {
  //     fetchPolicy: 'network-only',
  //     query: artifactById,
  //     variables () {
  //       return {
  //         id: this.artifactId
  //       }
  //     },
  //     update (data) {
  //       this.artifact = data.artifactById
  //     }
  //   }
  // },
  // computed: {
  //   artifactId () {
  //     // console.log('this.$store.state.focusArtifactId', this.$store.state.focusArtifactId)
  //     // return this.$store.state.focusArtifactId
  //     return this.id
  //   },
  //   artifactName () {
  //     return this.artifact ? this.artifact.name : 'N/A'
  //   },
  //   artifactTypeName () {
  //     return this.artifact ? this.artifact.artifactType.name : 'N/A'
  //   }
  // },
  data () {
    return {
    }
  }
}
</script>


</style>
