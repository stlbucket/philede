<template>
  <div>
    <h1>Release - {{ release.number }}</h1>
    <v-btn @click="done">Done</v-btn>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="ddl-up"
        ripple
      >
        Up DDL
      </v-tab>
      <v-tab-item
        key="ddl-up"
        lazy
      >
        <v-textarea
          :value="release.ddlUp"
          auto-grow
          readonly
        ></v-textarea>
      </v-tab-item>

      <v-tab
        key="ddl-down"
        ripple
      >
        Down DDL
      </v-tab>
      <v-tab-item
        key="ddl-down"
        lazy
      >
        <v-textarea
          :value="release.ddlDown"
          auto-grow
          readonly
        ></v-textarea>
      </v-tab-item>

    </v-tabs>
  </div>
</template>

<script>
import releasePatchTree from '../../gql/query/releasePatchTree.gql'

export default {
  name: "ReleaseDetail",
  components: {
  },
  methods: {
    done () {
      this.$router.go(-1)
    }
  },
  computed: {
    focusReleaseId () {      
      return this.$store.state.focusReleaseId
    }
  },
  apollo: {
    init: {
      query: releasePatchTree,
      variables () {
        return {
          id: this.focusReleaseId
        }
      },
      skip () {
        return this.focusReleaseId === ''
      },
      fetchPolicy: 'network-only',
      update (result) {
        this.release = result.release
      }
    }

  },
  data () {
    return {
      release: {}
    }
  },
}
</script>
