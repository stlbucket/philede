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

    <div :hidden="schemataHidden">
      <h2>Select a schema :</h2>
      <v-radio-group 
        v-model="selectedSchemaId"
        :column="false"
      >
        <v-radio
          v-for="schema in schemata"
          :key="schema.id"
          :label="`${schema.name}`"
          :value="schema.id"
        ></v-radio>
      </v-radio-group>
    </div>

    <div :hidden="selectArtifactHidden">
      <h2>Select existing {{ artifactTypeName }}:</h2>
      <v-select
        :label="selectArtifactLabel" 
        :items="artifacts"
        item-text="name"
        item-value="id"
        v-model="selectedArtifactId"
      ></v-select>
    </div>

    <v-toolbar>
      <v-btn @click="create" :disabled="createDisabled">Create</v-btn>
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
    selectedArtifactType() {
      return this.artifactTypes.find(at => at.id === this.selectedArtifactTypeId)
    },
    selectedArtifact() {
      return this.minor.project.artifacts.nodes.find(a => a.id === this.selectedArtifactId)
    },
    selectedPatchType() {
      return this.selectedArtifactType ? this.selectedArtifactType.patchTypes.nodes.find(pt => pt.id === this.selectedPatchTypeId) : null
    },
    selectedSchema () {
      return this.selectedSchemaId !== '' ? this.minor.project.schemata.nodes.find(s => s.id === this.selectedSchemaId) : { name: 'N/A' }
    },
    action () {
      return this.selectedPatchType ? this.selectedPatchType.action : 'NONE'
    },
    patchTypeHidden () {
      return this.selectedArtifactType === null || this.selectedArtifactType === undefined
    },
    schemataHidden () {
      return this.selectedArtifactType ? this.selectedArtifactType.requiresSchema === false : true
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
    specificPatchTypeHidden (patchType) {
      return patchType.action === 'CREATE' ? false : this.artifacts.length === 0
    },
    documentationLinkName () {
      return this.selectedPatchType ? `${this.selectedPatchType.name} documentation` : ''
    },
    documentationUrl () {
      return this.selectedPatchType ? this.selectedPatchType.documentationUrl : ''
    },
    artifactNameLabel () {
      return this.selectedArtifactType ? `New ${this.selectedArtifactType.name} name` : ''
    }
  },
  methods: {
    cancel () {
      this.$router.go(-1)
    },
    filterforArtifactsInSchema () {
      this.artifacts = this.minor.project.artifacts.nodes.filter(a => a.schema.id === this.selectedSchemaId && a.artifactType.id === this.selectedArtifactTypeId)
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
      this.artifacts = []
      this.selectedPatchTypeId = this.selectedArtifactType.patchTypes.nodes[0].id
      this.selectedSchemaId = this.minor.project.schemata.nodes.length > 1 ? '' : (this.minor.project.schemata.nodes[0] || {}).id
      this.selectedArtifactId = ''
      this.artifactName = ''
      this.filterforArtifactsInSchema()
    },
    selectedArtifactId () {
      if (this.selectedArtifact) this.templateFieldValues[`${this.selectedArtifact.artifactType.name}Name`] = this.selectedArtifact.name
      this.calculateDdl()
    },
    selectedPatchTypeId () {
      this.calculateDdl()
    },
    selectedSchemaId () {
      this.templateFieldValues[`schemaName`] = (this.selectedSchema || {name: 'N/A'}).name
      this.filterforArtifactsInSchema()
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
