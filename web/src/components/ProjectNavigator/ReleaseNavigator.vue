<template>
  <div>
    <v-toolbar>
    <v-text-field
      label="Release"
      :value="focusRelease.number"
    ></v-text-field>
      <v-btn @click="explore">Explore</v-btn>
    </v-toolbar>
    <v-toolbar>
      <v-btn @click="newPatch" :disabled="newPatchSetDisabled">New Minor</v-btn>
    </v-toolbar>
    <minor-list></minor-list>
  </div>
</template>

<script>
import MinorList from './MinorList'
import pdeProjectById from '../../gql/query/pdeProjectById.gql'

export default {
  name: "ReleaseNavigator",
  components: {
    MinorList
  },
  methods: {
    newPatch () {
      this.$eventHub.$emit('newMinor', this.focusRelease)      
    },
    explore () {
      this.$eventHub.$emit('exploreRelease', this.focusRelease)
    }
  },
  computed: {
    focusRelease () {
      return (this.releases.find(r => r.id === this.$store.state.focusReleaseId) || {})
    },
    releaseStatus () {
      return this.focusRelease ? this.focusRelease.status : 'N/A'
    },
    newPatchSetDisabled () {
      return this.focusRelease.id ? this.focusRelease.locked === true : true
    },
    selectedProjectId () {
      return this.$store.state.selectedProjectId
    }
  },
  watch: {
    selectedProjectId () {
      this.$apollo.queries.init.refetch()
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: this.selectedProjectId
        }
      },
      fetchPolicy: 'network-only',
      skip () {
        return this.selectedProjectId === ''
      },
      update (result) {
        this.pdeProject = result.pdeProjectById || {
          releases: {
            nodes: []
          }
        }
        this.releases = this.pdeProject.releases.nodes.map(
          release => {
            return Object.assign({
              displayName: `${release.number} - ${release.name}`
            }, release)
          }
        )
      }
    }
  },
  props: {
    pdeProjectId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      releases: [],
      pdeProject: null
    }
  }
}
</script>
