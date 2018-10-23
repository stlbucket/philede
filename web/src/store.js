import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedFocus from 'vuex-persistedstate'

Vue.use(Vuex)

function doClearFocus(state){
  state.focusSchemaId = ''
  state.focusArtifactTypeId = ''
  state.focusArtifactId = ''
  state.focusMinorId = ''
  state.focusPatchId = ''
}

export default new Vuex.Store({
  state: {
    focusProjectId: '',
    focusReleaseId: '',
    focusSchemaId: '',
    focusArtifactTypeId: '',
    focusArtifactId: '',
    focusPatchId: '',
    focusMinorId: ''
  },
  mutations: {
    clearFocus(state){
      doClearFocus(state)
    },
    focusProjectId (state, payload) {
      doClearFocus(state)
      state.focusProjectId = payload.focusProjectId
    },
    focusReleaseId (state, payload) {
      doClearFocus(state)
      state.focusReleaseId = payload.focusReleaseId
    },
    focusSchemaId (state, payload) {
      doClearFocus(state)
      state.focusSchemaId = payload.focusSchemaId
    },
    focusArtifactTypeId (state, payload) {
      doClearFocus(state)
      state.focusArtifactTypeId = payload.focusArtifactTypeId
    },
    focusArtifactId (state, payload) {
      doClearFocus(state)
      state.focusArtifactId = payload.focusArtifactId
    },
    focusPatchId (state, payload) {
      doClearFocus(state)
      state.focusPatchId = payload.focusPatchId
    },
    focusMinorId (state, payload) {
      doClearFocus(state)
      state.focusMinorId = payload.focusMinorId
    }
  },
  actions: {

  },
  getters: {
  },
  plugins: [createPersistedFocus()]
})
