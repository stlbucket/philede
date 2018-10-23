<template>
  <div>
    <h1>Export Project: {{ projectName }}</h1>
      <v-toolbar>
        <v-btn @click="saveFile">Save</v-btn>
      </v-toolbar>
      <v-textarea
        :value="projectJson"
        auto-grow
        readonly
      ></v-textarea>
  </div>
</template>

<script>
import exportProjectById from '../../gql/query/exportProjectById.gql'

export default {
  name: "ExportProject",
  components: {
  },
  props: {
  },
  computed: {
    projectName () {
      return this.project ? this.project.name : 'N/A'
    },
    projectJson () {
      return this.project ? JSON.stringify({
        artifactTypes: this.artifactTypes,
        project: this.project
      }, null, 2) : 'N/A'
    }
  },
  methods: {
    saveFile: function() {
        const data = this.projectJson
        const blob = new Blob([data], {type: 'text/plain'})
        const e = document.createEvent('MouseEvents'),
        a = document.createElement('a');
        a.download = `${this.project.name}-${this.project.id}.json`;
        a.href = window.URL.createObjectURL(blob);
        a.dataset.downloadurl = ['text/json', a.download, a.href].join(':');
        e.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        a.dispatchEvent(e);
    }
  },
  apollo: {
    init: {
      query: exportProjectById,
      variables () {
        return {
          id: this.$store.state.focusProjectId
        }
      },
      fetchPolicy: 'network-only',
      update (result) {
        this.project = result.pdeProjectById || {
        releases: {
          nodes: []
          }
        }
        this.artifactTypes = result.allArtifactTypes.nodes
      }
    }
  },
  data () {
    this.$store.commit('clearFocus')
    return {
      file: '',
      artifactTypes: [],
      project: {
        releases: {
          nodes: []
        }
      }
    }
  }
}
</script>