<template>
  <v-layout justify-left>
    <v-flex xs12 sm10>
      <h1>Release Manager</h1>
      <hr/>
      <h2>Latest</h2>
      <v-toolbar>
        <v-toolbar-title>{{ releaseDisplay(latestRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(latestRelease)">
          <v-btn @click="explore(latestRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Staging</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(stagingRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(stagingRelease)">
          <v-btn @click="completeRelease">Complete</v-btn>
          <v-btn @click="explore(stagingRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Testing</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(testingRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(testingRelease)">
          <v-btn @click="completeRelease">Move to Staging</v-btn>
          <v-btn @click="explore(testingRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Development</h2>
      <v-toolbar dark>
        <v-toolbar-title> {{ releaseDisplay(developmentRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(developmentRelease)">
          <v-btn @click="releaseToTesting(developmentRelease)">Release to Testing</v-btn>
          <v-btn @click="stashRelease">Stash</v-btn>
          <v-btn @click="explore(developmentRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Stashed</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(stashedRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(stashedRelease)">
          <v-btn @click="unstashRelease">Unstash</v-btn>
          <v-btn @click="explore(stashedRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Future</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(futureRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn @click="explore(futureRelease)">Explore</v-btn>
      </v-toolbar>

      <h2>Historic</h2>
      <v-list
        v-for="(release) in historicReleases"
        :key="release.id"
      >
        <v-toolbar dark>
          <v-toolbar-title>{{ release }}</v-toolbar-title>
        </v-toolbar>
      ></v-list>

      <h2>Deprecated</h2>
      <v-list
        v-for="(release) in deprecatedReleases"
        :key="release.id"
      >
        <v-toolbar dark>
          <v-toolbar-title>{{ releaseDisplay(release) }}</v-toolbar-title>
          <v-spacer></v-spacer>
            <v-btn @click="explore(release)">Explore</v-btn>
        </v-toolbar>
      ></v-list>
    </v-flex>
  </v-layout>
</template>

<script>
import Release from './Release'
import releaseToTesting from '../../gql/mutation/releaseToTesting.gql'

export default {
  name: "ReleaseManager",
  components: {
    Release
  },
  methods: {
    completeRelease() {

    },
    releaseToTesting(release) {
      console.log('release me', release)
      this.$apollo.mutate({
        mutation: releaseToTesting,
        variables: {
          projectId: release.projectId
        }
      })
      .then(result => {
        this.$eventHub.$emit('releaseToTesting', result.data.releaseToTesting.release)
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    },
    stashRelease () {

    },
    unstashRelease () {

    },
    releaseDisplay (release) {
      return release ? `${release.number}  --  ${release.name}` : `slot empty`
    },
    showExplore (release) {
      return release ? true : false
    },
    explore (release) {
      this.$eventHub.$emit('exploreRelease', release)
    }
  },
  computed: {
    stagingRelease () {
      return this.releases.find(r => r.status === 'STAGING')
    },
    testingRelease () {
      return this.releases.find(r => r.status === 'TESTING')
    },
    developmentRelease () {
      return this.releases.find(r => r.status === 'DEVELOPMENT')
    },
    stashedRelease () {
      return this.releases.find(r => r.status === 'STASHED')
    },
    futureRelease () {
      return this.releases.find(r => r.status === 'FUTURE')
    },
    latestRelease () {
      return this.releases.find(r => r.status === 'LATEST')
    },
    historicReleases () {
      return this.releases.filter(r => r.status === 'HISTORIC')
    },
    deprecatedReleases () {
      return this.releases.filter(r => r.status === 'DEPRECATED')
    },
    developmentHistoricReleases () {
      return this.releases.filter(r => r.status === 'STAGING_HISTORIC')
    }
  },
  watch: {
  },
  props: {
    releases: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      stagingPresent: false
    }
  }
}
</script>
