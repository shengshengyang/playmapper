<template>
  <div class="h-[calc(100vh-64px)] flex">
    <!-- 左側面板 -->
    <div class="w-80 bg-white border-r overflow-y-auto">
      <div class="p-4">
        <h2 class="text-lg font-bold text-gray-800 mb-4">景點探索</h2>

        <!-- 搜尋 -->
        <div class="relative mb-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜尋景點..."
            class="w-full px-4 py-2 pl-10 border rounded-lg focus:ring-2 focus:ring-primary-500"
          />
          <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
        </div>

        <!-- 年齡篩選 -->
        <AgeFilter
          v-model:min-age="minAge"
          v-model:max-age="maxAge"
          @change="handleAgeChange"
        />

        <!-- 景點列表 -->
        <div class="mt-4 space-y-3">
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
    <div class="flex-1 relative">
      <MapContainer
        ref="mapRef"
        :places="filteredPlaces"
        :center="mapCenter"
        :zoom="13"
        @place-click="selectPlace"
      />

      <!-- 新增景點按鈕 -->
      <button
        @click="showAddPlaceModal = true"
        class="absolute bottom-6 right-6 bg-primary-500 text-white px-4 py-2 rounded-lg shadow-lg hover:bg-primary-600 transition-colors"
      >
        + 新增景點
      </button>
    </div>

    <!-- 景點詳情側邊欄 -->
    <transition name="slide">
      <div
        v-if="selectedPlace"
        class="w-96 bg-white border-l overflow-y-auto"
      >
        <PlaceDetail
          :place="selectedPlace"
          @close="selectedPlace = null"
          @add-to-plan="addToPlan"
        />
      </div>
    </transition>

    <!-- 新增景點對話框 -->
    <div
      v-if="showAddPlaceModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">新增景點</h2>
        <PlaceForm
          @submit="submitNewPlace"
          @cancel="showAddPlaceModal = false"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import MapContainer from '@/components/map/MapContainer.vue'
import PlaceCard from '@/components/place/PlaceCard.vue'
import PlaceDetail from '@/components/place/PlaceDetail.vue'
import PlaceForm from '@/components/place/PlaceForm.vue'
import AgeFilter from '@/components/place/AgeFilter.vue'
import { usePlacesStore } from '@/stores/placesStore'
import { usePlannerStore } from '@/stores/plannerStore'

const placesStore = usePlacesStore()
const plannerStore = usePlannerStore()

const mapRef = ref(null)
const searchQuery = ref('')
const minAge = ref(0)
const maxAge = ref(18)
const selectedPlace = ref(null)
const showAddPlaceModal = ref(false)

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

  // 年齡篩選
  places = places.filter(place =>
    place.minAge <= maxAge.value && place.maxAge >= minAge.value
  )

  return places
})

function handleAgeChange({ minAge: min, maxAge: max }) {
  minAge.value = min
  maxAge.value = max
}

function selectPlace(place) {
  selectedPlace.value = place
  if (mapRef.value && place.latitude && place.longitude) {
    mapRef.value.flyTo(place.latitude, place.longitude, 16)
  }
}

function addToPlan(place) {
  plannerStore.addPlace(place)
  // 顯示通知
  alert(`已將「${place.name}」加入行程規劃`)
}

async function submitNewPlace(data) {
  try {
    // TODO: 呼叫 API
    console.log('Submitting new place:', data)
    showAddPlaceModal.value = false
    alert('景點已提交，等待審核')
  } catch (error) {
    console.error('Error submitting place:', error)
  }
}
</script>
