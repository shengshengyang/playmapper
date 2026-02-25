<template>
  <div class="space-y-6">
    <!-- 統計 -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">待審核</p>
            <p class="text-3xl font-bold text-orange-500 mt-1">{{ pendingPlaces.length }}</p>
          </div>
          <div class="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center text-2xl">
            ⏳
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">今日已審核</p>
            <p class="text-3xl font-bold text-green-500 mt-1">{{ todayReviewed }}</p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-2xl">
            ✅
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">本月已審核</p>
            <p class="text-3xl font-bold text-blue-500 mt-1">{{ monthReviewed }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-2xl">
            📊
          </div>
        </div>
      </div>
    </div>

    <!-- 待審核列表 -->
    <div class="bg-white rounded-xl shadow-sm">
      <div class="p-6 border-b">
        <h2 class="text-lg font-semibold text-gray-800">待審核景點</h2>
      </div>

      <div v-if="loading" class="p-12 text-center">
        <div class="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full mx-auto"></div>
        <p class="mt-4 text-gray-500">載入中...</p>
      </div>

      <div v-else-if="pendingPlaces.length === 0" class="p-12 text-center">
        <div class="text-gray-300 text-5xl mb-4">✅</div>
        <p class="text-gray-500">太棒了！目前沒有待審核的景點</p>
      </div>

      <div v-else class="divide-y">
        <div
          v-for="place in pendingPlaces"
          :key="place.id"
          class="p-6 hover:bg-gray-50"
        >
          <div class="flex items-start gap-4">
            <!-- 圖片 -->
            <div class="w-24 h-24 bg-gray-200 rounded-lg flex-shrink-0 flex items-center justify-center">
              <span v-if="place.images?.length" class="text-3xl">🏞️</span>
              <span v-else class="text-3xl text-gray-400">📍</span>
            </div>

            <!-- 資訊 -->
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between">
                <div>
                  <h3 class="font-semibold text-gray-800 text-lg">{{ place.name }}</h3>
                  <p class="text-gray-500 text-sm mt-1">{{ place.address }}</p>
                </div>
                <span class="text-sm text-gray-400">
                  提交於 {{ formatDate(place.createdAt) }}
                </span>
              </div>

              <div class="mt-3 flex flex-wrap gap-4 text-sm text-gray-600">
                <span>適合年齡: {{ place.minAge || 0 }} - {{ place.maxAge || 18 }} 歲</span>
                <span v-if="place.suggestedDurationMinutes">
                  建議停留: {{ place.suggestedDurationMinutes }} 分鐘
                </span>
                <span v-if="place.ticketPrice">
                  票價: NT$ {{ place.ticketPrice }}
                </span>
              </div>

              <p v-if="place.description" class="mt-3 text-gray-600 text-sm line-clamp-2">
                {{ place.description }}
              </p>

              <!-- 設施標籤 -->
              <div v-if="place.facilities?.length" class="mt-3 flex flex-wrap gap-2">
                <span
                  v-for="facility in place.facilities"
                  :key="facility"
                  class="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded"
                >
                  {{ facility }}
                </span>
              </div>
            </div>
          </div>

          <!-- 操作按鈕 -->
          <div class="mt-4 pt-4 border-t flex items-center justify-between">
            <div class="text-sm text-gray-500">
              提交者: {{ place.submitterId ? `使用者 #${place.submitterId}` : '系統' }}
            </div>
            <div class="flex gap-3">
              <button
                @click="showDetail(place)"
                class="px-4 py-2 border rounded-lg hover:bg-gray-100 transition-colors"
              >
                查看詳情
              </button>
              <button
                @click="showRejectDialog(place)"
                class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
              >
                拒絕
              </button>
              <button
                @click="handleApprove(place)"
                class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
              >
                通過
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 拒絕原因對話框 -->
    <div
      v-if="rejectingPlace"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-xl max-w-md w-full m-4">
        <div class="p-6 border-b">
          <h3 class="text-lg font-semibold">拒絕景點</h3>
        </div>
        <div class="p-6">
          <p class="text-gray-600 mb-4">
            您即將拒絕「{{ rejectingPlace.name }}」，請輸入拒絕原因：
          </p>
          <textarea
            v-model="rejectReason"
            rows="4"
            class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-red-500"
            placeholder="請說明拒絕原因，此資訊將發送給提交者..."
          ></textarea>
        </div>
        <div class="p-6 border-t flex justify-end gap-3">
          <button
            @click="cancelReject"
            class="px-4 py-2 border rounded-lg hover:bg-gray-100"
          >
            取消
          </button>
          <button
            @click="confirmReject"
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
          >
            確認拒絕
          </button>
        </div>
      </div>
    </div>

    <!-- 詳情對話框 -->
    <div
      v-if="viewingPlace"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="viewingPlace = null"
    >
      <div class="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto m-4">
        <div class="p-6 border-b flex items-center justify-between">
          <h3 class="text-lg font-semibold">{{ viewingPlace.name }}</h3>
          <button @click="viewingPlace = null" class="text-gray-400 hover:text-gray-600">✕</button>
        </div>
        <div class="p-6 space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="text-sm text-gray-500">地址</label>
              <p>{{ viewingPlace.address || '-' }}</p>
            </div>
            <div>
              <label class="text-sm text-gray-500">適合年齡</label>
              <p>{{ viewingPlace.minAge || 0 }} - {{ viewingPlace.maxAge || 18 }} 歲</p>
            </div>
            <div>
              <label class="text-sm text-gray-500">建議停留時間</label>
              <p>{{ viewingPlace.suggestedDurationMinutes || 60 }} 分鐘</p>
            </div>
            <div>
              <label class="text-sm text-gray-500">票價</label>
              <p>{{ viewingPlace.ticketPrice ? `NT$ ${viewingPlace.ticketPrice}` : '免費' }}</p>
            </div>
            <div>
              <label class="text-sm text-gray-500">緯度</label>
              <p>{{ viewingPlace.latitude || '-' }}</p>
            </div>
            <div>
              <label class="text-sm text-gray-500">經度</label>
              <p>{{ viewingPlace.longitude || '-' }}</p>
            </div>
          </div>
          <div>
            <label class="text-sm text-gray-500">描述</label>
            <p class="mt-1">{{ viewingPlace.description || '-' }}</p>
          </div>
          <div>
            <label class="text-sm text-gray-500">設施</label>
            <div class="flex flex-wrap gap-2 mt-1">
              <span
                v-for="facility in viewingPlace.facilities"
                :key="facility"
                class="px-2 py-1 bg-gray-100 rounded text-sm"
              >
                {{ facility }}
              </span>
              <span v-if="!viewingPlace.facilities?.length" class="text-gray-400">無</span>
            </div>
          </div>
          <div>
            <label class="text-sm text-gray-500">聯絡資訊</label>
            <p>{{ viewingPlace.phone || '-' }}</p>
            <p>{{ viewingPlace.website || '-' }}</p>
          </div>
        </div>
        <div class="p-6 border-t flex justify-end gap-3">
          <button
            @click="showRejectDialog(viewingPlace); viewingPlace = null"
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
          >
            拒絕
          </button>
          <button
            @click="handleApprove(viewingPlace); viewingPlace = null"
            class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600"
          >
            通過
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useReviewsStore } from '@/stores/reviewsStore'
import dayjs from 'dayjs'

const reviewsStore = useReviewsStore()

const loading = ref(false)
const pendingPlaces = ref([])
const todayReviewed = ref(3)
const monthReviewed = ref(28)

const rejectingPlace = ref(null)
const rejectReason = ref('')
const viewingPlace = ref(null)

onMounted(async () => {
  loading.value = true
  await reviewsStore.fetchPendingPlaces()
  pendingPlaces.value = reviewsStore.pendingPlaces

  // 模擬資料
  if (pendingPlaces.value.length === 0) {
    pendingPlaces.value = [
      {
        id: 1,
        name: '新月湖公園',
        address: '台中市北屯區新月湖路100號',
        minAge: 0,
        maxAge: 10,
        suggestedDurationMinutes: 90,
        description: '大型親子公園，設有遊樂設施、沙坑、溜滑梯等多種設施，適合全家大小同遊。',
        facilities: ['遊樂場', '沙坑', '溜滑梯', '停車場', '廁所'],
        createdAt: '2024-03-20T10:30:00'
      },
      {
        id: 2,
        name: '兒童創意樂園',
        address: '台中市西屯區台灣大道三段',
        minAge: 2,
        maxAge: 12,
        suggestedDurationMinutes: 120,
        ticketPrice: 200,
        description: '室內親子遊樂園，有多種創意遊戲區和DIY活動。',
        facilities: ['室內遊戲區', 'DIY教室', '餐廳', '哺集乳室'],
        createdAt: '2024-03-19T14:20:00'
      }
    ]
  }

  loading.value = false
})

function formatDate(date) {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

function showDetail(place) {
  viewingPlace.value = place
}

function showRejectDialog(place) {
  rejectingPlace.value = place
  rejectReason.value = ''
}

function cancelReject() {
  rejectingPlace.value = null
  rejectReason.value = ''
}

async function handleApprove(place) {
  if (!confirm(`確定要通過「${place.name}」嗎？`)) return

  const result = await reviewsStore.approvePlace(place.id)
  if (result.success) {
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== place.id)
    todayReviewed.value++
    monthReviewed.value++
    alert('審核通過')
  } else {
    alert(result.message || '操作失敗')
  }
}

async function confirmReject() {
  const result = await reviewsStore.rejectPlace(rejectingPlace.value.id, rejectReason.value)
  if (result.success) {
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== rejectingPlace.value.id)
    todayReviewed.value++
    monthReviewed.value++
    cancelReject()
    alert('已拒絕')
  } else {
    alert(result.message || '操作失敗')
  }
}
</script>
