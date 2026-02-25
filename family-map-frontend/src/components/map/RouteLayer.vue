<template>
  <div></div>
</template>

<script setup>
import { watch, onUnmounted } from 'vue'
import L from 'leaflet'

const props = defineProps({
  map: {
    type: Object,
    required: true
  },
  coordinates: {
    type: Array,
    default: () => []
  },
  color: {
    type: String,
    default: '#3b82f6'
  }
})

let polyline = null

watch(() => props.coordinates, (newCoords) => {
  updateRoute(newCoords)
}, { immediate: true })

onUnmounted(() => {
  if (polyline) {
    polyline.remove()
  }
})

function updateRoute(coordinates) {
  if (!props.map) return

  // 移除舊路線
  if (polyline) {
    polyline.remove()
  }

  if (coordinates.length < 2) return

  // 繪製新路線
  const latLngs = coordinates.map(coord => [coord.lat, coord.lng])
  polyline = L.polyline(latLngs, {
    color: props.color,
    weight: 4,
    opacity: 0.8,
    smoothFactor: 1
  }).addTo(props.map)

  // 調整視野
  props.map.fitBounds(polyline.getBounds(), { padding: [50, 50] })
}

function clearRoute() {
  if (polyline) {
    polyline.remove()
    polyline = null
  }
}

defineExpose({
  clearRoute
})
</script>
