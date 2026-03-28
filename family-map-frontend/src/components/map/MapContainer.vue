<template>
  <div ref="mapContainer" class="h-full w-full rounded-lg"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import L from 'leaflet'
import { useMapStore } from '@/stores/mapStore'
import {
  createPlaceIcon,
  createSelectedIcon,
  getColorByAge,
  getPlaceStatusLabel,
  getPlaceTypeLabel
} from '@/services/mapService'

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
  map.value = L.map(mapContainer.value, {
    center: props.center,
    zoom: props.zoom,
    zoomControl: true
  })

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
  }).addTo(map.value)

  markersLayer.value = L.layerGroup().addTo(map.value)

  map.value.on('click', (e) => {
    emit('map-click', { lat: e.latlng.lat, lng: e.latlng.lng })
  })

  updateMarkers()
}

function updateMarkers() {
  if (!markersLayer.value) return

  markersLayer.value.clearLayers()

  props.places.forEach(place => {
    if (!place.latitude || !place.longitude) return

    const color = getColorByAge(place.minAge, place.maxAge)
    const icon = place.id === mapStore.selectedPlaceId
      ? createSelectedIcon(place)
      : createPlaceIcon({
        color,
        infrastructureType: place.infrastructureType,
        reviewStatus: place.reviewStatus
      })

    const marker = L.marker([place.latitude, place.longitude], { icon })
      .addTo(markersLayer.value)

    marker.bindPopup(`
      <div class="p-2 min-w-[220px]">
        <h3 class="font-bold text-lg">${place.name}</h3>
        <p class="text-gray-600 text-sm mt-1">${place.address || ''}</p>
        <div class="mt-2 text-xs text-gray-500">
          類型：${getPlaceTypeLabel(place.infrastructureType)}
        </div>
        <div class="mt-1 text-xs ${place.reviewStatus === 'pending' ? 'text-amber-600' : 'text-emerald-600'}">
          狀態：${getPlaceStatusLabel(place.reviewStatus)}
        </div>
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
