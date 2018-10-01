<template>
  <div>
    <v-btn :disabled="newArtifactDisabled">New Patch</v-btn>
    <v-treeview
      :items="items"
      key-field="id"
      caption-field="name"
      children-field="children"
      expand-all
      select
      @treeSelect="treeSelect"
      v-model="selectedItems"
    />
  </div>
</template>

<script>
export default {
  name: "MinorArtifactTree",
  methods: {
    newArtifact() {
      alert('new')
    },
    findArtifact (id) {
      // const artifact = this.pdeProject.schemas.nodes.
    },
    focusPatchChanged (focusPatch) {
      // console.log('FOCUS DANIELSON', focusPatch)
      this.focusPatch = focusPatch
      switch (focusPatch.__typename) {
        case 'Schema':
          this.selectedItems = [ focusPatch.id ]
        break
        case 'Artifact':
          this.selectedItems = [ focusPatch.id ]
        break
        case 'ArtifactType':
          this.selectedItems = [ focusPatch.id ]
        break
        case 'Patch':
          this.selectedItems = [ focusPatch.artifact.id ]
        break
        default:
          this.selectedItems = []
      }
    },
    treeSelect (id) {
      // console.log('treeSelect', id)
      const schema = this.schemas.find(s => s.id === id)
      const artifact = this.allArtifacts.find(a => a.id === id)
      const artifactType = this.allArtifactTypes.find(at => at.id === id)
      if (schema) {
        this.$eventHub.$emit('schemaSelected', schema)
      } else if (artifact) {
        this.$eventHub.$emit('artifactSelected', artifact)
      } else if (artifactType) {
        this.$eventHub.$emit('artifactTypeSelected', artifactType)
      } else {
      }
    },
    getArtifactsForType (artifactType) {
      return this.allArtifacts.filter(a => a.artifactType.id === artifactType.id)
    },
    getPatchesForArtifactType (artifactType) {
      return this.minor.patches.nodes.filter(p => p.artifact.artifactType.id === artifactType.id)
    }
  },
  computed: {
    items () {
      return this.schemas.map(
          schema => {
            return {
              id: schema.id,
              name: schema.name,
              children: this.artifactTypes.map(
                artifactType => {
                  const patches = this.getPatchesForArtifactType(artifactType)

                  const artifacts = patches.reduce(
                    (acc, patch) => {
                      const existing = acc.find(a => a.id === patch.artifact.id)
                      return existing ? acc : acc.concat([patch.artifact])
                    }, []
                  )

                  return {
                    id: artifactType.id,
                    name: artifactType.name,
                    children: artifacts.map(
                      artifact => {
                        return {
                          id: artifact.id,
                          name: artifact.name,
                          children: patches.filter(p => p.artifact.id === artifact.id).map(
                            patch => {
                              return {
                                id: patch.id,
                                name: patch.patchType.name,
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
            }
          }
        )
    },
    artifactTypes () {
      return this.minor.patches.nodes.reduce(
        (acc, patch) => {
          const artifactType = patch.artifact.artifactType
          return acc.find(at => at.id === artifactType.id) ? acc : acc.concat([artifactType])
        }, []
      )
    },
    schemas () {
      return this.minor.patches.nodes.reduce(
        (acc, patch) => {
          const schema = patch.artifact.schema
          return acc.find(s => s.id === schema.id) ? acc : acc.concat([schema])
        }, []
      )
    },
    allArtifacts () {
      return this.minor.patches.nodes.reduce(
        (acc, patch) => {
          const artifact = patch.artifact
          return acc.find(a => a.id === artifact.id) ? acc : acc.concat([artifact])
        }, []
      )
    },
    newArtifactDisabled () {
      return (this.focusPatch.__typename || 'NONE') !== 'ArtifactType'
    }
  },
  watch: {
  },
  props: {
    minor: {
      type: Object,
      required: true
    },
    // focusArtifactId: String,
    allArtifactTypes: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      selectedItems: [],
      focusPatch: {}
    }
  },
  created () {
    this.$eventHub.$on('focusPatch', this.focusPatchChanged);
    this.$eventHub.$on('treeSelect', this.treeSelect);
  },
  beforeDestroy() {
    this.$eventHub.$off('focusPatch');
    this.$eventHub.$off('treeSelect');
  }
}
</script>
