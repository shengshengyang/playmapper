import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false, title: '登入' }
  },
  {
    path: '/',
    component: () => import('@/views/LayoutView.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/dashboard'
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
        meta: { title: '儀表板' }
      },
      {
        path: 'places',
        name: 'Places',
        component: () => import('@/views/PlacesView.vue'),
        meta: { title: '景點管理' }
      },
      {
        path: 'places/add',
        name: 'AddPlace',
        component: () => import('@/views/PlaceFormView.vue'),
        meta: { title: '新增景點' }
      },
      {
        path: 'places/:id/edit',
        name: 'EditPlace',
        component: () => import('@/views/PlaceFormView.vue'),
        meta: { title: '編輯景點' }
      },
      {
        path: 'reviews',
        name: 'Reviews',
        component: () => import('@/views/ReviewsView.vue'),
        meta: { title: '審核管理' }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/UsersView.vue'),
        meta: { title: '使用者管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || '管理後台'} - 親子遊玩地圖`

  const authStore = useAuthStore()

  if (to.meta.requiresAuth !== false && !authStore.isLoggedIn) {
    next('/login')
  } else if (to.path === '/login' && authStore.isLoggedIn) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
