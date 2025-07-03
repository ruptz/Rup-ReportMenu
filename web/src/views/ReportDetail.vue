<template>  
<div class="report-detail">
    <ConfirmModal
      :show="showDeleteModal"
      title="Delete Report"
      message="Are you sure you want to delete this report? This action cannot be undone."
      @close="showDeleteModal = false"
      @confirm="handleDeleteConfirm"
    />
    
    <ToastNotification
      :show="showToast"
      :message="toastMessage"
      :type="toastType"
      @close="closeToast"
    />
    <div class="detail-header">
      <div class="header-left">
        <button class="button subtle" @click="router.push('/')">
          <span class="icon">←</span>
          <!-- Back to Reports -->
          {{ t('reports.backToReports') }}
        </button>
        <h1>{{ truncate(report?.title, 30) || 'Loading...' }}</h1>
      </div>      
      <div v-if="report" class="header-actions">
        <button v-if="permissionStore.canDeleteReports" 
            @click="confirmDelete"
            class="button danger">
            <!-- Delete Report -->
            {{ t('reports.deleteReport') }}
        </button>
        <select v-if="permissionStore.canManageReports"
                v-model="report.status" 
                @change="updateReport"
                class="status-select">
          <option value="open">{{ t('status.open') }}</option>
          <option value="in_progress">{{ t('status.inProgress') }}</option>
          <option value="closed">{{ t('status.closed') }}</option>
        </select>
        <select v-if="permissionStore.canManageReports" 
                v-model="report.priority" 
                @change="updateReport"
                class="priority-select">
          <option value="low">{{ t('priority.low') }}</option>
          <option value="medium">{{ t('priority.medium') }}</option>
          <option value="high">{{ t('priority.high') }}</option>
        </select>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      <!-- Loading -->
      {{ t('common.loading') }}
    </div>
    
    <div v-else-if="!report" class="not-found">
      <!-- Report not found -->
      {{ t('reports.reportNotFound') }}
    </div>
    
    <div v-else class="detail-content">
      <div class="report-info">
        <div class="info-card">
          <div class="info-section">
            <h3>{{ t('reports.reportDetails') }}</h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="label">{{ t('reports.reportedBy') }}</span>
                <span class="value">{{ report.player_name }}</span>
              </div>              
              <div class="info-item">
                <span class="label">{{ t('reports.playerLicenses') }}</span>
                <div class="license-buttons">
                  <button class="value subtle" @click="copyLicense('license')">
                    {{ t('licenses.copyLicense') }}
                  </button>
                  <button class="value subtle" @click="copyLicense('steam')">
                    {{ t('licenses.copySteam') }}
                  </button>
                  <button class="value subtle" @click="copyLicense('discord')">
                    {{ t('licenses.copyDiscord') }}
                  </button>
                  <button class="value subtle" @click="copyLicense('fivem')">
                    {{ t('licenses.copyFivem') }}
                  </button>
                </div>
              </div>
              <div class="info-item">
                <span class="label">{{ t('reports.reportId') }}</span>
                <span class="value">{{ report.id }}</span>
              </div>
              <div class="info-item">
                <span class="label">{{ t('reports.status') }}</span>                
                <span :class="['status-badge', `status-${report.status}`]">
                  {{ report.status?.replace('_', ' ') || 'Unknown' }}
                </span>
              </div>
              <div class="info-item">
                <span class="label">{{ t('reports.priority') }}</span>
                <span :class="['priority-badge', `priority-${report.priority}`]">
                  {{ report.priority }}
                </span>
              </div>
              <div class="info-item">
                <span class="label">{{ t('reports.created') }}</span>
                <span class="value">{{ formatDate(report.created_at) }}</span>
              </div>
              <div v-if="report.reported_name" class="info-item">
                <span class="label">{{ t('reports.reportedPlayer') }}</span>
                <span class="value">{{ report.reported_name }}</span>
              </div>
            </div>
          </div>
          <div class="description-section">
            <h3>{{ t('reports.description') }}</h3>
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
              
              <!-- Check if message is a media URL -->
              <div v-if="isMediaUrl(msg.message).isMedia" class="media-attachment">
                <img v-if="isMediaUrl(msg.message).type === 'image'" 
                     :src="extractUrlFromMessage(msg.message)" 
                     alt="Attachment" 
                     class="attachment-image"
                     @click="openMedia(extractUrlFromMessage(msg.message))" />
                <video v-else-if="isMediaUrl(msg.message).type === 'video'" 
                       :src="extractUrlFromMessage(msg.message)" 
                       controls 
                       class="attachment-video"></video>
              </div>
              
              <!-- Regular text message -->
              <p v-else>{{ msg.message }}</p>
            </div>
          </div>
        </div>

        <div class="reply-box">
          <!-- Media preview -->
          <div v-if="mediaPreview" class="media-preview">
            <div class="preview-container">
              <img v-if="mediaType === 'image'" :src="mediaPreview" alt="Preview" class="preview-image" />
              <video v-else-if="mediaType === 'video'" :src="mediaPreview" controls class="preview-video"></video>
              <button @click="clearMedia" class="clear-media">×</button>
            </div>
          </div>
          
          <div class="message-input-container">
            <div class="input-wrapper">
              <textarea 
                v-model="newMessage" 
                :placeholder="t('messages.typeMessage')"
                @keydown.enter.prevent="sendMessage"
                @paste="handlePaste"
                rows="3"
              ></textarea>
              <div class="paste-info">
                💡 Tip: {{ t('messages.pasteInfo') }}
                <br>
                <small>{{ t('messages.maxSizes') }}</small>
              </div>
            </div>
            <div class="message-actions">
              <input 
                type="file" 
                ref="fileInput" 
                accept="image/*,video/*" 
                style="display:none" 
                @change="handleFileSelected" 
              />
              <button @click="sendMessage" 
                      class="button primary" 
                      :disabled="!canSendMessage || uploading">
                {{ uploading ? t('messages.uploading') : t('messages.sendMessage') }}
              </button>
            </div>
          </div>
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
      }    .value {
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
    
    .license-buttons {
      display: flex;
      flex-direction: column;
      gap: 4px;
      
      .value.subtle {
        text-align: left;
        font-size: 12px;
        padding: 6px 10px;
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
    
    .media-attachment {
      margin-top: 8px;
      
      .attachment-image {
        max-width: 200px;
        max-height: 200px;
        border-radius: 8px;
        cursor: pointer;
        transition: transform 0.2s;
        
        &:hover {
          transform: scale(1.05);
        }
      }
      
      .attachment-video {
        max-width: 250px;
        max-height: 200px;
        border-radius: 8px;
      }
    }
  }
}

.reply-box {
  padding: 16px;
  border-top: 1px solid theme-var('border');
  display: flex;
  flex-direction: column;
  gap: 12px;
  
  .media-preview {
    .preview-container {
      position: relative;
      display: inline-block;
      max-width: 200px;
      
      .preview-image, .preview-video {
        max-width: 100%;
        max-height: 150px;
        border-radius: 8px;
        border: 1px solid theme-var('border');
      }
      
      .clear-media {
        position: absolute;
        top: -8px;
        right: -8px;
        background: #dc3545;
        color: white;
        border: none;
        border-radius: 50%;
        width: 24px;
        height: 24px;
        cursor: pointer;
        font-size: 16px;
        line-height: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        
        &:hover {
          background: #c82333;
        }
      }
    }
  }
  
  .message-input-container {
    display: flex;
    gap: 12px;
    
    .input-wrapper {
      flex: 1;
      position: relative;
      
      .paste-info {
        font-size: 11px;
        color: theme-var('text-secondary');
        margin-top: 4px;
        opacity: 0.7;
        font-style: italic;
      }
    }
    
    textarea {
      width: 100%;
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
    
    .message-actions {
      display: flex;
      gap: 8px;
      align-items: flex-end;
    }
  }
}

.attach-button {
  background: theme-var('surface');
  border: 1px solid theme-var('border');
  color: theme-var('text-secondary');
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 16px;
  transition: all 0.2s;
  min-width: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  
  &:hover {
    color: theme-var('text');
    background: theme-var('hover');
    border-color: theme-var('button');
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &:active {
    transform: scale(0.95);
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
import { ref, onMounted, nextTick, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ConfirmModal from '@/components/ConfirmModal.vue'
import ToastNotification from '@/components/ToastNotification.vue'
import { usePermissionStore } from '@/stores/permissions'
import { useLang } from '@/composables/useLang'
import { getFiveManageApiKey } from '@/utils/config'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'
import type { Report, Message, MessageContent } from '@/types'
import { format } from 'date-fns'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui
const { t } = useLang()

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()
const report = ref<Report | null>(null)
const messages = ref<MessageContent[]>([])
const loading = ref(true)
const newMessage = ref('')
const currentPlayerId = ref<string>('')
const messagesContainer = ref<HTMLElement | null>(null)

// Media upload variables
const mediaFile = ref<File | null>(null)
const mediaPreview = ref<string | null>(null)
const mediaType = ref<'image' | 'video' | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const uploading = ref(false)

// FiveM Manage API configuration
const FM_API_KEY = ref<string>('')
const IMAGE_ENDPOINT = 'https://fmapi.net/api/v2/image'
const VIDEO_ENDPOINT = 'https://fmapi.net/api/v2/video'

// File size limits (in bytes)
const MAX_IMAGE_SIZE = 32 * 1024 * 1024 // 32 MB
const MAX_VIDEO_SIZE = 32 * 1024 * 1024 // 32 MB

// Helper function to format file size
const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// Validate file size
const validateFileSize = (file: File): { valid: boolean, message?: string } => {
  const isImage = file.type.startsWith('image/')
  const isVideo = file.type.startsWith('video/')
  
  if (isImage && file.size > MAX_IMAGE_SIZE) {
    return {
      valid: false,
      message: `Image too large: ${formatFileSize(file.size)}. Maximum size: ${formatFileSize(MAX_IMAGE_SIZE)}`
    }
  }
  
  if (isVideo && file.size > MAX_VIDEO_SIZE) {
    return {
      valid: false,
      message: `Video too large: ${formatFileSize(file.size)}. Maximum size: ${formatFileSize(MAX_VIDEO_SIZE)}`
    }
  }
  
  return { valid: true }
}

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
  if (!report.value || (!newMessage.value.trim() && !mediaFile.value)) return

  let messageToSend = newMessage.value.trim()
  
  // If media, Upload to FMAPI
  if (mediaFile.value) {
    if (import.meta.env.VITE_DEV === 'true') {
      messageToSend = messageToSend || 'Media attachment'
    } else {
      const mediaUrl = await uploadToFMAPI(mediaFile.value)
      if (mediaUrl) {
        messageToSend = mediaUrl
      } else {
        console.error('Failed to upload media')
        return
      }
    }
    
    // Clear media after upload
    clearMedia()
  }
  
  // Clear input
  newMessage.value = ''

  // Development mode
  if (import.meta.env.VITE_DEV === 'true') {
    const mockMessage: MessageContent = {
      message: messageToSend,
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
    message: messageToSend
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

const deleteReportMedia = async (messages: any[]) => {
  const mediaToDelete: { id: string, type: 'image' | 'video' }[] = [];

  for (const entry of messages) {
    let parsedMessages: any[] = [];

    try {
      parsedMessages = JSON.parse(entry.messages);
    } catch (err) {
      console.error('Failed to parse entry.messages:', err);
      continue;
    }

    for (const msg of parsedMessages) {
      const messageContent = msg.message;

      const mediaIdMatch = messageContent.match(/<!--MEDIA_ID:([a-zA-Z0-9]+)-->/);
      if (!mediaIdMatch || !mediaIdMatch[1]) {
        //console.warn('No MEDIA_ID found in message:', messageContent);
        continue;
      }

      const mediaId = mediaIdMatch[1];

      try {
        const urlPart = messageContent.split('<!--')[0].trim();
        const url = new URL(urlPart);
        const filename = url.pathname.split('/').pop() || '';
        const ext = filename.split('.').pop()?.toLowerCase();

        let type: 'image' | 'video' | null = null;
        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].includes(ext!)) {
          type = 'image';
        } else if (['mp4', 'webm', 'ogg', 'avi', 'mov'].includes(ext!)) {
          type = 'video';
        }

        if (type) {
          mediaToDelete.push({ id: mediaId, type });
        } else {
          console.warn('Unsupported file extension:', ext);
        }
      } catch (err) {
        console.warn('Invalid URL in message:', messageContent);
      }
    }
  }

  for (const media of mediaToDelete) {
    const endpoint = `http://fmapi.net/api/${media.type}/delete/${media.id}`;

    try {
      const response = await fetch(endpoint, {
        method: 'DELETE',
        headers: {
          'Authorization': FM_API_KEY.value,
        }
      });

      if (!response.ok) {
        console.error(`Failed to delete ${media.type} ID: ${media.id.slice(0, 6)}...`, await response.text());
      } else {
        //console.log(`Deleted ${media.type} ID: ${media.id.slice(0, 6)}...`);
      }
    } catch (err) {
      console.error(`Error deleting ${media.type} ID: ${media.id.slice(0, 6)}...`, err);
    }
  }
};

const copyLicense = async (licenseType: string) => {
  if (!report.value) return
  
  try {
    const response = await fetchNui<{success: boolean, license: string}>('getPlayerLicenses', {
      playerLicense: report.value.player_id,
      licenseType: licenseType
    })
    
    if (response?.success && response.license) {
      await copyToClipboard(response.license)
    } else {
      displayToast(`Failed to copy ${licenseType} license\nPlayer might be offline or doesnt have this license!`, 'error')
    }
  } catch (error) {
    console.error('Failed to copy license: Contact Developer', error)
  }
}

const showToast = ref(false)
const toastMessage = ref('')
const toastType = ref<'success' | 'error' | 'warning'>('success')

// Toast notification functions
const displayToast = (message: string, type: 'success' | 'error' | 'warning' = 'success') => {
  toastMessage.value = message
  toastType.value = type
  showToast.value = true
  
  // Auto close after 5 seconds for success and warning
  if (type !== 'error') {
    setTimeout(() => {
      closeToast()
    }, 5000)
  }
}

const closeToast = () => {
  showToast.value = false
  toastMessage.value = ''
}

// Upload file to FiveManage
const uploadToFMAPI = async (file: File): Promise<string | null> => {
  try {
    uploading.value = true
    
    const formData = new FormData()
    formData.append('file', file)
    formData.append('metadata', JSON.stringify({
      name: file.name,
      description: 'Uploaded from Rup-ReportMenu'
    }))
    
    const endpoint = file.type.startsWith('image/') ? IMAGE_ENDPOINT : VIDEO_ENDPOINT
    
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Authorization': FM_API_KEY.value
      },
      body: formData
    })
    
    // Get the raw response text first
    const responseText = await response.text()
    
    // Check for specific errors first (before checking response.ok)
    if (responseText.includes('Unauthorized') || responseText.includes('401') || response.status === 401) {
      displayToast('Upload failed: Authentication error. Please check your API key in config.lua', 'error')
      return null
    }
    
    if (responseText.includes('404') || responseText.includes('Not Found') || response.status === 404) {
      displayToast('Upload failed: API endpoint not found.', 'error')
      return null
    }
    
    if (responseText.includes('413') || responseText.includes('too large') || response.status === 413) {
      const fileType = file.type.startsWith('image/') ? 'image' : 'video'
      const maxSize = fileType === 'image' ? formatFileSize(MAX_IMAGE_SIZE) : formatFileSize(MAX_VIDEO_SIZE)
      displayToast(`Upload failed: File too large (${formatFileSize(file.size)}).\nMaximum ${fileType} size: ${maxSize}.\n\nTip: Compress your file or use a smaller one.`, 'error')
      return null
    }
    
    // Generic error check after specific ones
    if (!response.ok) {
      console.error('Upload failed:', responseText)
      displayToast(`Upload failed: ${response.status} - ${response.statusText}`, 'error')
      return null
    }
    
    // Check if response is JSON
    const contentType = response.headers.get('content-type')
    if (!contentType || !contentType.includes('application/json')) {
      displayToast('Upload failed: Server returned non-JSON response.', 'error')
      return null
    }
    
    // Parse as JSON
    let data
    try {
      data = JSON.parse(responseText)
    } catch (parseError) {
      displayToast(`Failed to parse JSON: ${parseError}`, 'error')
      return null
    }
    
    if (data && data.status === 'ok') {
      // Embed the media ID invisibly so we can delete it later :D
      const messageWithId = `${data.data.url}<!--MEDIA_ID:${data.data.id}-->`
      return messageWithId
    } else {
      console.error('Upload failed. Response data:', data)
      if (data && data.error) {
        console.error('API Error: Contact Developer', data.error)
      }
      return null
    }
  } catch (error) {
    console.error('Upload error:', error)
    if (error instanceof TypeError && error.message.includes('fetch')) {
      console.error('Network error - Contact Developer (CORS | Network)')
    }
    return null
  } finally {
    uploading.value = false
  }
}

// Handle file selection
const handleFileSelected = (event: Event) => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    
    // Validate file size
    const validation = validateFileSize(file)
    if (!validation.valid) {
      displayToast(validation.message || 'File validation failed', 'error')
      if (fileInput.value) fileInput.value.value = '' // Clear the input
      return
    }
    
    mediaFile.value = file
    
    // Determine media type
    mediaType.value = file.type.startsWith('image/') 
      ? 'image' 
      : file.type.startsWith('video/') 
        ? 'video' 
        : null
    
    // Create preview
    if (mediaType.value) {
      const reader = new FileReader()
      reader.onload = (e) => {
        mediaPreview.value = e.target?.result as string
      }
      reader.readAsDataURL(file)
    }
  }
}

// Clear media
const clearMedia = () => {
  mediaFile.value = null
  mediaPreview.value = null
  mediaType.value = null
  if (fileInput.value) fileInput.value.value = ''
}

// Handle paste event for images and videos
const handlePaste = async (event: ClipboardEvent) => {
  const items = event.clipboardData?.items
  if (!items) return

  for (let i = 0; i < items.length; i++) {
    const item = items[i]
    
    // Handle both images and videos
    if (item.type.startsWith('image/') || item.type.startsWith('video/')) {
      event.preventDefault()
      
      const file = item.getAsFile()
      if (file) {
        // Validate file size
        const validation = validateFileSize(file)
        if (!validation.valid) {
          displayToast((validation.message || 'File validation failed') + '\n\nTip: Try compressing the file or use a smaller one.', 'error')
          return
        }
        
        const mediaTypeValue = item.type.startsWith('image/') ? 'image' : 'video'
        //console.log(`${mediaTypeValue} pasted:`, file.name, file.type, formatFileSize(file.size))
        
        mediaFile.value = file
        mediaType.value = mediaTypeValue
        
        // Create preview
        const reader = new FileReader()
        reader.onload = (e) => {
          mediaPreview.value = e.target?.result as string
        }
        reader.readAsDataURL(file)
        
        //console.log(`${mediaTypeValue} Size: ${formatFileSize(file.size)}`)
      }
      break
    }
  }
}

// Check if can send message
const canSendMessage = computed(() => {
  return (newMessage.value.trim() || mediaFile.value) && !uploading.value
})

// Helper function to extract URL from message (removing hidden media ID)
const extractUrlFromMessage = (message: string): string => {
  // Check if message contains hidden media ID
  if (message.includes('<!--MEDIA_ID:')) {
    return message.split('<!--MEDIA_ID:')[0]
  }
  return message
}

// Helper function to check if message is a media URL
const isMediaUrl = (message: string): { isMedia: boolean, type?: 'image' | 'video' } => {
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']
  const videoExtensions = ['.mp4', '.webm', '.ogg', '.avi', '.mov']
  
  // Extract the actual URL part (without hidden ID)
  const url = extractUrlFromMessage(message)
  
  // Check if it's a URL
  try {
    const urlObj = new URL(url)
    const pathname = urlObj.pathname.toLowerCase()
    
    if (imageExtensions.some(ext => pathname.endsWith(ext))) {
      return { isMedia: true, type: 'image' }
    }
    if (videoExtensions.some(ext => pathname.endsWith(ext))) {
      return { isMedia: true, type: 'video' }
    }
  } catch {
    // Not a valid URL
  }
  
  return { isMedia: false }
}

// Open media in new window/tab
const openMedia = (mediaUrl: string) => {
  window.open(mediaUrl, '_blank')
}

onMounted(async () => {
  FM_API_KEY.value = await getFiveManageApiKey()
  
  await loadReport()
  await nextTick()
  await scrollToBottom()
  
  window.addEventListener('message', (event) => {
    if (event.data.type === 'updateMessages' && report.value) {
      updateMessages(event.data.id)
    }

    if (event.data.type === 'deleteReportMedia' && report.value) {
      deleteReportMedia(event.data.messages)
    }
  })
})
</script>