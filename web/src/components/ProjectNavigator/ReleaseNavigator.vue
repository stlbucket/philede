<template>
  <div>
    <v-toolbar>
      <h3>{{ selectedRelease.number }}</h3>
      <v-btn @click="newPatch">New Patch Set</v-btn>
    </v-toolbar>
    <minor-list
      :releaseId="selectedReleaseId"
    ></minor-list>
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
      this.$eventHub.$emit('newMinor', this.selectedRelease)      
    }
  },
  computed: {
    selectedRelease () {
      return (this.releases.find(r => r.id === this.selectedReleaseId) || {})
    },
    releaseStatus () {
      return this.selectedRelease ? this.selectedRelease.status : 'N/A'
    },
    newPatchSetDisabled () {
      return this.selectedRelease ? this.selectedRelease.locked : true
    }
  },
  watch: {
    focusReleaseId () {
      this.selectedReleaseId = this.focusReleaseId
    }
  },
  apollo: {
    init: {
      query: pdeProjectById,
      variables () {
        return {
          id: `${this.pdeProjectId}`
        }
      },
      fetchPolicy: 'network-only',
      skip () {
        return this.pdeProjectId === ''
      },
      update (result) {
        this.pdeProject = result.pdeProjectById
        this.releases = this.pdeProject.releases.nodes.map(
          release => {
            return Object.assign({
              displayName: `${release.number} - ${release.name}`
            }, release)
          }
        )
        this.selectedReleaseId = this.focusReleaseId ? this.focusReleaseId : ''
        this.selectedReleaseId = this.selectedReleaseId !== '' ? this.selectedReleaseId : (this.releases.find(r => r.status === 'DEVELOPMENT') || {id: ''}).id
        console.log('this.sel', this.selectedReleaseId)
      }
    }
  },
  props: {
    pdeProjectId: {
      type: String,
      required: true
    },
    focusReleaseId: String
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      releases: [],
      selectedReleaseId: '',
      pdeProject: null
    }
  },
}
</script>
