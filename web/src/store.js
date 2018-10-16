import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    focusProjectId: '',
    focusReleaseId: '',
    focusSchemaId: '',
    focusArtifactTypeId: '',
    focusArtifactId: '',
    focusPatchId: ''
  },
  mutations: {
    focusProjectId (state, payload) {
      state.focusProjectId = payload.focusProjectId
      state.focusSchemaId = ''
      state.focusArtifactTypeId = ''
      state.focusArtifactId = ''
      state.focusPatchId = ''
    },
    focusReleaseId (state, payload) {
      state.focusReleaseId = payload.focusReleaseId
      state.focusSchemaId = ''
      state.focusArtifactTypeId = ''
      state.focusArtifactId = ''
      state.focusPatchId = ''
    },
    focusSchemaId (state, payload) {
      state.focusSchemaId = payload.focusSchemaId
      state.focusArtifactTypeId = ''
      state.focusArtifactId = ''
      state.focusPatchId = ''
    },
    focusArtifactTypeId (state, payload) {
      state.focusArtifactId = ''
      state.focusPatchId = ''
      state.focusArtifactTypeId = payload.focusArtifactTypeId
    },
    focusArtifactId (state, payload) {
      state.focusSchemaId = ''
      state.focusArtifactTypeId = ''
      state.focusPatchId = ''
      state.focusArtifactId = payload.focusArtifactId
    },
    focusPatchId (state, payload) {
      state.focusSchemaId = ''
      state.focusArtifactTypeId = ''
      state.focusArtifactId = ''
      state.focusPatchId = payload.focusPatchId
    }
  },
  actions: {

  },
  getters: {
  },
  plugins: [createPersistedState()]
})
