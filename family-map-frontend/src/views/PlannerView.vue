<template>
  <div class="max-w-6xl mx-auto p-6">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">智慧行程規劃</h1>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- 左側: 規劃精靈 -->
      <PlannerWizard
        :available-places="places"
        @save="handleSaveTrip"
      />

      <!-- 右側: 地圖預覽 -->
      <div class="bg-white rounded-lg shadow-lg overflow-hidden">
        <div class="h-[600px]">
          <MapContainer
            ref="mapRef"
            :places="selectedPlacesForMap"
            :center="mapCenter"
            :zoom="12"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import PlannerWizard from '@/components/planner/PlannerWizard.vue'
import MapContainer from '@/components/map/MapContainer.vue'
import { usePlacesStore } from '@/stores/placesStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const placesStore = usePlacesStore()

const mapRef = ref(null)
const selectedPlacesForMap = ref([])
const mapCenter = ref([24.1477, 120.6736])

const places = computed(() => placesStore.places)

onMounted(() => {
  placesStore.fetchPlaces()
})

function handleSaveTrip(tripData) {
  console.log('Saving trip:', tripData)
  // TODO: 呼叫 API 儲存行程
  alert('行程已儲存！')
  router.push('/my-trips')
}
</script>
