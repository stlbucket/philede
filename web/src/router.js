import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
// import Apollo from "./views/Apollo.vue";
import Artifact from "./views/Artifact.vue"
import ProjectNew from "./components/ProjectNew.vue"
import ProjectDetail from "./components/ProjectDetail.vue"
import NewRelease from "./views/NewRelease/Component.vue"
import TestGraphQL from "./components/TestGraphQL.vue"
import TestPgTap from "./components/TestPgTap.vue"
import PatchNew from "./components/PatchNew.vue"

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
      name: "project",
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
      path: "/newRelease",
      name: "newRelease",
      component: NewRelease,
      props: false
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
