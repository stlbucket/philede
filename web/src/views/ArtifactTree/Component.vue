<template>
  <div>
    <div>SELECTED: {{ selectedItems }}</div>
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
import ProjectById from '../../graphql/query/ProjectById.gql'

export default {
  name: "ArtifactTree",
  methods: {
    parseArtifactTree (pdeProject, allArtifactTypes) {
      this.items = [{
        id: 99999999999,
        title: 'schemas',
        name: 'schemas',
        children: pdeProject.schemas.nodes.map(
          schema => {
            return {
              id: schema.id,
              title: 'schema',
              name: schema.name,
              children: allArtifactTypes.map(
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
    }
  },
  apollo: {
    pdeProjectById: {
      query: ProjectById,
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
        const pdeProject = result.pdeProjectById
        const allArtifactTypes = result.allArtifactTypes.nodes
        this.parseArtifactTree(pdeProject, allArtifactTypes)
      }
    }
  },
  props: {
    pdeProjectId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      items:  [],
      selectedItems: []
    }
  },
}
</script>
