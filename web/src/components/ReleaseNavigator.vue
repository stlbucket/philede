<template>
  <div>
    <v-toolbar>
      <v-btn @click="newRelease">New</v-btn>
      <v-select 
        :label="`Release - ${releaseStatus}`"
        :items="releases"
        item-text="displayName"
        item-value="id"
        v-model="selectedReleaseId"
      ></v-select>
    </v-toolbar>
    <minor-list
      :releaseId="selectedReleaseId"
    ></minor-list>
  </div>
</template>

<script>
import MinorList from './MinorList'
import pdeProjectById from '../gql/query/pdeProjectById.gql'

export default {
  name: "ReleaseNavigator",
  components: {
    MinorList
  },
  methods: {
    newRelease () {
      this.$router.push({ name: 'newRelease' })
    }
  },
  computed: {
    selectedRelease () {
      return (this.releases.find(r => r.id === this.selectedReleaseId) || {})
    },
    releaseStatus () {
      return this.selectedRelease ? this.selectedRelease.status : 'N/A'
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
      networkPolicy: 'fetch-only',
      skip () {
        return this.pdeProjectId === ''
      },
      update (result) {
        this.pdeProject = result.pdeProjectById
        this.releases = this.pdeProject.releases.nodes.map(
          release => {
            return Object.assign({
              displayName: `${release.name}`
            }, release)
          }
        )
        this.selectedReleaseId = (this.releases[0] || {id: ''}).id
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
      selectedReleaseId: '',
      pdeProject: null
    }
  },
}
</script>
