<template>
  <div>
    <h1>New Patch</h1>
    <hr/>
    <h2>Minor Version: {{ minor.number }}</h2>
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

    <div :hidden="nameArtifactHidden">
      <h2>Name new {{ artifactTypeName }}:</h2>
      <v-text-field
        :label="artifactNameLabel"
        v-model="artifactName"
      ></v-text-field>
    </div>

      <h2>Template Fields</h2>
      <template v-for="field in templateFields">
        <v-text-field
          :key="field"
          :label="field"
          :disabled="templateFieldDisabled(field)"
          v-model="templateFieldValues[field]"
        ></v-text-field>
      </template>

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
import patchNewInit from '../../gql/query/patchNewInit.gql'
import createArtifact from '../../gql/mutation/createArtifact.gql'
import createPatch from '../../gql/mutation/createPatch.gql'
import createSchema from '../../gql/mutation/createSchema.gql'

export default {
  name: "NewPatch",
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
    createDisabled () {
      const allTemplateFieldsFilled = this.templateFields.reduce(
        (acc,field) => {
          return acc === false ? false : (this.templateFieldValues[field] !== null && this.templateFieldValues[field] !== undefined)
      }, true)

      const artifactIdentified = (this.selectedPatchType || {}).action === 'CREATE' ? this.artifactName !== '' : this.selectedArtifact !== null

      return !artifactIdentified || !allTemplateFieldsFilled
    },
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
    nameArtifactHidden () {
      return this.selectedPatchType ? this.selectedPatchType.action !== 'CREATE' : true
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
    },
    templateFields () {
      return this.selectedPatchType ? Array.from(new Set(this.selectedPatchType.ddlUpTemplate.split('{{').filter(s => s.indexOf('}}') > -1).map(s => s.substring(0, s.indexOf('}}'))))) : []
    }
  },
  methods: {
    createSchema () {
      const variables = {
          projectId: this.minor.project.id,
          name: this.artifactName
        }
      return this.$apollo.mutate({
        mutation: createSchema,
        variables: variables
      })
      .then(result => {
        console.log('schema result', result)
        return result.data.createSchema.schema
      })
      .catch(error => {
        alert ('ERROR')
        console.log(error)
      })
    },
    createArtifact (schema) {
      console.log('schema', schema)
      const variables = {
          projectId: this.minor.project.id,
          schemaId: schema.id,
          name: this.artifactName,
          description: 'tacos',
          artifactTypeId: this.selectedArtifactType.id
        }

      return this.$apollo.mutate({
        mutation: createArtifact,
        variables: variables
      })
      .then(result => {
        return result.data.createArtifact.artifact
      })
      .catch(error => {
        alert ('ERROR')
        console.log(error)
      })
    },
    createPatch (artifact) {
      return this.$apollo.mutate({
        mutation: createPatch,
        variables: {
          projectId: this.minor.project.id,
          patchTypeId: this.selectedPatchType.id,
          minorId: this.minor.id,
          artifactId: artifact.id,
          ddlUp: this.ddlUp,
          ddlDown: this.ddlDown
        }
      })
      .then(result => {
        return result.data.createPatch.patch
      })
      .catch(error => {
        alert ('ERROR')
        console.log(error)
      })
    },
    create () {
      if (this.selectedPatchType.action === 'CREATE' && this.selectedArtifactType.name.toLowerCase() === 'schema') {
        return this.createSchema()
          .then(schema => {
            return this.createArtifact(schema)
          })
          .then(artifact => {
            return this.createPatch(artifact)
          })
          .then(patch => {
            this.$store.commit('focusPatchId', { focusPatchId: result.data.createPatch.patch.id })
          })
          .catch(error => {
            alert ('ERROR')
            console.log('ERROR', error)
          })
      } else if (this.selectedPatchType.action === 'CREATE' && this.selectedArtifactType.name.toLowerCase !== 'schema') {
        return this.createArtifact(this.selectedSchema)
          .then(artifact => {
            return this.createPatch(artifact)
          })
          .then(patch => {
            this.$store.commit('focusPatchId', { focusPatchId: result.data.createPatch.patch.id })
          })
          .catch(error => {
            alert ('ERROR')
            console.log('ERROR', error)
          })

      } else {
        return this.createPatch(this.selectedArtifact)
          .then(patch => {
            console.log('new patch', patch)
          })
          .catch(error => {
            alert ('ERROR')
            console.log('ERROR', error)
          })
      }
    },
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
    calculateDdlUp () {
      this.ddlUp = this.templateFields.reduce(
        (template, fieldName) => {
          const enteredValue = this.templateFieldValues[fieldName]
          const value = enteredValue === enteredValue.toLowerCase() ? enteredValue : `"${enteredValue}"`
          return template.split(`{{${fieldName}}}`).join(value)
        }, this.selectedPatchType.ddlUpTemplate
      ) 
    },
    calculateDdlDown () {
      this.ddlDown = this.templateFields.reduce(
        (template, fieldName) => {
          const enteredValue = this.templateFieldValues[fieldName]
          const value = enteredValue === enteredValue.toLowerCase() ? enteredValue : `"${enteredValue}"`
          return template.split(`{{${fieldName}}}`).join(value)
        }, this.selectedPatchType.ddlDownTemplate
      ) 
    },
    calculateDdl () {
      this.calculateDdlUp()
      this.calculateDdlDown()
    },
    templateFieldChanged () {
      this.calculateDdl()
    },
    templateFieldDisabled (field) {
      return field === `${this.selectedArtifactType.name}Name`
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
    },
    artifactName () {
      this.templateFieldValues[`${this.selectedArtifactType.name}Name`] = this.artifactName
      this.calculateDdl()
    },
    templateFieldValues: {
      handler (val) {
        this.calculateDdl()
      },
      deep: true
    } 
  },
  apollo: {
    init: {
      fetchPolicy: 'network-only',
      query: patchNewInit,
      variables () {
        return {
          minorId: this.minorId
        }
      },
      update (data) {
        this.artifactTypes = data.allArtifactTypes.nodes
        this.minor = data.minorById
        this.schemata = this.minor ? this.minor.project.schemata.nodes : []
      }
    }
  },
  data () {
    return {
      ddlUp: 'N/A',
      ddlDown: 'N/A',
      minor: {
        schemata: {
          nodes: []
        },
        project: {
          artifacts: {
            nodes: []
          }
        }
      },
      schemata: [],
      patchName: '',
      selectedArtifactTypeId: '',
      selectedPatchTypeId: '',
      selectedSchemaId: '',
      selectedArtifactId: '',
      artifactName: '',
      artifactTypes: [],
      patchTypes: [],
      artifacts: [],
      templateFieldValues: {}
    }
  }
}
</script>