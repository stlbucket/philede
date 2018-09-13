<template>
  <div>
    <p>FOCUS: {{ focusArtifactId }}</p>
    <v-btn 
      @click="newArtifact"
      :disabled="disableNew"
    >New
    </v-btn>
    <v-treeview
      :items="items"
      caption-field="name"
      children-field="children"
      expand-all
      select
      v-model="selectedItems"
    />
  </div>
</template>

<script>
import initQuery from './initQuery.gql'

export default {
  name: "ProjectTree",
  methods: {
    newArtifact() {
      alert('new')
    },
    parseArtifactTree () {
      this.items = [{
        id: 99999999999,
        title: 'schemas',
        name: 'schemas',
        children: this.pdeProject.schemas.nodes.map(
          schema => {
            return {
              id: schema.id,
              title: 'schema',
              name: schema.name,
              children: this.allArtifactTypes.map(
                artifactType => {
                  return {
                    id: artifactType.id,
                    title: 'artifact_type',
                    name: artifactType.name,
                    children: schema.artifacts.nodes.filter(a => a.artifactType.id === artifactType.id).map(
                      artifact => {
                        return {
                          id: artifact.id,
                          title: 'artifact',
                          name: `*-${artifact.name}`,
                          children: []
                        }
                      }
                    )
                  }
                }
              )
            }
          }
        )
      }]

      this.allArtifacts = this.pdeProject.schemas.nodes.reduce(
        (acc, schema) => {
          return acc.concat(schema.artifacts.nodes)
        }, []
      )
    },
    findArtifact (id) {
      // const artifact = this.pdeProject.schemas.nodes.
    }
  },
  computed: {
    disableNew () {
      return false
      // return this.workingArtifactType.id === null
    }
  },
  watch: {
    selectedItems (sel) {
      const artifact = this.allArtifacts.find(a => a.id === sel[0])
      if (sel[0] === 99999999999) {
        this.$router.push({ name: 'home' })
      } else if (artifact) {
        this.$router.push({ name: 'artifact', params: { id: artifact.id }})
      }
    },
    focusArtifactId () {
      this.selectedItems = [this.focusArtifactId]
    }
  },
  apollo: {
    init: {
      query: initQuery,
      variables () {
        return {
          id: `${this.pdeProjectId}`
        }
      },
      networkPolicy: 'fetch-only',
      skip () {
        return this.pdeProjectId === ''
      },
      update (result) {
        this.pdeProject = result.pdeProjectById
        this.allArtifactTypes = result.allArtifactTypes.nodes
        this.parseArtifactTree()
      }
    }
  },
  props: {
    pdeProjectId: {
      type: String,
      required: true
    },
    focusArtifactId: String
  },
  data () {
    return {
      items:  [],
      selectedItems: [],
      pdeProject: null,
      allArtifactTypes: [],
      allArtifacts: []
    }
  },
}
</script>
