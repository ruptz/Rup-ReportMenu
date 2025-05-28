import { mockReports, mockUserPreferences, type Report, type Message, type UserPreferences } from './mockData'
let mockMessages = [] as Message[]

// Mock implementation of fetchNui for browser development
export const fetchNui = async <T>(eventName: string, data: any): Promise<T> => {
  switch (eventName) {    case 'getReports':
      const role = import.meta.env.VITE_USER_ROLE || 'player'
      if (role === 'admin' || role === 'mod') {
        return mockReports as T
      }
      // Players only see their own reports
      return mockReports.filter(r => r.player_id === 'STEAM:LOCAL') as T
      
    case 'getReportMessages':
      return mockMessages.filter(m => m.report_id === data.reportId) as T
    
    case 'createReport':
      const newReport: Report = {
        id: mockReports.length + 1,
        player_id: 'STEAM:LOCAL',
        player_name: 'Local Test User',        ...data,
        status: 'open',
        priority: data.priority || 'medium',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      mockReports.push(newReport)
      return { success: true, reportId: newReport.id } as T
      
    case 'addMessage':
      const newMessage: Message = {
        id: mockMessages.length + 1,
        report_id: data.report_id,
        sender_id: 'STEAM:LOCAL',
        sender_name: 'Local Test User',
        message: data.message,
        created_at: new Date().toISOString()
      }
      mockMessages.push(newMessage)
      return { success: true, messageId: newMessage.id } as T
      
    case 'deleteReport':
      const reportIndex = mockReports.findIndex(r => r.id === data.reportId)
      if (reportIndex !== -1) {
        mockReports.splice(reportIndex, 1)
        // Also remove associated messages
        mockMessages = mockMessages.filter(m => m.report_id !== data.reportId)
        return { success: true } as T
      }
      return { success: false } as T
      case 'getUserPreferences':
      return { theme: mockUserPreferences.theme } as T
      
    case 'updateUserPreferences':
      mockUserPreferences.theme = data.theme
      return { success: true } as T
      
    default:
      return { success: true } as T
  }
}