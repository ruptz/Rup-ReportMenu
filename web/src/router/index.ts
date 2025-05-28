import { createRouter, createWebHashHistory } from 'vue-router'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/',
      name: 'reports',
      component: () => import('../views/ReportList.vue')
    },
    {
      path: '/report/new',
      name: 'new-report',
      component: () => import('../views/NewReport.vue')
    },
    {
      path: '/report/:id',
      name: 'report-detail',
      component: () => import('../views/ReportDetail.vue')
    }
  ]
})

export default router