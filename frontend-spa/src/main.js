import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './views/App.vue'
import router from './router'
import './assets/main.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

app.mount('#app')
