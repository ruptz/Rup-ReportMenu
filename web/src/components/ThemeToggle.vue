<template>
  <button class="theme-toggle" @click="toggleTheme" :title="theme === 'light' ? 'Switch to dark mode' : 'Switch to light mode'">
    <span v-if="theme === 'light'">🌙</span>
    <span v-else>☀️</span>
  </button>
</template>

<script setup lang="ts">
import { useThemeStore } from '@/stores/theme'
import { storeToRefs } from 'pinia'

const themeStore = useThemeStore()
const { theme } = storeToRefs(themeStore)

const toggleTheme = () => {
  themeStore.setTheme(theme.value === 'light' ? 'dark' : 'light')
}
</script>

<style lang="scss" scoped>
.theme-toggle {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: all 0.3s ease;
  color: theme-var('text');
  position: relative;
  overflow: hidden;

  span {
    display: inline-block;
    transition: transform 0.3s ease, opacity 0.3s ease;
  }

  &:hover {
    background: theme-var('hover');
    transform: scale(1.1);
  }

  // Theme transition animations
  &[title*="dark"] span {
    transform: rotate(-45deg);
  }
  
  &[title*="light"] span {
    transform: rotate(45deg);
  }
}
</style>