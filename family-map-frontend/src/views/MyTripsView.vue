<template>
  <div class="max-w-4xl mx-auto p-6">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">我的行程</h1>

    <div v-if="trips.length === 0" class="text-center py-12">
      <div class="text-gray-400 text-6xl mb-4">📝</div>
      <p class="text-gray-500">您還沒有建立任何行程</p>
      <router-link
        to="/planner"
        class="inline-block mt-4 bg-primary-500 text-white px-6 py-2 rounded-lg hover:bg-primary-600 transition-colors"
      >
        開始規劃行程
      </router-link>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="trip in trips"
        :key="trip.id"
        class="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow p-6"
      >
        <div class="flex items-start justify-between">
          <div>
            <h3 class="font-bold text-lg text-gray-800">{{ trip.name }}</h3>
            <p class="text-sm text-gray-500 mt-1">
              {{ formatDate(trip.startDate) }} - {{ formatDate(trip.endDate) }}
            </p>
            <p class="text-sm text-gray-500">
              同行孩童: {{ trip.childAge }} 歲
            </p>
          </div>
          <div class="flex items-center gap-2">
            <button
              @click="viewTrip(trip)"
              class="text-primary-500 hover:text-primary-600"
            >
              查看詳情
            </button>
            <button
              @click="deleteTrip(trip)"
              class="text-red-500 hover:text-red-600"
            >
              刪除
            </button>
          </div>
        </div>

        <!-- 行程預覽 -->
        <div class="mt-4 flex gap-2 overflow-x-auto pb-2">
          <div
            v-for="(place, index) in trip.places.slice(0, 5)"
            :key="place.id"
            class="flex items-center flex-shrink-0"
          >
            <div class="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-primary-700 font-medium">
              {{ index + 1 }}
            </div>
            <span class="ml-2 text-sm text-gray-600">{{ place.name }}</span>
            <span v-if="index < Math.min(trip.places.length, 5) - 1" class="mx-2 text-gray-300">→</span>
          </div>
          <span v-if="trip.places.length > 5" class="text-sm text-gray-400 flex-shrink-0">
            +{{ trip.places.length - 5 }} 更多
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { formatDate as formatDateUtil } from '@/utils/timeCalculator'

const router = useRouter()

const trips = ref([])

onMounted(() => {
  // TODO: 從 API 載入行程
  // 模擬資料
  trips.value = [
    {
      id: 1,
      name: '台中親子一日遊',
      startDate: '2024-03-20',
      endDate: '2024-03-20',
      childAge: 5,
      places: [
        { id: 1, name: '國立自然科學博物館' },
        { id: 2, name: '台中公園' },
        { id: 3, name: '審計新村' },
        { id: 4, name: '勤美誠品綠園道' },
        { id: 5, name: '秋紅谷景觀生態公園' },
        { id: 6, name: '望高寮夜景公園' }
      ]
    },
    {
      id: 2,
      name: '台北親子二日遊',
      startDate: '2024-04-05',
      endDate: '2024-04-06',
      childAge: 8,
      places: [
        { id: 7, name: '台北市立動物園' },
        { id: 8, name: '貓空纜車' },
        { id: 9, name: '兒童新樂園' }
      ]
    }
  ]
})

function formatDate(date) {
  return formatDateUtil(date)
}

function viewTrip(trip) {
  // TODO: 導向行程詳情頁
  console.log('View trip:', trip)
  alert('功能開發中')
}

function deleteTrip(trip) {
  if (confirm(`確定要刪除「${trip.name}」嗎？`)) {
    trips.value = trips.value.filter(t => t.id !== trip.id)
    // TODO: 呼叫 API 刪除
  }
}
</script>
