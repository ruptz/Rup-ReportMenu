export interface Report {
  id: number
  player_id: string
  player_name: string
  reported_id?: string
  reported_name?: string
  title: string
  description: string
  status: 'open' | 'in_progress' | 'closed'
  priority: 'low' | 'medium' | 'high'
  created_at: string
  updated_at: string
}

export interface MessageContent {
  message: string
  sent_at: string
  sender_name: string
  sender_id: string
  isOwnMessage?: boolean
}

export interface Message {
  id: number
  report_id: number
  messages: MessageContent[]
  created_at: string
}