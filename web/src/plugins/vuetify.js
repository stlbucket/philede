import Vue from 'vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'

import VTreeview from '@/components/common/vtreeview'

// import colors from 'vuetify/es5/util/colors'

Vue.use(Vuetify, {
  // theme: {
  //   primary: colors.purple,
  //   secondary: colors.grey.darken1,
  //   accent: colors.yellow.accent3,
  //   error: colors.red.accent3
  // }
})

Vue.use(VTreeview)
