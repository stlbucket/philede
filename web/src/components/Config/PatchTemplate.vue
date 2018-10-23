<template>
  <div>
    <h1>Patch Template</h1>
    <hr/>
    <h2>Select an artifact type:</h2>
    <v-radio-group 
      v-model="selectedArtifactTypeId"
      :column="false"
    >
      <v-radio
        v-for="artifactType in artifactTypes"
        :key="artifactType.id"
        :label="`${artifactType.name}`"
        :value="artifactType.id"
      ></v-radio>
    </v-radio-group>

    <div :hidden="patchTypeHidden">
      <h2>Select a patch type:</h2>
      <a :href="documentationUrl" target="_blank"><h2>{{ documentationLinkName }}</h2></a>
      <v-radio-group 
        v-model="selectedPatchTypeId"
        :column="false"
      >
        <v-radio
          v-for="patchType in patchTypes"
          :key="patchType.id"
          :label="`${patchType.name}`"
          :value="patchType.id"
        ></v-radio>
      </v-radio-group>
      
    </div>

    <v-toolbar>
      <v-btn @click="save" :disabled="saveDisabled">Save</v-btn>
      <v-btn @click="cancel">Cancel</v-btn>
    </v-toolbar>

    <div :hidden="editorHidden">
      <editor
        ref="editorUp" 
        v-model="ddlUp" 
        @init="editorInit" 
        lang="pgsql" 
        theme="tomorrow_night_bright"
        width="100%" 
        height="400"
        readonly="true"
      ></editor>
      <hr/>
      <editor
        ref="editorDown" 
        v-model="ddlDown" 
        @init="editorInit" 
        lang="pgsql" 
        theme="tomorrow_night_bright"
        width="100%" 
        height="400"
        readonly="true"
      ></editor>
    </div>

  </div>
</template>

<script>
import patchTemplateInit from '../../gql/query/patchTemplateInit.gql'

export default {
  name: "PatchTemplate",
  components: {
    editor: require('vue2-ace-editor'),
  },
  props: {
    minorId: {
      type: String,
      require: true
    }
  },
  computed: {
    saveDisabled () {
      return false
    },
    selectedArtifactType() {
      return this.artifactTypes.find(at => at.id === this.selectedArtifactTypeId)
    },
    selectedPatchType() {
      return this.selectedArtifactType ? this.selectedArtifactType.patchTypes.nodes.find(pt => pt.id === this.selectedPatchTypeId) : null
    },
    action () {
      return this.selectedPatchType ? this.selectedPatchType.action : 'NONE'
    },
    patchTypeHidden () {
      return this.selectedArtifactType === null || this.selectedArtifactType === undefined
    },
    selectArtifactHidden () {
      return this.selectedSchemaId === '' || this.selectedArtifactType.requiresSchema === false || this.selectedPatchType.action === 'CREATE'
    },
    selectArtifactLabel () {
      return this.selectedArtifactType ? 
        (this.selectedArtifactId === '' ? `Select an existing ${this.selectedArtifactType.name}` : `Selected ${this.selectedArtifactType.name}`) 
        : ''
    },
    artifactTypeName () {
      return this.selectedArtifactType ? this.selectedArtifactType.name : ''
    },
    editorHidden() {
      return false // this.artifactName === ''
    },
    documentationLinkName () {
      return this.selectedPatchType ? `${this.selectedPatchType.name} documentation` : ''
    },
    documentationUrl () {
      return this.selectedPatchType ? this.selectedPatchType.documentationUrl : ''
    }
  },
  methods: {
    save () {

    },
    cancel () {
      this.$router.go(-1)
    },
    editorInit: function () {
        require('brace/ext/language_tools') //language extension prerequsite...
        require('brace/mode/html')                
        require('brace/mode/javascript')    //language
        require('brace/mode/less')
        require('brace/theme/chrome')
        require('brace/snippets/javascript') //snippet
        require('brace/mode/pgsql')
        require('brace/theme/tomorrow_night_bright')
    },
    calculateDdl () {
      this.ddlUp = this.selectedPatchType.ddlUpTemplate
      this.ddlDown = this.selectedPatchType.ddlDownTemplate
    }
  },
  watch: {
    selectedArtifactTypeId () {
      this.patchTypes = this.selectedArtifactType.patchTypes.nodes
      this.selectedPatchTypeId = this.selectedArtifactType.patchTypes.nodes[0].id
      this.selectedArtifactId = ''
    },
    selectedArtifactId () {
      if (this.selectedArtifact) this.templateFieldValues[`${this.selectedArtifact.artifactType.name}Name`] = this.selectedArtifact.name
      this.calculateDdl()
    },
    selectedPatchTypeId () {
      this.calculateDdl()
    },
    selectedSchemaId () {
      this.calculateDdl()
    }
  },
  apollo: {
    init: {
      fetchPolicy: 'network-only',
      query: patchTemplateInit,
      update (data) {
        this.artifactTypes = data.allArtifactTypes.nodes
      }
    }
  },
  data () {
    return {
      ddlUp: 'N/A',
      ddlDown: 'N/A',
      patchName: '',
      selectedArtifactTypeId: '',
      selectedPatchTypeId: '',
      selectedSchemaId: '',
      selectedArtifactId: '',
      artifactTypes: [],
      patchTypes: []
    }
  }
}
</script>
