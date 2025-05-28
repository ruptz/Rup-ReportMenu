<template>
  <Teleport to="body">
  <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
      <div class="modal-content">
        <h2>{{ title }}</h2>
        <p>{{ message }}</p>
        <div class="modal-actions">
          <button class="button subtle" @click="$emit('close')">Cancel</button>
          <button class="button danger" @click="$emit('confirm')">Delete</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
defineProps<{
  show: boolean
  title: string
  message: string
}>()

defineEmits<{
  (e: 'close'): void
  (e: 'confirm'): void
}>()
</script>

<style lang="scss" scoped>
@use '@/styles/main.scss' as *;

.modal-overlay {
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
    background: rgba(0, 0, 0, 0.7);
  }
  
  animation: fadeIn 0.2s ease-out;
}

.modal-content {
  position: relative;
  z-index: 2;
  background-color: theme-var('surface');
  border: 1px solid theme-var('border');
  border-radius: 8px;
  padding: 24px;
  width: 90%;
  max-width: 400px;
  box-shadow: 0 8px 16px theme-var('shadow');
  animation: slideIn 0.2s ease-out;

  h2 {
    color: theme-var('text');
    font-size: 20px;
    font-weight: 500;
    margin: 0 0 12px 0;
  }

  p {
    color: theme-var('text-secondary');
    margin: 0 0 24px 0;
    line-height: 1.5;
  }
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;

  .button {
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    border: none;
    transition: all 0.2s;

    &.subtle {
      background: theme-var('button');
      color: white;

      &:hover {
        opacity: 0.5;
      }
    }

    &.danger {
      background: var(--danger-color);
      color: white;

      &:hover {
        opacity: 0.5;
      }
    }
  }
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