import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
// import Apollo from "./views/Apollo.vue";
// import Artifact from "./components/Artifact/Artifact.vue"
import ArtifactDetail from "./components/Artifact/ArtifactDetail.vue"
import ArtifactTypeDetail from "./components/ArtifactType/ArtifactTypeDetail.vue"

import Config from "./components/Config/Config.vue"

import Graphileiql from "./components/Graphileiql/Graphileiql.vue"
import GraphQLSchema from "./components/Graphileiql/GraphQLSchema.vue"
import GraphQLTest from "./components/GraphQLTest/GraphQLTest.vue"

import ProjectNew from "./components/Project/ProjectNew.vue"
import ProjectDetail from "./components/Project/ProjectDetail.vue"
import ProjectExport from "./components/Project/ProjectExport.vue"
import ProjectImport from "./components/Project/ProjectImport.vue"

import ReleaseDetail from "./components/Release/ReleaseDetail.vue"
import ReleaseCreate from "./components/Release/ReleaseCreate.vue"

import TestGraphQL from "./components/Routes/TestGraphQL.vue"

import TestPgTap from "./components/Routes/TestPgTap.vue"

import PatchCreate from "./components/Patch/PatchCreate.vue"
import PatchDetail from "./components/Patch/PatchDetail.vue"
import PgTapTest from "./components/PgTapTest/PgTapTest.vue"
import PsqlQuery from "./components/PsqlQuery/PsqlQuery.vue"


import MinorCreate from "./components/Minor/MinorCreate.vue"

import SchemaNew from "./components/Routes/SchemaNew.vue"
import SchemaDetail from "./components/Schema/SchemaDetail.vue"

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/artifactDetail/:id",
      name: "artifactDetail",
      component: ArtifactDetail,
      props: true
    },
    {
      path: "/artifactTypeDetail/:id",
      name: "artifactTypeDetail",
      component: ArtifactTypeDetail,
      props: true
    },
    {
      path: "/newProject",
      name: "newProject",
      component: ProjectNew,
      props: false
    },
    {
      path: "/exportProject",
      name: "exportProject",
      component: ProjectExport,
      props: false
    },
    {
      path: "/importProject",
      name: "importProject",
      component: ProjectImport,
      props: false
    },
    {
      path: "/psql-query/:id",
      name: "psql-query",
      component: PsqlQuery,
      props: true
    },
    {
      path: "/psql-query",
      name: "new-psql-query",
      component: PsqlQuery,
      props: false
    },
    {
      path: "/pg-tap-test/:id",
      name: "pg-tap-test",
      component: PgTapTest,
      props: true
    },
    {
      path: "/graph-ql-test/:id",
      name: "graph-ql-test",
      component: GraphQLTest,
      props: true
    },
    {
      path: "/graphileiql",
      name: "graphileiql",
      component: Graphileiql,
      props: false
    },
    {
      path: "/graphQLSchema",
      name: "graphQLSchema",
      component: GraphQLSchema,
      props: false
    },
    {
      path: "/project",
      name: "projectDetail",
      component: ProjectDetail,
      props: false
    },
    {
      path: "/release/:id",
      name: "releaseDetail",
      component: ReleaseDetail,
      props: true
    },
    {
      path: "/newMinor",
      name: "newMinor",
      component: MinorCreate,
      props: true
    },
    {
      path: "/newDevelopmentRelease",
      name: "newDevelopmentRelease",
      component: ReleaseCreate,
      props: false
    },
    {
      path: "/config",
      name: "config",
      component: Config,
      props: false
    },
    {
      path: "/test-graph-ql/:id",
      name: "test-graph-ql",
      component: TestGraphQL,
      props: true
    },
    {
      path: "/test-pg-tap/:id",
      name: "test-pg-tap",
      component: TestPgTap,
      props: true
    },
    {
      path: "/newPatch/:minorId",
      name: "newPatch",
      component: PatchCreate,
      props: true
    },
    {
      path: "/patchDetail/:id",
      name: "patchDetail",
      component: PatchDetail,
      props: true
    },
    {
      path: "/newSchema/:releaseId",
      name: "newSchema",
      component: SchemaNew,
      props: true
    },
    {
      path: "/schemaDetail/:id",
      name: "schemaDetail",
      component: SchemaDetail,
      props: true
    },
    {
      path: "/about",
      name: "about",
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () =>
        import(/* webpackChunkName: "about" */ "./views/About.vue")
    }
  ]
});
