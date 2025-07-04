import { ref, computed } from 'vue'

import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'

const isDevelopment = import.meta.env.VITE_DEV === 'true'
const fetchNui = isDevelopment ? mockFetchNui : prodFetchNui

interface LanguageData {
  [key: string]: {
    [section: string]: {
      [key: string]: string
    }
  }
}

const languageData = ref<LanguageData>({})
const currentLanguage = ref('en')
const isLoaded = ref(false)

// Load language JSON from public :D
const loadLanguages = async (): Promise<void> => {
  try {
    
    const possiblePaths = [
      '/lang.json',
      '/web/dist/lang.json',
    ]
    
    for (const path of possiblePaths) {
      try {
        const response = await fetch(path)
        
        if (response.ok) {
          languageData.value = await response.json()
          
          // Get config from nui
          const langResponse = await fetchNui<{ language: string }>('getLang', {})
          const serverLang = langResponse?.language || 'en'
          
          if (languageData.value[serverLang]) {
            currentLanguage.value = serverLang
          } else {
            currentLanguage.value = 'en'
          }
          
          isLoaded.value = true
          return
        }
      } catch (err) {
        console.log(`${path} - Failed:`, err)
      }
    }
    
  } catch (error) {
    console.error('Error loading language system:', error)
  }
}

// Get translated text
const t = (key: string, fallback?: string): string => {
  if (!isLoaded.value || !languageData.value[currentLanguage.value]) {
    return fallback || key
  }

  const keys = key.split('.')
  let value: any = languageData.value[currentLanguage.value]

  for (const k of keys) {
    if (value && typeof value === 'object' && k in value) {
      value = value[k]
    } else {
      return fallback || key
    }
  }

  return typeof value === 'string' ? value : fallback || key
}

// Set current language
const setLanguage = (lang: string): void => {
  if (languageData.value[lang]) {
    currentLanguage.value = lang
  } else {
    console.warn('Language not found:', lang)
  }
}

// Get available languages
const availableLanguages = computed(() => {
  return Object.keys(languageData.value)
})

export const useLang = () => {
  return {
    t,
    currentLanguage: computed(() => currentLanguage.value),
    availableLanguages,
    setLanguage,
    loadLanguages,
    isLoaded: computed(() => isLoaded.value)
  }
}