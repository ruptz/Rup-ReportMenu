import { defineStore } from 'pinia'
import { fetchNui } from '@/utils/fetchNui'

interface Report {
  id: number
  player_id: string
  player_name: string
  reported_id: string | null
  reported_name: string | null
  title: string
  description: string
  status: 'open' | 'in_progress' | 'closed'
  priority: 'low' | 'medium' | 'high'
  created_at: string
  updated_at: string
}

interface Message {
  id: number
  report_id: number
  sender_id: string
  sender_name: string
  message: string
  created_at: string
}

export const useReportStore = defineStore('reports', {
  state: () => ({
    reports: [] as Report[],
    messages: {} as Record<number, Message[]>,
    loading: false,
    error: null as string | null,
  }),

  actions: {
    async fetchReports() {
      this.loading = true
      try {
        const reports = await fetchNui<Report[]>('getReports', {})
        this.reports = reports
      } catch (error) {
        this.error = 'Failed to fetch reports'
      } finally {
        this.loading = false
      }
    },

    async createReport(data: Partial<Report>) {
      try {
        const response = await fetchNui<{success: boolean, reportId: number}>('createReport', data)
        if (response.success) {
          await this.fetchReports()
          return response.reportId
        }
      } catch (error) {
        this.error = 'Failed to create report'
        return null
      }
    },

    async updateReport(reportId: number, updates: Partial<Report>) {
      try {
        const response = await fetchNui<{success: boolean}>('updateReport', {
          reportId,
          updates
        })
        if (response.success) {
          await this.fetchReports()
          return true
        }
      } catch (error) {
        this.error = 'Failed to update report'
        return false
      }
    },

    async addMessage(reportId: number, message: string) {
      try {
        const response = await fetchNui<{success: boolean, messageId: number}>('addMessage', {
          report_id: reportId,
          message
        })
        if (response.success) {
          // Update messages
          if (!this.messages[reportId]) {
            this.messages[reportId] = []
          }
          this.messages[reportId].push({
            id: response.messageId,
            report_id: reportId,
            message,
            created_at: new Date().toISOString(),
          } as Message)
          return true
        }
      } catch (error) {
        this.error = 'Failed to send message'
        return false
      }
    }
  }
})