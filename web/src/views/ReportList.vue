<template>
  <div class="dashboard">
    <div class="dashboard-header">      
      <div class="header-content">
        <h1>Reports Dashboard</h1>
        <div class="header-actions">
          <button v-if="permissionStore.canCreateReports" @click="createNewReport" class="button">
            <span class="icon">+</span> New Report
          </button>
          <ThemeToggle class="theme-toggle" />
        </div>
      </div>
    </div>
    
    <div class="dashboard-content">
      <div class="dashboard-sidebar">        
        <div class="sidebar-section">
          <h3>Search</h3>
          <div class="search-box">
            <input 
              type="text" 
              v-model="searchQuery" 
              placeholder="Search by title or ID..."
              class="search-input"
            />
          </div>
        </div>
        <div class="sidebar-section">
          <h3>Filters</h3>
          <div class="filter-options">
            <select v-model="statusFilter">
              <option value="">All Statuses</option>
              <option value="open">Open</option>
              <option value="in_progress">In Progress</option>
              <option value="closed">Closed</option>
            </select>
            <select v-model="priorityFilter">
              <option value="">All Priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>            
            <select v-model="dateFilter">
              <option value="">All Dates</option>
              <option value="oldest">Last Updated (Oldest)</option>
              <option value="newest">Last Updated (Newest)</option>
            </select>
          </div>
        </div>
        
        <div class="sidebar-section">
          <h3>Overview</h3>
          <div class="stats">
              <div class="stat-card">
              <div class="stat-value">{{ reports.length }}</div>
              <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card open">
              <div class="stat-value">{{ reports.filter(r => r.status?.toLowerCase() === 'open').length }}</div>
              <div class="stat-label">Open</div>
            </div>
            <div class="stat-card in-progress">
              <div class="stat-value">{{ reports.filter(r => r.status?.toLowerCase() === 'in_progress').length }}</div>
              <div class="stat-label">In Progress</div>
            </div>
            <div class="stat-card closed">
              <div class="stat-value">{{ reports.filter(r => r.status?.toLowerCase() === 'closed').length }}</div>
              <div class="stat-label">Closed</div>
            </div>
          </div>
        </div>
      </div>

      <div class="reports-grid">
        <div v-if="loading" class="loading">
          <div class="loading-spinner"></div>
          Loading reports...
        </div>
        <div v-else-if="filteredReports.length === 0" class="no-reports">
          <div class="empty-state">
            <span class="material-icons">inbox</span>
            <p>No reports found</p>
          </div>
        </div>
        <div v-else class="report-cards">
          <div v-for="report in filteredReports" :key="report.id" class="report-card" @click="viewReport(report.id)">
            <div class="card-priority" :class="`priority-${report.priority}`"></div>
            <div class="card-content">              
              <div class="card-header">
                <div class="title-group">
                  <span class="report-id">#{{ report.id }}</span>
                  <h3 class="title">{{ truncate(report.title, 30) }}</h3>
                </div>
                <span :class="['status-badge', `status-${report.status}`]">
                  {{ report.status?.replace('_', ' ') || 'Unknown' }}
                </span>
              </div>
              <div class="card-meta">
                <span class="reporter">{{ report.player_name }}</span>
                <span class="date">{{ formatDate(report.updated_at) }}</span>
              </div>
              <p class="description">{{ truncate(report.description, 100) }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { usePermissionStore } from '@/stores/permissions'
import ThemeToggle from '@/components/ThemeToggle.vue'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'
import type { Report } from '@/types'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui
import { format } from 'date-fns'

const router = useRouter()
const permissionStore = usePermissionStore()
const reports = ref<Report[]>([])
const loading = ref(true)
const searchQuery = ref('')
const statusFilter = ref('')
const priorityFilter = ref('')
const dateFilter = ref('')

const filteredReports = computed(() => {
  let filtered = reports.value.filter(report => {
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      const matchesTitle = report.title.toLowerCase().includes(query)
      const matchesId = report.id.toString().includes(query)
      if (!matchesTitle && !matchesId) return false
    }
    if (statusFilter.value && report.status !== statusFilter.value) return false
    if (priorityFilter.value && report.priority !== priorityFilter.value) return false
    return true
  })
  if (dateFilter.value) {
    filtered.sort((a, b) => {
      const dateA = new Date(a.updated_at).getTime()
      const dateB = new Date(b.updated_at).getTime()
      return dateFilter.value === 'oldest' ? dateA - dateB : dateB - dateA
    })
  }

  return filtered
})

const loadReports = async () => {
  try {
    reports.value = await fetchNui('getReports', {})
  } finally {
    loading.value = false
  }
}

const viewReport = (id: number) => {
  router.push(`/report/${id}`)
}

const createNewReport = () => {
  router.push('/report/new')
}

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy HH:mm')
}

const truncate = (text: string, length: number) => {
  if (text.length <= length) return text
  return text.substring(0, length) + '...'
}

onMounted(() => {
  if (!permissionStore.loaded) {
    permissionStore.loadPermissions()
  }
  loadReports()
  window.addEventListener('message', (event) => {
    if (event.data.type === 'updateReports' && reports.value) {
      loadReports()
    }
  })
})
</script>

<style lang="scss" scoped>
@use '@/styles/main.scss' as *;

.dashboard {
  width: 100%;
  max-width: 1400px;  
  background: theme-var('surface');
  min-height: 90vh;
  display: flex;
  flex-direction: column;
  color: theme-var('text');
  border-radius: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.dashboard-header {
  background: theme-var('surface');
  padding: 24px 32px;
  border-bottom: 1px solid theme-var('border');
  
  h1 {
    font-size: 24px;
    font-weight: 500;
    color: theme-var('text');
    margin: 0;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 16px;

    .button {
      background: #1a73e8;
      color: white;
      border: none;
      padding: 8px 24px;
      border-radius: 4px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: background 0.2s;

      &:hover {
        background: #1557b0;
      }
    }
  }
}

.dashboard-content {
  display: flex;
  gap: 24px;
  padding: 24px;
  background: theme-var('background');
  flex: 1;
}

.dashboard-sidebar {
  width: 300px;
  flex-shrink: 0;

  .sidebar-section {
    background: theme-var('surface');
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

    h3 {
      font-size: 16px;
      font-weight: 500;      
      color: theme-var('text-secondary');
      margin-bottom: 16px;
    }
  }

  .filter-options {
    display: flex;
    flex-direction: column;
    gap: 12px;    select {
      width: 100%;
      padding: 8px 12px;
      border: 1px solid theme-var('border');
      border-radius: 4px;
      color: theme-var('text');
      background: theme-var('surface');
      font-size: 14px;

      &:focus {
        outline: none;
        border-color: #1a73e8;
      }
    }
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(1, 1fr);
    gap: 12px; 

    .stat-card {
      background: theme-var('surface');
      border: 1px solid theme-var('border');
      border-radius: 8px;
      padding: 16px;
      text-align: center;  

      &.open {
        border-left: 4px solid var(--success-color);
      }

      &.in-progress {
        border-left: 4px solid var(--warning-color);
      }

      &.closed {
        border-left: 4px solid var(--danger-color);
      }

      .stat-value {
        font-size: 24px;
        font-weight: 500;
        color: #1a73e8;
      }

      .stat-label {
        font-size: 14px;
        color: theme-var('text');
        margin-top: 4px;
      }
    }
  }
}

.reports-grid {
  flex: 1;
  max-height: calc(90vh - 200px);
  overflow-y: auto;
  
  .report-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 16px;
    padding-right: 8px;
  }

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
}

.report-card {
  background: theme-var('surface');
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid theme-var('border');
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: pointer;
  display: flex;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }

  .card-priority {
    width: 4px;
    &.priority-high { background: #ea4335; }
    &.priority-medium { background: #f29900; }
    &.priority-low { background: #34a853; }
  }
  .card-content {
    flex: 1;
    padding: 16px;
    position: relative;

    .notification-dot {
      position: absolute;
      top: 8px;
      right: 8px;
      width: 8px;
      height: 8px;
      background-color: #ea4335;
      border-radius: 50%;
      animation: pulse 2s infinite;
    }
  }

  @keyframes pulse {
    0% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(234, 67, 53, 0.7);
    }
    
    70% {
      transform: scale(1);
      box-shadow: 0 0 0 6px rgba(234, 67, 53, 0);
    }
    
    100% {
      transform: scale(0.95);
      box-shadow: 0 0 0 0 rgba(234, 67, 53, 0);
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;

    .title {
      font-size: 16px;
      font-weight: 500;      
      color: theme-var('text');
      margin: 0;
    }

    .status-badge {
      font-size: 12px;
      font-weight: 500;
      padding: 4px 12px;
      border-radius: 12px;
      text-transform: capitalize; 

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
  }

  .card-meta {
    display: flex;
    justify-content: space-between;
    font-size: 13px;
    color: #5f6368;
    margin-bottom: 8px;
  }

  .description {
    font-size: 14px;
    color: #5f6368;
    margin: 0;
    line-height: 1.4;
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

.empty-state {
  text-align: center;
  padding: 48px;
  color: #5f6368;

  .material-icons {
    font-size: 48px;
    margin-bottom: 16px;
    color: #dadce0;
  }
}

.theme-toggle {
  margin-left: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.title-group {
      display: flex;
      align-items: center;
      gap: 8px;

      .report-id {
        font-size: 14px;
        font-weight: 600;
        color: theme-var('text-secondary');
        background: theme-var('background');
        padding: 2px 6px;
        border-radius: 4px;
        min-width: 32px;
        text-align: center;
      }
    }

.search-box {
    margin-bottom: 8px;
    
    .search-input {
      width: 100%;
      padding: 8px 12px;
      border: 1px solid theme-var('border');
      border-radius: 4px;
      color: theme-var('text');
      background: theme-var('surface');
      font-size: 14px;

      &:focus {
        outline: none;
        border-color: #1a73e8;
      }

      &::placeholder {
        color: theme-var('text-secondary');
      }
    }
  }
</style>