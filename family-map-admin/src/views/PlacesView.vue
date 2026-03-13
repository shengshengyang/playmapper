<template>
  <div class="space-y-6">
    <!-- 頂部操作列 -->
    <div class="bg-white rounded-xl shadow-sm p-4">
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <!-- 搜尋 -->
        <div class="relative flex-1 max-w-md">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜尋景點名稱或地址..."
            class="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          />
          <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
        </div>

        <div class="flex items-center gap-3">
          <!-- 狀態篩選 -->
          <select
            v-model="statusFilter"
            class="px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
          >
            <option value="">全部狀態</option>
            <option value="approved">已通過</option>
            <option value="pending">待審核</option>
            <option value="rejected">已拒絕</option>
          </select>

          <!-- 新增按鈕 -->
          <router-link
            to="/places/add"
            class="bg-primary-500 text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors flex items-center gap-2"
          >
            <span>+</span>
            <span>新增景點</span>
          </router-link>
        </div>
      </div>
    </div>

    <!-- 景點列表 -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">景點</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">地址</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">適合年齡</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">狀態</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">評分</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr
            v-for="place in filteredPlaces"
            :key="place.id"
            class="hover:bg-gray-50"
          >
            <td class="px-6 py-4">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center text-gray-400 mr-3">
                  <span v-if="place.images?.length">🏞️</span>
                  <span v-else>📍</span>
                </div>
                <div>
                  <div class="font-medium text-gray-900">{{ place.name }}</div>
                  <div class="text-sm text-gray-500">ID: {{ place.id }}</div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 text-sm text-gray-500 max-w-xs truncate">
              {{ place.address || '-' }}
            </td>
            <td class="px-6 py-4">
              <span class="text-sm text-gray-600">{{ place.minAge || 0 }} - {{ place.maxAge || 18 }} 歲</span>
            </td>
            <td class="px-6 py-4">
              <span
                class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                :class="getStatusClass(place.status)"
              >
                {{ getStatusText(place.status) }}
              </span>
            </td>
            <td class="px-6 py-4">
              <span class="text-sm text-gray-600">
                ⭐ {{ place.rating?.toFixed(1) || '-' }}
                <span class="text-gray-400">({{ place.reviewCount || 0 }})</span>
              </span>
            </td>
            <td class="px-6 py-4 text-right">
              <div class="flex justify-end gap-2">
                <button
                  @click="viewPlace(place)"
                  class="text-primary-600 hover:text-primary-800 text-sm"
                >
                  查看
                </button>
                <button
                  @click="editPlace(place)"
                  class="text-blue-600 hover:text-blue-800 text-sm"
                >
                  編輯
                </button>
                <button
                  @click="deletePlace(place)"
                  class="text-red-600 hover:text-red-800 text-sm"
                >
                  刪除
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- 空狀態 -->
      <div v-if="filteredPlaces.length === 0" class="text-center py-12">
        <div class="text-gray-400 text-4xl mb-4">📭</div>
        <p class="text-gray-500">沒有找到符合條件的景點</p>
      </div>

      <!-- 分頁 -->
      <div v-if="filteredPlaces.length > 0" class="px-6 py-4 border-t flex items-center justify-between">
        <p class="text-sm text-gray-500">
          顯示 {{ startIndex + 1 }} - {{ endIndex }} 筆，共 {{ totalItems }} 筆
        </p>
        <div class="flex gap-2">
          <button
            @click="prevPage"
            :disabled="currentPage === 1"
            class="px-3 py-1 border rounded hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            上一頁
          </button>
          <button
            v-for="page in displayedPages"
            :key="page"
            @click="goToPage(page)"
            class="px-3 py-1 rounded"
            :class="currentPage === page
              ? 'bg-primary-500 text-white'
              : 'border hover:bg-gray-50'"
          >
            {{ page }}
          </button>
          <button
            @click="nextPage"
            :disabled="currentPage === totalPages"
            class="px-3 py-1 border rounded hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            下一頁
          </button>
        </div>
      </div>
    </div>

    <!-- 查看詳情對話框 -->
    <div
      v-if="viewingPlace"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="viewingPlace = null"
    >
      <div class="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto m-4">
        <div class="p-6">
          <div class="flex items-start justify-between mb-4">
            <h2 class="text-xl font-bold">{{ viewingPlace.name }}</h2>
            <button @click="viewingPlace = null" class="text-gray-400 hover:text-gray-600">✕</button>
          </div>
          <div class="space-y-4">
            <div>
              <label class="text-sm text-gray-500">地址</label>
              <p>{{ viewingPlace.address || '-' }}</p>
            </div>
            <div class="grid grid-cols-2 gap-4">
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
              <p>{{ viewingPlace.description || '-' }}</p>
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
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { usePlacesStore } from '@/stores/placesStore'
import { placesApi } from '@/services/api'

const router = useRouter()
const placesStore = usePlacesStore()

const searchQuery = ref('')
const statusFilter = ref('')
const viewingPlace = ref(null)
const currentPage = ref(1)
const itemsPerPage = 10
const loading = ref(false)

// 從 API 獲取所有景點（包含待審核）
const allPlaces = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const response = await placesApi.getAllStatus()
    allPlaces.value = response.data
  } catch (error) {
    console.error('Failed to fetch places:', error)
  } finally {
    loading.value = false
  }
})

const filteredPlaces = computed(() => {
  let places = allPlaces.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    places = places.filter(p =>
      p.name.toLowerCase().includes(query) ||
      p.address?.toLowerCase().includes(query)
    )
  }

  if (statusFilter.value) {
    places = places.filter(p => p.status === statusFilter.value)
  }

  return places
})

const totalItems = computed(() => filteredPlaces.value.length)
const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, totalItems.value))

const displayedPages = computed(() => {
  const pages = []
  const maxPages = 5
  let start = Math.max(1, currentPage.value - 2)
  let end = Math.min(totalPages.value, start + maxPages - 1)

  if (end - start < maxPages - 1) {
    start = Math.max(1, end - maxPages + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

function getStatusClass(status) {
  const classes = {
    approved: 'bg-green-100 text-green-700',
    pending: 'bg-yellow-100 text-yellow-700',
    rejected: 'bg-red-100 text-red-700'
  }
  return classes[status] || 'bg-gray-100 text-gray-700'
}

function getStatusText(status) {
  const texts = {
    approved: '已通過',
    pending: '待審核',
    rejected: '已拒絕'
  }
  return texts[status] || status
}

function viewPlace(place) {
  viewingPlace.value = place
}

function editPlace(place) {
  router.push(`/places/${place.id}/edit`)
}

async function deletePlace(place) {
  if (confirm(`確定要刪除「${place.name}」嗎？此操作無法復原。`)) {
    try {
      await placesApi.delete(place.id)
      allPlaces.value = allPlaces.value.filter(p => p.id !== place.id)
      alert('刪除成功')
    } catch (error) {
      console.error('Failed to delete place:', error)
      alert('刪除失敗，請稍後再試')
    }
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function goToPage(page) {
  currentPage.value = page
}
</script>
