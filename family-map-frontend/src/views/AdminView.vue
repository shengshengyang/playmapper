<template>
  <div class="max-w-6xl mx-auto p-6">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">後台管理</h1>

    <!-- 分頁 -->
    <div class="flex border-b mb-6">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        @click="activeTab = tab.id"
        class="px-6 py-3 font-medium transition-colors"
        :class="activeTab === tab.id
          ? 'text-primary-600 border-b-2 border-primary-600'
          : 'text-gray-500 hover:text-gray-700'"
      >
        {{ tab.label }}
        <span
          v-if="tab.count !== undefined"
          class="ml-2 px-2 py-0.5 rounded-full text-xs"
          :class="activeTab === tab.id ? 'bg-primary-100 text-primary-700' : 'bg-gray-100 text-gray-600'"
        >
          {{ tab.count }}
        </span>
      </button>
    </div>

    <!-- 審核佇列 -->
    <div v-if="activeTab === 'review'">
      <ReviewQueue
        :places="pendingPlaces"
        @approve="handleApprove"
        @reject="handleReject"
        @view="handleView"
      />
    </div>

    <!-- 景點管理 -->
    <div v-if="activeTab === 'places'">
      <div class="mb-4 flex justify-between items-center">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="搜尋景點..."
          class="px-4 py-2 border rounded-lg w-64"
        />
        <button
          @click="showAddModal = true"
          class="bg-primary-500 text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors"
        >
          + 新增景點
        </button>
      </div>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-4 py-3 text-left text-sm font-medium text-gray-600">名稱</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-gray-600">地址</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-gray-600">狀態</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-gray-600">評分</th>
              <th class="px-4 py-3 text-left text-sm font-medium text-gray-600">操作</th>
            </tr>
          </thead>
          <tbody class="divide-y">
            <tr v-for="place in filteredPlaces" :key="place.id" class="hover:bg-gray-50">
              <td class="px-4 py-3">{{ place.name }}</td>
              <td class="px-4 py-3 text-sm text-gray-500">{{ place.address }}</td>
              <td class="px-4 py-3">
                <span
                  class="px-2 py-1 rounded-full text-xs"
                  :class="getStatusClass(place.status)"
                >
                  {{ getStatusText(place.status) }}
                </span>
              </td>
              <td class="px-4 py-3">{{ place.rating?.toFixed(1) || '-' }}</td>
              <td class="px-4 py-3">
                <button
                  @click="editPlace(place)"
                  class="text-primary-500 hover:text-primary-600 mr-2"
                >
                  編輯
                </button>
                <button
                  @click="deletePlace(place)"
                  class="text-red-500 hover:text-red-600"
                >
                  刪除
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 統計數據 -->
    <div v-if="activeTab === 'stats'" class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-500 text-sm">總景點數</h3>
        <p class="text-3xl font-bold text-gray-800 mt-2">{{ stats.totalPlaces }}</p>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-500 text-sm">待審核</h3>
        <p class="text-3xl font-bold text-orange-500 mt-2">{{ stats.pendingReview }}</p>
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-500 text-sm">本月新增</h3>
        <p class="text-3xl font-bold text-green-500 mt-2">{{ stats.monthlyNew }}</p>
      </div>
    </div>

    <!-- 編輯對話框 -->
    <div
      v-if="editingPlace || showAddModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <PlaceEditor
          :place="editingPlace"
          @save="handleSavePlace"
          @close="closeEditor"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ReviewQueue from '@/components/admin/ReviewQueue.vue'
import PlaceEditor from '@/components/admin/PlaceEditor.vue'
import { placesApi, reviewApi } from '@/services/api'

const tabs = [
  { id: 'review', label: '審核佇列', count: 0 },
  { id: 'places', label: '景點管理' },
  { id: 'stats', label: '統計數據' }
]

const activeTab = ref('review')
const searchQuery = ref('')
const pendingPlaces = ref([])
const allPlaces = ref([])
const editingPlace = ref(null)
const showAddModal = ref(false)

const stats = ref({
  totalPlaces: 0,
  pendingReview: 0,
  monthlyNew: 0
})

onMounted(async () => {
  await loadData()
})

async function loadData() {
  try {
    // 載入待審核景點
    const pendingRes = await reviewApi.getPending()
    pendingPlaces.value = pendingRes.data
    tabs[0].count = pendingPlaces.value.length

    // 載入所有景點
    const allRes = await placesApi.getAll()
    allPlaces.value = allRes.data

    // 更新統計
    stats.value.totalPlaces = allPlaces.value.length
    stats.value.pendingReview = pendingPlaces.value.length
  } catch (error) {
    console.error('Error loading data:', error)
    // 使用模擬資料
    pendingPlaces.value = [
      {
        id: 1,
        name: '新月湖公園',
        address: '台中市北屯區新月湖路100號',
        minAge: 0,
        maxAge: 12,
        suggestedDurationMinutes: 90,
        description: '大型親子公園，設有遊樂設施、沙坑、溜滑梯等'
      }
    ]
    allPlaces.value = [
      { id: 1, name: '國立自然科學博物館', address: '台中市北區館前路1號', status: 'approved', rating: 4.5 },
      { id: 2, name: '台中公園', address: '台中市中區公園路', status: 'approved', rating: 4.2 }
    ]
    tabs[0].count = pendingPlaces.value.length
    stats.value.totalPlaces = allPlaces.value.length
    stats.value.pendingReview = pendingPlaces.value.length
    stats.value.monthlyNew = 5
  }
}

const filteredPlaces = computed(() => {
  if (!searchQuery.value) return allPlaces.value

  const query = searchQuery.value.toLowerCase()
  return allPlaces.value.filter(place =>
    place.name.toLowerCase().includes(query) ||
    (place.address && place.address.toLowerCase().includes(query))
  )
})

function getStatusClass(status) {
  const classes = {
    approved: 'bg-green-100 text-green-700',
    pending: 'bg-yellow-100 text-yellow-700',
    rejected: 'bg-red-100 text-red-700'
  }
  return classes[status] || classes.pending
}

function getStatusText(status) {
  const texts = {
    approved: '已通過',
    pending: '待審核',
    rejected: '已拒絕'
  }
  return texts[status] || status
}

async function handleApprove(place) {
  try {
    await reviewApi.approve(place.id)
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== place.id)
    tabs[0].count = pendingPlaces.value.length
    alert(`已通過「${place.name}」`)
  } catch (error) {
    console.error('Error approving place:', error)
    alert('操作失敗')
  }
}

async function handleReject(place, reason) {
  try {
    await reviewApi.reject(place.id, reason)
    pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== place.id)
    tabs[0].count = pendingPlaces.value.length
    alert(`已拒絕「${place.name}」`)
  } catch (error) {
    console.error('Error rejecting place:', error)
    alert('操作失敗')
  }
}

function handleView(place) {
  editingPlace.value = place
}

function editPlace(place) {
  editingPlace.value = place
}

function deletePlace(place) {
  if (confirm(`確定要刪除「${place.name}」嗎？`)) {
    placesApi.delete(place.id)
    allPlaces.value = allPlaces.value.filter(p => p.id !== place.id)
  }
}

async function handleSavePlace(data) {
  try {
    if (editingPlace.value?.id) {
      await placesApi.update(editingPlace.value.id, data)
    } else {
      await placesApi.create(data)
    }
    closeEditor()
    await loadData()
  } catch (error) {
    console.error('Error saving place:', error)
    alert('儲存失敗')
  }
}

function closeEditor() {
  editingPlace.value = null
  showAddModal.value = false
}
</script>
