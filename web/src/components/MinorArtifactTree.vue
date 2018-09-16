<template>
  <div>
    <v-btn :disabled="newArtifactDisabled">New</v-btn>
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
    focusItemChanged (focusItem) {
      // console.log('FOCUS DANIELSON', focusItem)
      this.focusItem = focusItem
      switch (focusItem.__typename) {
        case 'Schema':
          this.selectedItems = [ focusItem.id ]
        break
        case 'Artifact':
          this.selectedItems = [ focusItem.id ]
        break
        case 'ArtifactType':
          this.selectedItems = [ focusItem.id ]
        break
        case 'Patch':
          this.selectedItems = [ focusItem.artifact.id ]
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
    }
  },
  computed: {
    items () {
      return this.schemas.map(
          schema => {
            return {
              id: schema.id,
              name: schema.name,
              children: this.allArtifactTypes.filter(at => at.name !== 'schema').map(
                artifactType => {
                  const typeChildren = this.minor.patches.nodes.reduce(
                    (acc, patch) => {
                        return patch.artifact.artifactType.id === artifactType.id ? acc.concat([patch.artifact]) : acc
                      }, []   
                  )

                  return {
                    id: artifactType.id,
                    name: artifactType.name,
                    children: typeChildren.map(
                      artifact => {
                        return {
                          id: artifact.id,
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
    },
    // items () {
    //   return [{
    //     id: 99999999999,
    //     name: 'schemas',
    //     children: this.schemas.map(
    //       schema => {
    //         return {
    //           id: schema.id,
    //           name: schema.name,
    //           children: this.allArtifactTypes.map(
    //             artifactType => {
    //               const typeChildren = this.minor.patches.nodes.reduce(
    //                 (acc, patch) => {
    //                     return patch.artifact.artifactType.id === artifactType.id ? acc.concat([patch.artifact]) : acc
    //                   }, []   
    //               )

    //               return {
    //                 id: artifactType.id,
    //                 title: 'artifact_type',
    //                 name: artifactType.name,
    //                 children: typeChildren.map(
    //                   artifact => {
    //                     return {
    //                       id: artifact.id,
    //                       title: 'artifact',
    //                       name: `*-${artifact.name}`,
    //                       children: []
    //                     }
    //                   }
    //                 )
    //               }
    //             }
    //           )
    //         }
    //       }
    //     )
    //   }]
    // },
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
      return (this.focusItem.__typename || 'NONE') !== 'ArtifactType'
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
      focusItem: {}
    }
  },
  created () {
    this.$eventHub.$on('focusItem', this.focusItemChanged);
    this.$eventHub.$on('treeSelect', this.treeSelect);
  },
  beforeDestroy() {
    this.$eventHub.$off('focusItem');
    this.$eventHub.$off('treeSelect');
  }
}
</script>
