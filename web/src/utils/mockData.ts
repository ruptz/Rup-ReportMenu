import { format, subHours } from 'date-fns'

export interface Report {
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

export interface Message {
  id: number
  report_id: number
  sender_id: string
  sender_name: string
  message: string
  created_at: string
}

export interface UserPreferences {
  theme: 'light' | 'dark'
}

export const mockReports: Report[] = [
  {
    id: 1,
    player_id: 'STEAM:123',
    player_name: 'John Doe',
    reported_id: 'STEAM:456',
    reported_name: 'Jane Smith',
    title: 'Vehicle Griefing',
    description: 'Player repeatedly ramming into my vehicle',
    status: 'open',
    priority: 'high',
    created_at: format(subHours(new Date(), 2), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 2), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 2,
    player_id: 'STEAM:789',
    player_name: 'Mike Johnson',
    reported_id: null,
    reported_name: null,
    title: 'Game Bug',
    description: 'Cannot access garage menu',
    status: 'in_progress',
    priority: 'medium',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 3,
    player_id: 'STEAM:909',
    player_name: 'John Johnson',
    reported_id: null,
    reported_name: null,
    title: 'Game Bug',
    description: 'Frozen screen when entering vehicle',
    status: 'closed',
    priority: 'low',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 4,
    player_id: 'STEAM:919',
    player_name: 'John Jacobs',
    reported_id: null,
    reported_name: null,
    title: 'RDM At Legion',
    description: 'Player shot me for no reason at Legion Square',
    status: 'open',
    priority: 'high',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 5,
    player_id: 'STEAM:929',
    player_name: 'John Jackson',
    reported_id: null,
    reported_name: null,
    title: 'Player Harassment',
    description: 'Player keeps following me and saying rude things',
    status: 'open',
    priority: 'medium',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 6,
    player_id: 'STEAM:829',
    player_name: 'Paul Smith',
    reported_id: null,
    reported_name: null,
    title: 'Killing In Safe Zone',
    description: 'Player is killing me in a safe zone',
    status: 'open',
    priority: 'low',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 7,
    player_id: 'STEAM:729',
    player_name: 'Ben Lawson',
    reported_id: null,
    reported_name: null,
    title: 'Bugged Vehicle',
    description: 'My vehicle is stuck in the garage, My plate is 123ABC',
    status: 'in_progress',
    priority: 'low',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 8,
    player_id: 'STEAM:481',
    player_name: 'Alcia Parker',
    reported_id: null,
    reported_name: null,
    title: 'Garbage Job Bugged!',
    description: 'I cannot pick up garbage bags, I am stuck in the job',
    status: 'closed',
    priority: 'medium',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 9,
    player_id: 'STEAM:291',
    player_name: 'Trevor Phillips',
    reported_id: null,
    reported_name: null,
    title: 'Ciggarette Bugged!',
    description: 'I cannot smoke a cig!',
    status: 'in_progress',
    priority: 'high',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 10,
    player_id: 'STEAM:329',
    player_name: 'Lorena Smith',
    reported_id: null,
    reported_name: null,
    title: 'Cant eat food!',
    description: 'I am hungry but I cannot eat food!',
    status: 'open',
    priority: 'high',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 11,
    player_id: 'STEAM:729',
    player_name: 'Jake Paul',
    reported_id: null,
    reported_name: null,
    title: 'Cant fight!',
    description: 'I cannot fight with my fists!',
    status: 'open',
    priority: 'low',
    created_at: format(subHours(new Date(), 5), 'yyyy-MM-dd HH:mm:ss'),
    updated_at: format(subHours(new Date(), 3), 'yyyy-MM-dd HH:mm:ss')
  },
]

export const mockMessages: Message[] = [
  {
    id: 1,
    report_id: 1,
    sender_id: 'STEAM:123',
    sender_name: 'John Doe',
    message: 'This has been happening for 30 minutes now',
    created_at: format(subHours(new Date(), 1), 'yyyy-MM-dd HH:mm:ss')
  },
  {
    id: 2,
    report_id: 1,
    sender_id: 'ADMIN:1',
    sender_name: 'Admin Alice',
    message: 'We will look into this right away',
    created_at: format(subHours(new Date(), 0.5), 'yyyy-MM-dd HH:mm:ss')
  }
]

export const mockUserPreferences: UserPreferences = {
  theme: 'light'
}