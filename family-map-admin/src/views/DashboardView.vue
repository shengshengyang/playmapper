<template>
  <div class="space-y-6">
    <!-- 統計卡片 -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">總景點數</p>
            <p class="text-3xl font-bold text-gray-800 mt-1">{{ stats.totalPlaces }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-2xl">
            📍
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">待審核</p>
            <p class="text-3xl font-bold text-orange-500 mt-1">{{ stats.pendingReview }}</p>
          </div>
          <div class="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center text-2xl">
            ⏳
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">已通過</p>
            <p class="text-3xl font-bold text-green-500 mt-1">{{ stats.approved }}</p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-2xl">
            ✅
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">註冊使用者</p>
            <p class="text-3xl font-bold text-purple-500 mt-1">{{ stats.totalUsers }}</p>
          </div>
          <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center text-2xl">
            👥
          </div>
        </div>
      </div>
    </div>

    <!-- 圖表區域 -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white rounded-xl shadow-sm p-6">
        <h3 class="font-semibold text-gray-800 mb-4">審核狀態分布</h3>
        <div class="h-64">
          <StatusChart :stats="stats" />
        </div>
      </div>
      <div class="bg-white rounded-xl shadow-sm p-6">
        <h3 class="font-semibold text-gray-800 mb-4">本月新增</h3>
        <div class="h-64">
          <MonthlyChart :monthly-new="stats.monthlyNew" />
        </div>
      </div>
    </div>

    <!-- 快捷操作 -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- 待審核列表 -->
      <div class="bg-white rounded-xl shadow-sm">
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="font-semibold text-gray-800">待審核景點</h2>
          <router-link to="/reviews" class="text-primary-600 text-sm hover:underline">
            查看全部
          </router-link>
        </div>
        <div class="p-4">
          <div v-if="pendingPlaces.length === 0" class="text-center py-8 text-gray-400">
            目前沒有待審核的景點
          </div>
          <div v-else class="space-y-3">
            <div
              v-for="place in pendingPlaces.slice(0, 5)"
              :key="place.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div>
                <h3 class="font-medium text-gray-800">{{ place.name }}</h3>
                <p class="text-sm text-gray-500">{{ place.address }}</p>
              </div>
              <div class="flex gap-2">
                <button
                  @click="quickApprove(place)"
                  class="px-3 py-1 bg-green-500 text-white text-sm rounded hover:bg-green-600"
                >
                  通過
                </button>
                <button
                  @click="quickReject(place)"
                  class="px-3 py-1 bg-red-500 text-white text-sm rounded hover:bg-red-600"
                >
                  拒絕
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 最近活動 -->
      <div class="bg-white rounded-xl shadow-sm">
        <div class="p-4 border-b">
          <h2 class="font-semibold text-gray-800">最近活動</h2>
        </div>
        <div class="p-4">
          <div class="space-y-4">
            <div
              v-for="activity in recentActivities"
              :key="activity.id"
              class="flex items-start space-x-3"
            >
              <div
                class="w-8 h-8 rounded-full flex items-center justify-center text-sm"
                :class="getActivityColor(activity.type)"
              >
                {{ getActivityIcon(activity.type) }}
              </div>
              <div class="flex-1">
                <p class="text-gray-800">{{ activity.message }}</p>
                <p class="text-sm text-gray-400">{{ activity.time }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useReviewsStore } from '@/stores/reviewsStore'
import { statisticsApi } from '@/services/api'
import StatusChart from '@/components/charts/StatusChart.vue'
import MonthlyChart from '@/components/charts/MonthlyChart.vue'

const reviewsStore = useReviewsStore()

const stats = ref({
  totalPlaces: 0,
  pendingReview: 0,
  approved: 0,
  rejected: 0,
  totalUsers: 0,
  monthlyNew: 0
})

const pendingPlaces = ref([])

const recentActivities = ref([])

onMounted(async () => {
  // 獲取統計數據
  try {
    const response = await statisticsApi.getStats()
    stats.value = response.data
  } catch (error) {
    console.error('Failed to fetch statistics:', error)
  }

  // 獲取待審核景點
  await reviewsStore.fetchPendingPlaces()
  pendingPlaces.value = reviewsStore.pendingPlaces
})

async function quickApprove(place) {
  const result = await reviewsStore.approvePlace(place.id)
  if (result.success) {
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== place.id)
    stats.value.pendingReview--
    stats.value.approved++
    // 重新獲取統計數據
    try {
      const response = await statisticsApi.getStats()
      stats.value = response.data
    } catch (error) {
      console.error('Failed to refresh statistics:', error)
    }
  }
}

async function quickReject(place) {
  const reason = prompt('請輸入拒絕原因（選填）：')
  const result = await reviewsStore.rejectPlace(place.id, reason || '')
  if (result.success) {
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== place.id)
    stats.value.pendingReview--
    // 重新獲取統計數據
    try {
      const response = await statisticsApi.getStats()
      stats.value = response.data
    } catch (error) {
      console.error('Failed to refresh statistics:', error)
    }
  }
}

function getActivityColor(type) {
  const colors = {
    approve: 'bg-green-100 text-green-600',
    reject: 'bg-red-100 text-red-600',
    create: 'bg-blue-100 text-blue-600',
    edit: 'bg-yellow-100 text-yellow-600',
    user: 'bg-purple-100 text-purple-600'
  }
  return colors[type] || 'bg-gray-100 text-gray-600'
}

function getActivityIcon(type) {
  const icons = {
    approve: '✓',
    reject: '✕',
    create: '+',
    edit: '✎',
    user: '👤'
  }
  return icons[type] || '•'
}
</script>
