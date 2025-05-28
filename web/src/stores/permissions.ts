import { defineStore } from 'pinia'
import { fetchNui as mockFetchNui } from '@/utils/mockNui'
import { fetchNui as prodFetchNui } from '@/utils/fetchNui'
import type { Permission } from '@/types/permissions'
import { mockPermissions } from '@/types/permissions'

const fetchNui = import.meta.env.VITE_DEV === 'true' ? mockFetchNui : prodFetchNui

export const usePermissionStore = defineStore('permissions', {
  state: () => ({
    permissions: [] as Permission[],
    loaded: false
  }),

  getters: {
    canViewAllReports: (state) => 
      state.permissions.includes('reportmenu.admin.view') || 
      state.permissions.includes('reportmenu.mod.view'),
      
    canManageReports: (state) => 
      state.permissions.includes('reportmenu.admin.manage') ||
      state.permissions.includes('reportmenu.mod.manage'),
      
    canDeleteReports: (state) => 
      state.permissions.includes('reportmenu.admin.delete'),
      
    canCreateReports: (state) => 
      state.permissions.includes('reportmenu.player.create')
  },

  actions: {
    async loadPermissions() {
      if (import.meta.env.VITE_DEV === 'true') {
        const role = import.meta.env.VITE_USER_ROLE || 'player'
        this.permissions = [...mockPermissions[role]] // Convert readonly array to mutable
        this.loaded = true
        return
      }

      try {
        const perms = await fetchNui<Permission[]>('getPermissions', {})
        this.permissions = perms
        this.loaded = true
      } catch (error) {
        console.error('Failed to load permissions:', error)
        this.permissions = ['reportmenu.player.create'] // Fallback to basic permissions
        this.loaded = true
      }
    },

    hasPermission(perm: Permission) {
      return this.permissions.includes(perm)
    }
  }
})