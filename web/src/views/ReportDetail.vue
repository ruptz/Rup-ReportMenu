<template>  <div class="report-detail">
    <ConfirmModal
      :show="showDeleteModal"
      title="Delete Report"
      message="Are you sure you want to delete this report? This action cannot be undone."
      @close="showDeleteModal = false"
      @confirm="handleDeleteConfirm"
    />
    <div class="detail-header">
      <div class="header-left">
        <button class="button subtle" @click="router.push('/')">
          <span class="icon">←</span>
          Back to Reports
        </button>
        <h1>{{ truncate(report?.title, 30) || 'Loading...' }}</h1>
      </div>      
      <div v-if="report" class="header-actions">
        <button v-if="permissionStore.canDeleteReports" 
                @click="confirmDelete"
                class="button danger">
          Delete Report
        </button>
        <select v-if="permissionStore.canManageReports"
                v-model="report.status" 
                @change="updateReport"
                class="status-select">
          <option value="open">Open</option>
          <option value="in_progress">In Progress</option>
          <option value="closed">Closed</option>
        </select>
        <select v-if="permissionStore.canManageReports" 
                v-model="report.priority" 
                @change="updateReport"
                class="priority-select">
          <option value="low">Low Priority</option>
          <option value="medium">Medium Priority</option>
          <option value="high">High Priority</option>
        </select>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      Loading report...
    </div>
    
    <div v-else-if="!report" class="not-found">
      Report not found
    </div>
    
    <div v-else class="detail-content">
      <div class="report-info">
        <div class="info-card">
          <div class="info-section">
            <h3>Report Details</h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="label">Reported by</span>
                <span class="value">{{ report.player_name }}</span>
              </div>
              <div class="info-item">
                <span class="label">Player License</span>                
                <button class="value subtle" @click="copyToClipboard(report.player_id)">
                  Copy License
                </button>
              </div>
              <div class="info-item">
                <span class="label">Report ID</span>
                <span class="value">{{ report.id }}</span>
              </div>
              <div class="info-item">
                <span class="label">Status</span>                
                <span :class="['status-badge', `status-${report.status}`]">
                  {{ report.status?.replace('_', ' ') || 'Unknown' }}
                </span>
              </div>
              <div class="info-item">
                <span class="label">Priority</span>
                <span :class="['priority-badge', `priority-${report.priority}`]">
                  {{ report.priority }}
                </span>
              </div>
              <div class="info-item">
                <span class="label">Created</span>
                <span class="value">{{ formatDate(report.created_at) }}</span>
              </div>
              <div v-if="report.reported_name" class="info-item">
                <span class="label">Reported Player</span>
                <span class="value">{{ report.reported_name }}</span>
              </div>
            </div>
          </div>
          <div class="description-section">
            <h3>Description</h3>
            <p class="description">{{ report.description }}</p>
          </div>
        </div>
      </div>

      <div class="messages-container">
        <div class="messages" ref="messagesContainer">          
          <div v-for="(msg, index) in messages" 
               :key="index" 
               :class="['message', { 'message-self': msg.isOwnMessage }]">
            <div class="message-content">
              <div class="message-header">
                <span class="sender">{{ msg.sender_name }}</span>
                <span class="time">{{ formatDate(msg.sent_at) }}</span>
              </div>
              <p>{{ msg.message }}</p>
            </div>
          </div>
        </div>

        <div class="reply-box">
          <textarea 
            v-model="newMessage" 
            placeholder="Type your message..." 
            @keydown.enter.prevent="sendMessage"
            rows="3"
          ></textarea>
          <button @click="sendMessage" 
                  class="button primary" 
                  :disabled="!newMessage.trim()">
            Send Message
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@use '@/styles/main.scss' as *;

.report-detail {
  width: 100%;
  max-width: 1400px;  background: theme-var('surface');
  min-height: 90vh;
  display: flex;
  flex-direction: column;
  color: theme-var('text');
  border-radius: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.detail-header {  
  background: theme-var('surface');
  padding: 24px 32px;
  border-bottom: 1px solid theme-var('border');
  display: flex;
  justify-content: space-between;
  align-items: center;

  .header-left {
    display: flex;
    align-items: center;
    gap: 24px;

    h1 {
      font-size: 24px;
      font-weight: 500;
      color: white;
      border-radius: 5px;
      margin: 0;
      padding: 10px;
      background: theme-var('button');
    }
  }

  .header-actions {
    display: flex;
    gap: 12px;
  }
}

.button {
  padding: 8px 16px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  border: none;

  &.subtle {
    background: none;
    color: #5f6368;
    
    &:hover {
      background: #f1f3f4;
    }
  }

  &.primary {
    background: #1a73e8;
    color: white;

    &:hover {
      background: #1557b0;
    }

    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  }
}

select {
  padding: 8px 12px;
  border: 1px solid theme-var('border');
  border-radius: 4px;
  font-size: 14px;  color: theme-var('text');
  background: theme-var('surface');
  cursor: pointer;

  &:focus {
    outline: none;
    border-color: #1a73e8;
  }

  &.status-select {
    min-width: 140px;
  }

  &.priority-select {
    min-width: 140px;
  }
}

.detail-content {
  display: flex;
  gap: 24px;
  padding: 24px;
  flex: 1;
  min-height: 0;
  background: theme-var('background');
}

.report-info {
  width: 350px;
  flex-shrink: 0;
}

.info-card {  background: theme-var('surface');
  border-radius: 8px;
  border: 1px solid theme-var('border');
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;

  .info-section {
    padding: 20px;
    border-bottom: 1px solid theme-var('border');

    h3 {
      font-size: 16px;
      font-weight: 500;
      color: theme-var('text');
      margin: 0 0 16px 0;
    }
  }

  .description-section {
    padding: 20px;

    h3 {
      font-size: 16px;
      font-weight: 500;
      color: theme-var('text');
      margin: 0 0 16px 0;
    }    
    
    .description {
      color: theme-var('text-secondary');
      line-height: 1.5;
      margin: 0;
      white-space: pre-wrap;
      max-height: 200px;
      overflow-y: auto;
      padding-right: 8px;

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
    }
  }
}

.info-grid {
  display: grid;
  gap: 16px;

  .info-item {
    display: flex;
    flex-direction: column;
    gap: 4px;      .label {
        font-size: 12px;
        color: theme-var('text-secondary');
      }

    .value {
        font-size: 14px;
        color: theme-var('text');
        
        &.subtle {
          background: none;
          border: 1px solid theme-var('border');
          padding: 4px 8px;
          border-radius: 4px;
          cursor: pointer;
          transition: all 0.2s;
          
          &:hover {
            background: theme-var('hover');
            border-color: theme-var('button');
          }
        }
    }
  }
}

.messages-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: theme-var('surface');
  border: 1px solid theme-var('border');
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  height: calc(90vh - 200px);
  min-width: 0;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-height: 100%;

  // Scrollbar styling
  &::-webkit-scrollbar {
    width: 8px;
    background: transparent;
  }

  &::-webkit-scrollbar-track {
    background: theme-var('surface-secondary');
    border-radius: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: theme-var('border');
    border-radius: 4px;
    
    &:hover {
      background: theme-var('text-secondary');
    }
  }
}

.message {
  display: flex;
  margin-right: 48px;

  &.message-self {
    margin-right: 0;
    margin-left: 48px;
    flex-direction: row-reverse;    
    .message-content {
      background: theme-var('message-bg');
      color: theme-var('text');
    }
  }
  .message-content {
    background: theme-var('background');
    padding: 12px 16px;
    border-radius: 8px;
    max-width: 80%;
    word-wrap: break-word;
    word-break: break-word;
    overflow-wrap: break-word;

    .message-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 4px;
      
      .sender {
        font-weight: 500;
        font-size: 13px;
        color: theme-var('text');
      }

      .time {
        font-size: 12px;
        padding-left: 20px;
        color: theme-var('text-secondary');
      }
    }

    p {
      margin-top: 10px;
      color: theme-var('text');
      letter-spacing: 0.5px;
      line-height: 1.4;
      font-size: 14px;
      word-wrap: break-word;
      word-break: break-word;
      overflow-wrap: break-word;
      white-space: pre-wrap;
    }
  }
}

.reply-box {
  padding: 16px;
  border-top: 1px solid theme-var('border');
  display: flex;
  gap: 12px;
  textarea {
    flex: 1;
    padding: 12px;
    border: 1px solid theme-var('border');
    border-radius: 4px;
    resize: none;
    font-family: inherit;
    font-size: 14px;
    line-height: 1.4;
    background: theme-var('surface');
    color: theme-var('text');

    &:focus {
      outline: none;
      border-color: #1a73e8;
    }

    //Scrollbar styling
    &::-webkit-scrollbar {
      width: 8px;
      background: transparent;
    }

    &::-webkit-scrollbar-track {
      background: theme-var('surface-secondary');
      border-radius: 4px;
    }
    
    &::-webkit-scrollbar-thumb {
      background: theme-var('border');
      border-radius: 4px;

      &:hover {
        background: theme-var('text-secondary');
      }
    }
  }
}

.status-badge, .priority-badge {
  display: inline-flex;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge {  
  &.status-open {
    @extend .status-open;
  }
  &.status-in_progress {
    @extend .status-in_progress;
  }
  &.status-closed {
    @extend .status-closed;
  }
}

.priority-badge {
  &.priority-low {
    @extend .priority-low;
  }
  &.priority-medium {
    @extend .priority-medium;
  }
  &.priority-high {
    @extend .priority-high;
  }
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px;
  color: #5f6368;
  
  .loading-spinner {
    width: 24px;
    height: 24px;
    border: 2px solid #dadce0;
    border-top-color: #1a73e8;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 16px;
  }
}

.not-found {
  text-align: center;
  padding: 48px;
  color: #5f6368;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ConfirmModal from '@/components/ConfirmModal.vue'
import { usePermissionStore } from '@/stores/permissions'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'
import type { Report, Message, MessageContent } from '@/types'
import { format } from 'date-fns'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()
const report = ref<Report | null>(null)
const messages = ref<MessageContent[]>([])
const loading = ref(true)
const newMessage = ref('')
const currentPlayerId = ref<string>('')
const messagesContainer = ref<HTMLElement | null>(null)

const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

const loadReport = async () => {
  try {
    const reportId = Number(route.params.id)
    if (reportId) {
      const reports = await fetchNui<Report[]>('getReports', {})
      report.value = reports.find(r => r.id === reportId) || null
      
      if (report.value) {
        await updateMessages(reportId)
      } else {
        messages.value = []
      }
    }
  } finally {
    loading.value = false
  }
}

const updateReport = async () => {
  if (!report.value) return
  await fetchNui('updateReport', {
    reportId: report.value.id,
    updates: {
      status: report.value.status,
      priority: report.value.priority
    }
  })
}

const sendMessage = async () => {
  if (!report.value || !newMessage.value.trim()) return

  const messageContent = newMessage.value
  newMessage.value = '' // Clear input

  // Development mode
  if (import.meta.env.VITE_DEV === 'true') {
    const mockMessage: MessageContent = {
      message: messageContent,
      sender_id: currentPlayerId.value || 'license:dev_user',
      sender_name: 'Dev User',
      sent_at: new Date().toISOString(),
      isOwnMessage: true,
    }

    messages.value.push(mockMessage)
    await scrollToBottom()
    return
  }

  const response = await fetchNui<{success: boolean, messageId: number}>('addMessage', {
    report_id: report.value.id,
    message: messageContent
  })

  if (response.success) {
    await updateMessages(report.value.id)
  }
}

const copyToClipboard = async (text: string) => {
  try {
    await fetchNui<{success: boolean}>('copyToClipboard', { text })
  } catch (error) {
    console.error('Failed to copy: ', error)
  }
}

const showDeleteModal = ref(false)

const handleDeleteConfirm = async () => {
  if (!report.value) return

  const response = await fetchNui<{success: boolean}>('deleteReport', {
    reportId: report.value.id
  })

  if (response.success) {
    router.push({ name: 'reports' })
  }
  showDeleteModal.value = false
}

const confirmDelete = () => {
  showDeleteModal.value = true
}

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy HH:mm')
}

const truncate = (str: string | undefined, length: number) => {
  if (!str) return '';
  return str.length > length ? str.substring(0, length) + '...' : str;
}

const updateMessages = async (reportId: number) => {
  try {
    const response = await fetchNui<{messages: MessageContent[], currentPlayer: string}>('getReportMessages', { reportId })
    if (response?.messages) {
      currentPlayerId.value = response.currentPlayer


      const uniqueMessages = new Map()
      response.messages.forEach(msg => {
        const key = `${msg.message}-${msg.sent_at}-${msg.sender_id}`
        if (!uniqueMessages.has(key)) {
          uniqueMessages.set(key, {
            ...msg,
            isOwnMessage: msg.sender_id === response.currentPlayer
          })
        }
      })

      messages.value = Array.from(uniqueMessages.values()).sort((a, b) => 
        new Date(a.sent_at).getTime() - new Date(b.sent_at).getTime()
      )
      await scrollToBottom()
    }
  } catch (error) {
    console.error('Error updating messages:', error)
  }
}

onMounted(async () => {
  await loadReport()
  await nextTick()
  await scrollToBottom()
  
  window.addEventListener('message', (event) => {
    if (event.data.type === 'updateMessages' && report.value) {
      updateMessages(event.data.id)
    }
  })
})
</script>