<template>
  <div class="min-h-screen flex">
    <!-- 側邊欄 -->
    <aside class="w-64 bg-gray-900 text-white flex-shrink-0">
      <div class="p-4 border-b border-gray-800">
        <div class="flex items-center space-x-2">
          <span class="text-2xl">🗺️</span>
          <span class="font-bold">管理後台</span>
        </div>
      </div>

      <nav class="p-4 space-y-1">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          class="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors"
          :class="isActive(item.path)
            ? 'bg-primary-600 text-white'
            : 'text-gray-300 hover:bg-gray-800'"
        >
          <span>{{ item.icon }}</span>
          <span>{{ item.title }}</span>
          <span
            v-if="item.badge"
            class="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full"
          >
            {{ item.badge }}
          </span>
        </router-link>
      </nav>

      <!-- 底部登出 -->
      <div class="absolute bottom-0 left-0 w-64 p-4 border-t border-gray-800">
        <button
          @click="handleLogout"
          class="flex items-center space-x-3 text-gray-400 hover:text-white transition-colors w-full px-4 py-2"
        >
          <span>🚪</span>
          <span>登出</span>
        </button>
      </div>
    </aside>

    <!-- 主要內容區 -->
    <div class="flex-1 flex flex-col">
      <!-- 頂部列 -->
      <header class="bg-white border-b h-16 flex items-center justify-between px-6">
        <h1 class="text-xl font-semibold text-gray-800">{{ pageTitle }}</h1>

        <div class="flex items-center space-x-4">
          <span class="text-gray-500">歡迎，{{ authStore.username || '管理員' }}</span>
          <div class="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-primary-600">
            {{ (authStore.username || 'A')[0].toUpperCase() }}
          </div>
        </div>
      </header>

      <!-- 頁面內容 -->
      <main class="flex-1 p-6 overflow-y-auto">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { useReviewsStore } from '@/stores/reviewsStore'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const reviewsStore = useReviewsStore()

const menuItems = computed(() => [
  { path: '/dashboard', title: '儀表板', icon: '📊' },
  { path: '/places', title: '景點管理', icon: '📍' },
  { path: '/infrastructure-types', title: '設施類型管理', icon: '🏷️' },
  { path: '/reviews', title: '審核管理', icon: '✅', badge: reviewsStore.pendingPlaces.length || null },
  { path: '/users', title: '使用者管理', icon: '👥' }
])

const pageTitle = computed(() => {
  return route.meta.title || '管理後台'
})

function isActive(path) {
  return route.path === path || route.path.startsWith(path + '/')
}

function handleLogout() {
  if (confirm('確定要登出嗎？')) {
    authStore.logout()
    router.push('/login')
  }
}
</script>
