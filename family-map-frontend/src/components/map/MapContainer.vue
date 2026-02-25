<template>
  <div ref="mapContainer" class="h-full w-full rounded-lg"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import L from 'leaflet'
import { useMapStore } from '@/stores/mapStore'
import { createPlaceIcon, createSelectedIcon, getColorByAge } from '@/services/mapService'

const props = defineProps({
  center: {
    type: Array,
    default: () => [24.1477, 120.6736]
  },
  zoom: {
    type: Number,
    default: 13
  },
  places: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['place-click', 'map-click'])

const mapContainer = ref(null)
const map = ref(null)
const markersLayer = ref(null)
const mapStore = useMapStore()

onMounted(() => {
  initMap()
})

onUnmounted(() => {
  if (map.value) {
    map.value.remove()
  }
})

watch(() => props.places, () => {
  updateMarkers()
}, { deep: true })

function initMap() {
  // 初始化地圖
  map.value = L.map(mapContainer.value, {
    center: props.center,
    zoom: props.zoom,
    zoomControl: true
  })

  // 添加圖層（OpenStreetMap）
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
  }).addTo(map.value)

  // 建立標記圖層
  markersLayer.value = L.layerGroup().addTo(map.value)

  // 點擊事件
  map.value.on('click', (e) => {
    emit('map-click', { lat: e.latlng.lat, lng: e.latlng.lng })
  })

  // 更新標記
  updateMarkers()
}

function updateMarkers() {
  if (!markersLayer.value) return

  markersLayer.value.clearLayers()

  props.places.forEach(place => {
    if (!place.latitude || !place.longitude) return

    const color = getColorByAge(place.minAge, place.maxAge)
    const icon = place.id === mapStore.selectedPlaceId
      ? createSelectedIcon()
      : createPlaceIcon(color)

    const marker = L.marker([place.latitude, place.longitude], { icon })
      .addTo(markersLayer.value)

    // 彈出視窗
    marker.bindPopup(`
      <div class="p-2 min-w-[200px]">
        <h3 class="font-bold text-lg">${place.name}</h3>
        <p class="text-gray-600 text-sm mt-1">${place.address || ''}</p>
        <div class="flex items-center mt-2 text-sm">
          <span class="text-yellow-500">★</span>
          <span class="ml-1">${place.rating || 0}</span>
          <span class="text-gray-400 ml-2">(${place.reviewCount || 0} 則評論)</span>
        </div>
        <div class="mt-2 text-sm text-gray-500">
          適合年齡: ${place.minAge || 0} - ${place.maxAge || 18} 歲
        </div>
      </div>
    `)

    marker.on('click', () => {
      emit('place-click', place)
      mapStore.setSelectedPlace(place.id)
    })
  })

  // 自動調整視野
  if (props.places.length > 0) {
    const bounds = L.latLngBounds(
      props.places
        .filter(p => p.latitude && p.longitude)
        .map(p => [p.latitude, p.longitude])
    )
    if (bounds.isValid()) {
      map.value.fitBounds(bounds, { padding: [50, 50] })
    }
  }
}

function setView(center, zoom) {
  if (map.value) {
    map.value.setView(center, zoom)
  }
}

function flyTo(lat, lng, zoom = 15) {
  if (map.value) {
    map.value.flyTo([lat, lng], zoom)
  }
}

defineExpose({
  setView,
  flyTo,
  map
})
</script>
