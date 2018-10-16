import Vue from 'vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
import 'material-design-icons-iconfont/dist/material-design-icons.css' // Ensure you are using css-loader

import VTreeview from '@/components/common/vtreeview'
import { VuePlugin } from 'vuera'

Vue.use(Vuetify, {
  iconfont: 'md' // 'md' || 'mdi' || 'fa' || 'fa4'
})

Vue.use(VTreeview)

Vue.use(require('vue-shortkey'))

Vue.use(VuePlugin)
