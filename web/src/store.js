import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    selectedProjectId: '',
    focusReleaseId: '',
    focusArtifactId: ''
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
    }
  },
  actions: {

  },
  getters: {
  },
  plugins: [createPersistedState()]
})
