import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useMapStore = defineStore('map', () => {
  const center = ref([24.1477, 120.6736]) // 台中市中心
  const zoom = ref(13)
  const selectedPlaceId = ref(null)
  const markers = ref([])
  const routeLayer = ref(null)

  function setCenter(newCenter) {
    center.value = newCenter
  }

  function setZoom(newZoom) {
    zoom.value = newZoom
  }

  function setSelectedPlace(placeId) {
    selectedPlaceId.value = placeId
  }

  function clearSelectedPlace() {
    selectedPlaceId.value = null
  }

  function setMarkers(newMarkers) {
    markers.value = newMarkers
  }

  function setRouteLayer(layer) {
    routeLayer.value = layer
  }

  function clearRoute() {
    routeLayer.value = null
  }

  return {
    center,
    zoom,
    selectedPlaceId,
    markers,
    routeLayer,
    setCenter,
    setZoom,
    setSelectedPlace,
    clearSelectedPlace,
    setMarkers,
    setRouteLayer,
    clearRoute
  }
})
