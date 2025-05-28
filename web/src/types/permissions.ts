export type Permission = 
  | 'reportmenu.admin.view'
  | 'reportmenu.admin.manage'
  | 'reportmenu.admin.delete'
  | 'reportmenu.mod.view'
  | 'reportmenu.mod.manage'
  | 'reportmenu.player.create'

export const mockPermissions: Record<string, Permission[]> = {
  admin: [
    'reportmenu.admin.view',
    'reportmenu.admin.manage',
    'reportmenu.admin.delete',
    'reportmenu.player.create'
  ],
  mod: [
    'reportmenu.mod.view',
    'reportmenu.mod.manage',
    'reportmenu.player.create'
  ],
  player: [
    'reportmenu.player.create'
  ]
} as const