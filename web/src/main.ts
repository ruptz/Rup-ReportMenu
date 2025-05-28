import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.mount('#app')

// Development mode detection
if (import.meta.env.VITE_DEV === 'true') {
  window.GetParentResourceName = () => 'Rup-ReportMenu'
}