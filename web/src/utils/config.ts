interface ConfigData {
  fiveManageApiKey: string
  deleteMedia: boolean
}

let configCache: ConfigData | null = null

export const getConfig = async (): Promise<ConfigData> => {
  if (configCache) {
    return configCache
  }

  const fetchNui = await import('@/utils/fetchNui')
  const isDevelopment = import.meta.env.VITE_DEV === 'true'

  if (isDevelopment) {
    configCache = {
      fiveManageApiKey: 'dev-api-key',
      deleteMedia: true
    }
    return configCache
  }

  try {
    const response = await fetchNui.fetchNui<ConfigData>('getConfig', {})
    configCache = response
    return response
  } catch (error) {
    console.error('Failed to fetch config:', error)
    configCache = {
      fiveManageApiKey: '',
      deleteMedia: true
    }
    return configCache
  }
}

export const getFiveManageApiKey = async (): Promise<string> => {
  const config = await getConfig()
  return config.fiveManageApiKey
}