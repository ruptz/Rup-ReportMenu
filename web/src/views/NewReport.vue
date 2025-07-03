<template>
  <div class="new-report">
    <div class="form-header">
      <button class="button" @click="router.push('/')">{{ t('newreport.backToReports') }}</button>
      <h1>{{ t('newreport.title') }}</h1>
    </div>

    <form @submit.prevent="submitReport" class="report-form">
      <div class="form-group">
        <label>{{ t('newreport.title2') }}</label>
        <input v-model="form.title" type="text" required :placeholder="t('newreport.titlePlaceholder')">
      </div>

      <div class="form-group">
        <label>{{ t('newreport.reportAgainst') }}</label>
        <input v-model="form.reported_name" type="text" :placeholder="t('newreport.reportAgainstPlaceholder')">
      </div>

      <div class="form-group">
        <label>{{ t('newreport.description') }}</label>
        <textarea 
          v-model="form.description" 
          required 
          :placeholder="t('newreport.descriptionPlaceholder')"
        ></textarea>
      </div>

      <div class="form-group">
        <label>{{ t('newreport.priority') }}</label>
        <select v-model="form.priority">
          <option value="low">{{ t('prioTypes.low') }}</option>
          <option value="medium">{{ t('prioTypes.medium') }}</option>
          <option value="high">{{ t('prioTypes.high') }}</option>
        </select>
      </div>

      <button type="submit" class="button submit-button" :disabled="submitting">
        {{ submitting ? t('newreport.sumbitting') : t('newreport.sumbit') }}
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useLang } from '@/composables/useLang'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui
const { t } = useLang()
const router = useRouter()
const submitting = ref(false)

const form = ref({
  title: '',
  reported_name: '',
  description: '',
  priority: 'medium'
})

const submitReport = async () => {
  if (submitting.value) return
  submitting.value = true

  try {
    const response = await fetchNui<{success: boolean, reportId: number}>('createReport', form.value)
    if (response.success) {
      router.push(`/report/${response.reportId}`)
    }
  } finally {
    submitting.value = false
  }
}
</script>

<style lang="scss" scoped>
@use '@/styles/main.scss' as *;
.new-report {
  width: 100%;
  max-width: 800px;  
  background: theme-var('surface');
  min-height: 90vh;
  display: flex;
  flex-direction: column;
  color: theme-var('text');
  border-radius: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.form-header {  
  background: theme-var('surface');
  padding: 24px 32px;
  border-bottom: 1px solid theme-var('border');
  display: flex;
  align-items: center;
  gap: 24px;

  h1 {
    font-size: 24px;
    font-weight: 500;
    color: white;
    background-color: theme-var('button');
    border-radius: 5px;
    padding: 8px;
    margin: 0;
  }

  .button {
    background: none;
    color: #5f6368;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: background 0.2s;    
    &:hover {
      background: theme-var('hover');
    }
  }
}

.report-form {  flex: 1;
  padding: 32px;
  background: theme-var('background');
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;

  label {
    font-size: 14px;
    font-weight: 500;    
    color: theme-var('text-secondary');
  }

  input, textarea, select {
    padding: 12px;
    border: 1px solid theme-var('border');
    border-radius: 4px;
    font-size: 14px;
    color: theme-var('text');
    background: theme-var('surface');
    transition: border-color 0.2s;

    // Scrollbar styling
    &::-webkit-scrollbar {
      width: 8px;
      background: transparent;
    }
    &::-webkit-scrollbar-track {
      background: theme-var('border');
      border-radius: 4px;
    }
    &::-webkit-scrollbar-thumb {
      background: theme-var('button');
      border-radius: 4px;
    }

    &:focus {
      outline: none;
      border-color: #1a73e8;
    }

    &::placeholder {
      color: #80868b;
    }
  }
  textarea {
    height: 120px;
    max-height: 300px;
    resize: vertical;
    line-height: 1.5;
    overflow-y: auto;
  }

  select {
    cursor: pointer;
  }
}

.submit-button {
  margin-top: 16px;
  padding: 12px 24px;
  background: #1a73e8;
  color: white;
  border: none;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  align-self: flex-end;
  transition: background 0.2s;

  &:hover {
    background: #1557b0;
  }

  &:disabled {
    background: #dadce0;
    cursor: not-allowed;
  }
}
</style>