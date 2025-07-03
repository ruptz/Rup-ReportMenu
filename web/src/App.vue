<template>
  <div class="app" v-show="visible">
    <router-view></router-view>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useNuiEvent } from '@/composables/useNuiEvent'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'
import { useThemeStore } from '@/stores/theme'
import { useLang } from '@/composables/useLang'

const isDevelopment = import.meta.env.VITE_DEV === 'true'
const fetchNui = isDevelopment ? mockFetchNui : prodFetchNui
const visible = ref(isDevelopment)
const themeStore = useThemeStore()
const { loadLanguages } = useLang()

useNuiEvent('openReportMenu', () => {
  visible.value = true
})

const handleKeyPress = (e: KeyboardEvent) => {
  // Escape to close in both dev and production
  if (e.key === 'Escape') {
    visible.value = false
    fetchNui('closeMenu', {})
  }
  
  // Ctrl+I to toggle in dev debug only
  if (isDevelopment && e.ctrlKey && e.key === 'i') {
    e.preventDefault()
    visible.value = !visible.value
  }
}

onMounted(async () => {
  await themeStore.loadTheme()
  document.documentElement.classList.toggle('theme-dark', themeStore.theme === 'dark')
  await loadLanguages()
  console.log('Rup-ReportMenu Loaded, Enjoy!')
  window.addEventListener('keydown', handleKeyPress)
})
</script>

<style lang="scss">
@use '@/styles/main.scss';

.app {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;  color: theme-var('text');
  font-family: 'Inter', sans-serif;
  background: transparent;
  padding: 2rem;
}

.theme-toggle-position {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 100;
}
</style>