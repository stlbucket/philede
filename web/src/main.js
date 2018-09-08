import '@babel/polyfill'
import Vue from "vue";
import './plugins/vuetify'
import App from "./App.vue";
import router from "./router";
import { createProvider } from "./vue-apollo";
// import 'vue-awesome/icons'
// import Icon from 'vue-awesome/components/Icon'


Vue.config.productionTip = false;

new Vue({
  router,
  provide: createProvider().provide(),
  render: h => h(App)
}).$mount("#app");

// Vue.component('icon', Icon)
