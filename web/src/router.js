import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
// import Apollo from "./views/Apollo.vue";
import Artifact from "./components/Routes/Artifact.vue"
import ProjectNew from "./components/Project/ProjectNew.vue"
import ProjectDetail from "./components/Project/ProjectDetail.vue"
import TestGraphQL from "./components/Routes/TestGraphQL.vue"
import TestPgTap from "./components/Routes/TestPgTap.vue"
import PatchNew from "./components/Routes/PatchNew.vue"
import SchemaNew from "./components/Routes/SchemaNew.vue"

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/artifact/:id",
      name: "artifact",
      component: Artifact,
      props: true
    },
    {
      path: "/newProject",
      name: "newProject",
      component: ProjectNew,
      props: false
    },
    {
      path: "/project/:id",
      name: "projectDetail",
      component: ProjectDetail,
      props: true
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
      component: PatchNew,
      props: true
    },
    {
      path: "/newSchema/:releaseId",
      name: "newSchema",
      component: SchemaNew,
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
