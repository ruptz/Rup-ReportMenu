import { defineStore } from 'pinia'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui

export type Theme = 'light' | 'dark'

export const useThemeStore = defineStore('theme', {
  state: () => ({
    theme: 'light' as Theme,
    loaded: false
  }),

  actions: {
    async loadTheme() {      try {
        const response = await fetchNui<{ theme: Theme }>('getUserPreferences', {})
        this.theme = response.theme
        document.documentElement.classList.toggle('theme-dark', response.theme === 'dark')
      } catch (error) {
        console.error('Failed to load theme:', error)
      } finally {
        this.loaded = true
      }
    },

    async setTheme(theme: Theme) {
      try {
        await fetchNui('updateUserPreferences', { theme })
        this.theme = theme
        document.documentElement.classList.toggle('theme-dark', theme === 'dark')
      } catch (error) {
        console.error('Failed to update theme:', error)
      }
    }
  }
})