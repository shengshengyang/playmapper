<template>
  <div class="h-[calc(100vh-56px)] flex">
    <!-- 左側面板 -->
    <div class="w-80 bg-white border-r border-neutral-200/60 flex flex-col">
      <!-- 標題區 -->
      <div class="p-4 border-b border-neutral-100">
        <h2 class="section-title">親子基礎設施地圖</h2>
        <p class="text-sm text-neutral-500 mt-0.5">先建立可用點位，AI 規劃將在下一階段推出</p>
      </div>

      <!-- 搜尋和篩選 -->
      <div class="p-4 space-y-3">
        <!-- 搜尋框 -->
        <div class="relative">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜尋設施名稱或地址..."
            class="input pl-9"
          />
          <button
            v-if="searchQuery"
            @click="searchQuery = ''"
            class="absolute right-2.5 top-1/2 -translate-y-1/2 p-1 rounded-md hover:bg-neutral-100"
          >
            <X class="w-3.5 h-3.5 text-neutral-400" />
          </button>
        </div>

        <select v-model="selectedFacilityType" class="input">
          <option value="">全部設施類型</option>
          <option v-for="type in facilityTypes" :key="type" :value="type">{{ type }}</option>
        </select>

        <!-- 搜尋結果數量 -->
        <div class="flex items-center justify-between text-sm pt-1">
          <span class="text-neutral-500">
            找到 <span class="font-semibold text-neutral-700">{{ filteredPlaces.length }}</span> 個設施點
          </span>
        </div>
      </div>

      <!-- 景點列表 -->
      <div class="flex-1 overflow-y-auto p-4 pt-0">
        <div v-if="filteredPlaces.length === 0" class="text-center py-12">
          <div class="w-12 h-12 mx-auto mb-3 rounded-full bg-neutral-100 flex items-center justify-center">
            <Search class="w-5 h-5 text-neutral-400" />
          </div>
          <p class="text-neutral-500 text-sm">沒有找到符合條件的設施點</p>
          <button
            @click="resetFilters"
            class="mt-2 text-sm text-primary-600 hover:text-primary-700 font-medium"
          >
            清除篩選條件
          </button>
        </div>
        <div v-else class="space-y-3">
          <PlaceCard
            v-for="place in filteredPlaces"
            :key="place.id"
            :place="place"
            @click="selectPlace(place)"
          />
        </div>
      </div>
    </div>

    <!-- 地圖區域 -->
    <div class="flex-1 relative bg-neutral-100">
      <MapContainer
        ref="mapRef"
        :places="filteredPlaces"
        :center="mapCenter"
        :zoom="13"
        @place-click="selectPlace"
      />

      <!-- 地圖控制按鈕 -->
      <div class="absolute top-3 right-3 flex flex-col gap-2">
        <button
          @click="centerMap"
          class="icon-btn bg-white shadow-sm"
          title="回到中心位置"
        >
          <Locate class="w-4 h-4" />
        </button>
        <button
          @click="toggleFullscreen"
          class="icon-btn bg-white shadow-sm"
          title="全螢幕"
        >
          <Maximize2 class="w-4 h-4" />
        </button>
      </div>

      <!-- 新增景點按鈕 -->
      <button
        @click="showAddPlaceModal = true"
        class="absolute bottom-5 right-5 btn-primary shadow-md"
      >
        <Plus class="w-4 h-4" />
        <span>新增設施點</span>
      </button>
    </div>

    <!-- 景點詳情側邊欄 -->
    <transition name="slide">
      <div
        v-if="selectedPlace"
        class="w-96 bg-white border-l border-neutral-200/60 overflow-hidden shadow-lg"
      >
        <PlaceDetail
          :place="selectedPlace"
          @close="selectedPlace = null"
          @add-to-plan="addToPlan"
        />
      </div>
    </transition>

    <!-- 新增景點對話框 -->
    <transition name="scale">
      <div
        v-if="showAddPlaceModal"
        class="fixed inset-0 bg-neutral-900/40 flex items-center justify-center z-50 p-4"
        @click.self="showAddPlaceModal = false"
      >
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-xl max-h-[85vh] overflow-hidden flex flex-col">
          <!-- 對話框標題 -->
          <div class="p-4 border-b border-neutral-100 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 bg-primary-100 rounded-lg flex items-center justify-center">
                <Plus class="w-4 h-4 text-primary-600" />
              </div>
              <div>
                <h2 class="text-base font-semibold text-neutral-800">新增設施點</h2>
                <p class="text-xs text-neutral-500">先累積親子設施點位，再串接 AI 規劃</p>
              </div>
            </div>
            <button
              @click="showAddPlaceModal = false"
              class="icon-btn"
            >
              <X class="w-4 h-4" />
            </button>
          </div>
          <!-- 表單內容 -->
          <div class="flex-1 overflow-y-auto p-4">
            <PlaceForm
              @submit="submitNewPlace"
              @cancel="showAddPlaceModal = false"
            />
          </div>
        </div>
      </div>
    </transition>

    <!-- 成功提示 -->
    <transition name="slide-up">
      <div
        v-if="showNotification"
        class="fixed bottom-5 left-1/2 -translate-x-1/2 bg-secondary-600 text-white px-4 py-2.5 rounded-xl shadow-lg flex items-center gap-2 z-50"
      >
        <Check class="w-4 h-4" />
        <span class="text-sm font-medium">{{ notificationMessage }}</span>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Search, X, Plus, Locate, Maximize2, Check } from 'lucide-vue-next'
import MapContainer from '@/components/map/MapContainer.vue'
import PlaceCard from '@/components/place/PlaceCard.vue'
import PlaceDetail from '@/components/place/PlaceDetail.vue'
import PlaceForm from '@/components/place/PlaceForm.vue'
import { usePlacesStore } from '@/stores/placesStore'
import { usePlannerStore } from '@/stores/plannerStore'

const placesStore = usePlacesStore()
const plannerStore = usePlannerStore()

const mapRef = ref(null)
const searchQuery = ref('')
const selectedFacilityType = ref('')
const selectedPlace = ref(null)
const showAddPlaceModal = ref(false)
const showNotification = ref(false)
const notificationMessage = ref('')
const facilityTypes = ['親子廁所', '尿布台', '哺乳室', '無障礙廁所', '兒童遊戲區', '休息區']

const mapCenter = ref([24.1477, 120.6736])

onMounted(() => {
  placesStore.fetchPlaces()
})

const filteredPlaces = computed(() => {
  let places = placesStore.places

  // 搜尋篩選
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    places = places.filter(place =>
      place.name.toLowerCase().includes(query) ||
      (place.address && place.address.toLowerCase().includes(query))
    )
  }

  if (selectedFacilityType.value) {
    places = places.filter(place =>
      place.facilities?.includes(selectedFacilityType.value)
    )
  }

  return places
})

function selectPlace(place) {
  selectedPlace.value = place
  if (mapRef.value && place.latitude && place.longitude) {
    mapRef.value.flyTo(place.latitude, place.longitude, 16)
  }
}

function addToPlan(place) {
  plannerStore.addPlace(place)
  selectedPlace.value = null
  showNotificationMessage(`已收藏「${place.name}」`)
}

async function submitNewPlace(data) {
  try {
    console.log('Submitting new place:', data)
    showAddPlaceModal.value = false
    showNotificationMessage('設施點已提交，等待審核')
  } catch (error) {
    console.error('Error submitting place:', error)
  }
}

function showNotificationMessage(message) {
  notificationMessage.value = message
  showNotification.value = true
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
}

function resetFilters() {
  searchQuery.value = ''
  selectedFacilityType.value = ''
}

function centerMap() {
  if (mapRef.value) {
    mapRef.value.setView(mapCenter.value, 13)
  }
}

function toggleFullscreen() {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}
</script>
