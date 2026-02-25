import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Map',
    component: () => import('@/views/MapView.vue'),
    meta: { title: '地圖探索' }
  },
  {
    path: '/planner',
    name: 'Planner',
    component: () => import('@/views/PlannerView.vue'),
    meta: { title: '行程規劃' }
  },
  {
    path: '/place/:id',
    name: 'PlaceDetail',
    component: () => import('@/views/PlaceDetailView.vue'),
    meta: { title: '景點詳情' }
  },
  {
    path: '/my-trips',
    name: 'MyTrips',
    component: () => import('@/views/MyTripsView.vue'),
    meta: { title: '我的行程' }
  },
  {
    path: '/admin',
    name: 'Admin',
    component: () => import('@/views/AdminView.vue'),
    meta: { title: '後台管理' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || '親子遊玩地圖'} - Family Map`
  next()
})

export default router
