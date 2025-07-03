<template>
  <Teleport to="body">
    <div v-if="show" class="toast-overlay" @click.self="$emit('close')">
      <div class="toast-content" :class="`toast-${type}`">
        <div class="toast-header">
          <span class="toast-icon">
            {{ type === 'error' ? '❌' : type === 'warning' ? '⚠️' : '✅' }}
          </span>
          <span class="toast-title">
            {{ type === 'error' ? 'Error' : type === 'warning' ? 'Warning' : 'Success' }}
          </span>
          <button @click="$emit('close')" class="toast-close">×</button>
        </div>
        <div class="toast-message">{{ message }}</div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
defineProps<{
  show: boolean
  message: string
  type: 'success' | 'error' | 'warning'
}>()

defineEmits<{
  (e: 'close'): void
}>()
</script>

<style lang="scss" scoped>
@use '@/styles/main.scss' as *;

.toast-overlay {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
  }
  
  animation: fadeIn 0.2s ease-out;
}

.toast-content {
  position: relative;
  z-index: 2;
  background-color: theme-var('surface');
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 8px 16px theme-var('shadow');
  animation: slideIn 0.2s ease-out;
  overflow: hidden;
  
  &.toast-success {
    border-left: 4px solid #10b981;
  }
  
  &.toast-error {
    border-left: 4px solid #ef4444;
  }
  
  &.toast-warning {
    border-left: 4px solid #f59e0b;
  }
}

.toast-header {
  display: flex;
  align-items: center;
  padding: 16px 20px 12px 20px;
  gap: 12px;
  border-bottom: 1px solid theme-var('border');
  
  .toast-icon {
    font-size: 18px;
    flex-shrink: 0;
  }
  
  .toast-title {
    flex: 1;
    font-size: 16px;
    font-weight: 500;
    color: theme-var('text');
  }
  
  .toast-close {
    background: none;
    border: none;
    font-size: 20px;
    color: theme-var('text-secondary');
    cursor: pointer;
    padding: 0;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: all 0.2s;
    
    &:hover {
      background: theme-var('hover');
      color: theme-var('text');
    }
  }
}

.toast-message {
  padding: 16px 20px 20px 20px;
  color: theme-var('text-secondary');
  line-height: 1.5;
  white-space: pre-wrap;
  word-wrap: break-word;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideIn {
  from { 
    opacity: 0;
    transform: translateY(-20px);
  }
  to { 
    opacity: 1;
    transform: translateY(0);
  }
}
</style>