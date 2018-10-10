<template>
  <div>
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
    treeSelect (id) {
      const schema = this.schemas.find(s => s.id === id)
      const artifact = this.allArtifacts.find(a => a.id === id)
      const artifactType = this.allArtifactTypes.find(at => at.id === id)
      const patch = this.patches.find(p => p.id === id)
      if (schema) {
        this.selectedItems = [ schema.id ]
        this.$store.commit('focusSchemaId', { focusSchemaId: schema.id })
      } else if (artifact) {
        this.selectedItems = [ artifact.id ]
        this.$store.commit('focusArtifactId', { focusArtifactId: artifact.id })
      } else if (artifactType) {
        this.selectedItems = [ artifactType.id ]
        this.$store.commit('focusArtifactTypeId', { focusArtifactTypeId: artifactType.id })
      } else if (patch) {
        this.selectedItems = [ patch.id ]
        this.$store.commit('focusPatchId', { focusPatchId: patch.id })
      }
    },
    getArtifactsForType (artifactType) {
      return this.allArtifacts.filter(a => a.artifactType.id === artifactType.id)
    },
    getSchemaPatchesForArtifactType (artifactType, schema) {
      return this.minor.patches.nodes.filter(p => p.artifact.artifactType.id === artifactType.id && p.artifact.schema.id === schema.id)
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
                  const patches = this.getSchemaPatchesForArtifactType(artifactType, schema)

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
                                name: `${patch.number} - ${patch.patchType.name}`,
                                children: []
                              }
                            }
                          )
                        }
                      }
                    )
                  }
                }
              ).filter(at => at.children.length > 0)
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
    patches () {
      return this.minor.patches.nodes
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
    },
    focusPatchId () {
      return this.$store.state.focusPatchId
    }
  },
  watch: {
    focusPatchId () {
      if (this.focusPatchId !== '') this.selectedItems = [ this.focusPatchId ]
    }
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
    // this.$eventHub.$on('focusPatch', this.focusPatchChanged);
    this.$eventHub.$on('treeSelect', this.treeSelect);
  },
  beforeDestroy() {
    // this.$eventHub.$off('focusPatch');
    this.$eventHub.$off('treeSelect');
  }
}
</script>
