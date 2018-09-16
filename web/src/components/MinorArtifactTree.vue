<template>
  <div>
    <v-btn :disabled="newArtifactDisabled">New</v-btn>
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
export default {
  name: "MinorArtifactTree",
  methods: {
    newArtifact() {
      alert('new')
    },
    findArtifact (id) {
      // const artifact = this.pdeProject.schemas.nodes.
    }
  },
  computed: {
    items () {
      return [{
        id: 99999999999,
        name: 'schemas',
        children: this.schemas.map(
          schema => {
            return {
              id: schema.id,
              name: schema.name,
              children: this.allArtifactTypes.map(
                artifactType => {
                  const typeChildren = this.minor.patches.nodes.reduce(
                    (acc, patch) => {
                        return patch.artifact.artifactType.id === artifactType.id ? acc.concat([patch.artifact]) : acc
                      }, []   
                  )

                  return {
                    id: artifactType.id,
                    title: 'artifact_type',
                    name: artifactType.name,
                    children: typeChildren.map(
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
      return (this.focusItem.__typename || 'NONE') !== 'ArtifactType'
    }
  },
  watch: {
    selectedItems (sel) {
      const artifact = this.allArtifacts.find(a => a.id === sel[0])
      const artifactType = this.allArtifactTypes.find(at => at.id === sel[0])
      if (sel[0] === 99999999999) {
        this.$eventHub.$emit('schemaRootSelected')
      } else if (artifact) {
        this.$eventHub.$emit('artifactSelected', artifact)
      } else if (artifactType) {
        this.$eventHub.$emit('artifactTypeSelected', artifactType)
      } else {
      }
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
      focusItem: {}
    }
  },
}
</script>
