<template>
  <div>
    <v-toolbar>
      <v-select 
        :label="`Release - ${releaseStatus}`"
        :items="releases"
        item-text="displayName"
        item-value="id"
        v-model="selectedReleaseId"
      ></v-select>
      <v-btn @click="newSchema">New Schema</v-btn>
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
    newSchema () {
      this.$eventHub.$emit('newSchema', this.selectedRelease)
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
