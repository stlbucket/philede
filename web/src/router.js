import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
// import Apollo from "./views/Apollo.vue";
import Artifact from "./views/Artifact/Component.vue"

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    // {
    //   path: "/apollo",
    //   name: "apollo",
    //   component: Apollo
    // },
    {
      path: "/artifact",
      name: "artifact",
      component: Artifact
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
