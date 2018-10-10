<template>
  <v-layout justify-left>
    <v-flex xs12 sm10>
      <h1>Release Manager</h1>
      <hr/>
      <h2>Current</h2>
      <v-toolbar>
        <v-toolbar-title>{{ releaseDisplay(currentRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(currentRelease)">
          <v-btn @click="explore(currentRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Staging</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(stagingRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(stagingRelease)">
          <v-btn @click="releaseToCurrent(stagingRelease)">Complete</v-btn>
          <v-btn @click="explore(stagingRelease)">Explore</v-btn>
        </div>
      </v-toolbar>

      <h2>Testing</h2>
      <v-toolbar dark>
        <v-toolbar-title>{{ releaseDisplay(testingRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(testingRelease)">
          <v-btn @click="releaseToStaging(testingRelease)">Move to Staging</v-btn>
          <v-btn @click="explore(testingRelease)">Explore</v-btn>
        </div>
      </v-toolbar>
<hr/>
      <h2>Development</h2>
      <v-toolbar dark>
        <v-toolbar-title> {{ releaseDisplay(developmentRelease) }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <div v-if="showExplore(developmentRelease)">
          <v-btn @click="releaseToTesting(developmentRelease)">Release to Testing</v-btn>
          <v-btn @click="stashRelease">Stash</v-btn>
          <v-btn @click="explore(developmentRelease)">Explore</v-btn>
        </div>
        <div v-else>
          <v-btn @click="newDevelopmentRelease">New Development Release</v-btn>
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

      <hr/>
      <h2>Historic</h2>
      <v-list
        v-for="(release) in historicReleases"
        :key="release.id"
      >
        <v-toolbar dark>
          <v-toolbar-title>{{ releaseDisplay(release) }}</v-toolbar-title>
        </v-toolbar>
      ></v-list>

      <hr/>
      <h2>Archived</h2>
      <v-list
        v-for="(release) in archivedReleases"
        :key="release.id"
      >
        <v-toolbar dark>
          <v-toolbar-title>{{ releaseDisplay(release) }}</v-toolbar-title>
        </v-toolbar>
      ></v-list>

      <h2>Test Deprecated</h2>
      <v-list
        v-for="(release) in testingDeprecatedReleases"
        :key="release.id"
      >
        <v-toolbar dark>
          <v-toolbar-title>{{ releaseDisplay(release) }}</v-toolbar-title>
          <v-spacer></v-spacer>
            <v-btn @click="explore(release)">Explore</v-btn>
        </v-toolbar>
      ></v-list>

      <h2>Staging Deprecated</h2>
      <v-list
        v-for="(release) in stagingDeprecatedReleases"
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
// import Release from './Release'
import releaseToTesting from '../../gql/mutation/releaseToTesting.gql'
import releaseToStaging from '../../gql/mutation/releaseToStaging.gql'
import releaseToCurrent from '../../gql/mutation/releaseToCurrent.gql'

export default {
  name: "ReleaseManager",
  components: {
    // Release
  },
  methods: {
    releaseToCurrent(release) {
      this.$apollo.mutate({
        mutation: releaseToCurrent,
        variables: {
          projectId: release.projectId
        }
      })
      .then(result => {
        this.$eventHub.$emit('releaseToCurrent', result.data.releaseToCurrent.release)
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    },
    releaseToTesting(release) {
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
    releaseToStaging(release) {
      this.$apollo.mutate({
        mutation: releaseToStaging,
        variables: {
          projectId: release.projectId
        }
      })
      .then(result => {
        console.log('result', result)
        this.$eventHub.$emit('releaseToStaging', result.data.releaseToStaging.release)
      })
      .catch(error => {
        alert('ERROR')
        console.log(error)
      })
    },
    newDevelopmentRelease () {
      this.$eventHub.$emit('newDevelopmentRelease')
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
      this.$store.commit('focusReleaseId', { focusReleaseId: release.id })
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
    currentRelease () {
      return this.releases.find(r => r.status === 'CURRENT')
    },
    historicReleases () {
      return this.releases.filter(r => r.status === 'HISTORIC')
    },
    archivedReleases () {
      return this.releases.filter(r => r.status === 'ARCHIVED')
    },
    testingDeprecatedReleases () {
      return this.releases.filter(r => r.status === 'TESTING_DEPRECATED')
    },
    stagingDeprecatedReleases () {
      return this.releases.filter(r => r.status === 'STAGING_DEPRECATED')
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
