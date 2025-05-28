import { onMounted, onUnmounted } from 'vue'

interface NuiMessage<T = unknown> {
  action: string
  data: T
}

export const useNuiEvent = <T = unknown>(action: string, handler: (data: T) => void) => {
  const eventListener = (event: MessageEvent<NuiMessage<T>>) => {
    const { action: eventAction, data } = event.data

    if (eventAction === action) {
      handler(data)
    }
  }

  onMounted(() => window.addEventListener('message', eventListener))
  onUnmounted(() => window.removeEventListener('message', eventListener))

  return { }
}