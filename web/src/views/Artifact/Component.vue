<template>
  <div>
    <div>
      <button 
        @click="commitWorkingArtifact"
        :disabled="disableSave"
      >Save
      </button>
      <button 
        @click="newArtifact"
        :disabled="disableNew"
      >New
      </button>
    </div>
    <div>
      <p :hidden="editName">{{ selectedArtifact.name }}</p>
    </div>
    <div id="codemirror">
      <codemirror ref="myCm"
        :value="ddl" 
        :options="cmOptions"
        @ready="onCmReady"
        @focus="onCmFocus"
        @input="onCmCodeChange">
      </codemirror>
    </div>
  </div>
</template>

<script>
import getAllArtifacts from '../../graphql/query/Artifacts.gql'
import updateArtifact from '../../graphql/mutation/UpdateArtifact.gql'
import updateWorkingArtifact from '../../graphql/mutation/UpdateWorkingArtifact.gql'
import commitWorkingArtifact from '../../graphql/mutation/CommitWorkingArtifact.gql'
import getWorkingArtifact from '../../graphql/mutation/GetWorkingArtifact.gql'
import { codemirror } from 'vue-codemirror'
import 'codemirror/lib/codemirror.css'
import gql from 'graphql-tag'

const defaultWorkingArtifact = {
  artifact: {
  }
}

export default {
  name: "Artifact",
  components: {
    codemirror
  },
  props: {
    sql: String
  },
  methods: {
    onCmReady(cm) {
      // console.log('the editor is readied!', cm)
    },
    onCmFocus(cm) {
      // console.log('the editor is focus!', cm)
    },
    onCmCodeChange(newCode) {
      this.workingArtifact.ddl = newCode
      this.captureWorkingArtifact()
    },
    commitWorkingArtifact() {
      console.log('commit')
      // this.$apollo.mutate({
      //   mutation: commitWorkingArtifact,
      //   variables: {
      //     id: this.workingArtifact.id
      //   }
      // })
      // .then(result => {
      //   this.workingArtifact = defaultWorkingArtifact
      //   this.loadArtifacts()
      // })
      // .catch(error => {
      //   alert('ERROR')
      //   console.log('ERROR', error)
      // })
    },
    captureWorkingArtifact() {
      console.log('capture')
      // this.$apollo.mutate({
      //   mutation: updateWorkingArtifact,
      //   variables: {
      //     nodeId: this.workingArtifact.nodeId,
      //     id: this.workingArtifact.id,
      //     ddl: this.workingArtifact.ddl
      //   }
      // })
      // .catch(error => {
      //   alert ('ERROR')
      //   console.log('ERROR', error)
      // })
    },
    selected(node) {
      switch(node.model.type){
        case 'ARTIFACT':
          this.selectedArtifact = Object.assign({}, this.artifacts.reduce(
            (acc, artifactType) => {
              return acc.concat(artifactType.artifacts.nodes)
            }, []
          )
          .find(a => a.id === node.model.id))

          console.log('sel', this.selectedArtifact)
          this.$apollo.mutate({
            mutation: getWorkingArtifact,
            variables: {
              artifactId: this.selectedArtifact.id
            }
          })
          .then(result => {
            this.workingArtifact = result.data.getWorkingArtifact.workingArtifact
            this.ddl = this.workingArtifact.ddl
          })
          .catch(error => {
            alert('ERROR')
            console.log('ERROR', error)
          })
          break
        case 'ARTIFACT_TYPE':
          this.selectedArtifactType = this.artifacts.find(a => a.id === node.model.id)
          break
      }
    },
    newArtifact() {
      alert('new')
    },
    editName () {
      return true
    },
    loadArtifacts () {
      this.$apollo.query({
        query: getAllArtifacts,
        networkPolicy: 'fetch-only'
      })
      .then(result => {
        this.artifacts = result.data.allArtifactTypes.nodes
        console.log('selected', this.$refs.myTreeview.selected)
        console.log('clearSelected', this.$refs.myTreeview.clearSelected)
      })
      .catch(error => {
        alert('ERROR')
        console.log('ERROR', error)
      })
    }
  },
  computed: {
    disableSave () {
      console.log(this.workingArtifact.ddl, this.workingArtifact.artifact.ddl, this.workingArtifact.ddl === this.workingArtifact.artifact.ddl)
      return this.workingArtifact.ddl === this.workingArtifact.artifact.ddl
    },
    disableNew () {
      return false
      // return this.workingArtifactType.id === null
    }
  },
  data () {
    return {
      ddl: 'ddl',
      cmOptions: {
        // codemirror options
        tabSize: 4,
        mode: 'text/javascript',
        theme: 'base16-dark',
        lineNumbers: true,
        line: true,
        // more codemirror options, 更多 codemirror 的高级配置...
      },
      treeOptions: {

      },
      artifacts: [],
            openAll: true,
      treeTypes: [
        {
          type: "#",
          max_children: 6,
          max_depth: 4,
          valid_children: [
            "ARTIFACT_TYPE",
            "ARTIFACT"
          ]
        },
        {
          type: "ARTIFACT_TYPE",
          icon: "far fa-user",
          valid_children: ["ARTIFACT"]
        },
        {
          type: "ARTIFACT",
          icon: "far fa-hospital",
          valid_children: []
        }
      ],
      contextItems: [],
      selectedArtifact: {id: null},
      workingArtifact: defaultWorkingArtifact,
      selectedArtifactType: {id: null}
    }
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#codemirror {
  height: 1000px;
}

#tree {
  width: 20%;
  float: left;
}

</style>
