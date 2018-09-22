import '@babel/polyfill'
import Vue from "vue";
import './plugins/vuetify'
import App from "./App.vue";
import router from "./router";
import { createProvider } from "./vue-apollo";
import 'graphiql/graphiql.css'

Vue.config.productionTip = false;

// from https://medium.com/vuejobs/create-a-global-event-bus-in-vue-js-838a5d9ab03a
Vue.prototype.$eventHub = new Vue(); // Global event bus

new Vue({
  router,
  provide: createProvider().provide(),
  render: h => h(App)
}).$mount("#app");
