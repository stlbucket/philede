import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    selectedProjectId: '',
    focusReleaseId: '',
    focusArtifactId: '',
    focusPatchId: ''
  },
  mutations: {
    selectedProjectId (state, payload) {
      state.selectedProjectId = payload.projectId
    },
    focusReleaseId (state, payload) {
      state.focusReleaseId = payload.releaseId
    },
    focusArtifactId (state, payload) {
      state.focusArtifactId = payload.focusArtifactId
    },
    focusPatchId (state, payload) {
      state.focusPatchId = payload.focusPatchId
    }
  },
  actions: {

  },
  getters: {
  },
  plugins: [createPersistedState()]
})
