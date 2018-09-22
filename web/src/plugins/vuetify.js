import Vue from 'vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'

import VTreeview from '@/components/common/vtreeview'
import { VuePlugin } from 'vuera'

Vue.use(Vuetify, {
})

Vue.use(VTreeview)

Vue.use(VuePlugin)
