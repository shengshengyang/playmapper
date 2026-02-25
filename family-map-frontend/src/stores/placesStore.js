import { defineStore } from 'pinia'
import { ref } from 'vue'
import { placesApi } from '@/services/api'

export const usePlacesStore = defineStore('places', () => {
  const places = ref([])
  const selectedPlace = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function fetchPlaces() {
    loading.value = true
    error.value = null
    try {
      const response = await placesApi.getAll()
      places.value = response.data
    } catch (err) {
      error.value = err.message || '獲取景點失敗'
      console.error('Error fetching places:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchNearbyPlaces(lat, lng, radius = 10) {
    loading.value = true
    error.value = null
    try {
      const response = await placesApi.getNearby(lat, lng, radius)
      places.value = response.data
    } catch (err) {
      error.value = err.message || '獲取附近景點失敗'
      console.error('Error fetching nearby places:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchPlaceById(id) {
    loading.value = true
    error.value = null
    try {
      const response = await placesApi.getById(id)
      selectedPlace.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || '獲取景點詳情失敗'
      console.error('Error fetching place:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  function setSelectedPlace(place) {
    selectedPlace.value = place
  }

  function clearSelectedPlace() {
    selectedPlace.value = null
  }

  return {
    places,
    selectedPlace,
    loading,
    error,
    fetchPlaces,
    fetchNearbyPlaces,
    fetchPlaceById,
    setSelectedPlace,
    clearSelectedPlace
  }
})
