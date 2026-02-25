import { defineStore } from 'pinia'
import { ref } from 'vue'
import { placesApi } from '@/services/api'

export const usePlacesStore = defineStore('places', () => {
  const places = ref([])
  const loading = ref(false)
  const error = ref(null)
  const pagination = ref({
    page: 0,
    size: 20,
    totalElements: 0,
    totalPages: 0
  })

  async function fetchPlaces(params = {}) {
    loading.value = true
    error.value = null
    try {
      const response = await placesApi.getAll(params)
      places.value = response.data.content || response.data
      if (response.data.pageable) {
        pagination.value = {
          page: response.data.number,
          size: response.data.size,
          totalElements: response.data.totalElements,
          totalPages: response.data.totalPages
        }
      }
    } catch (err) {
      error.value = err.message
      console.error('Error fetching places:', err)
    } finally {
      loading.value = false
    }
  }

  async function createPlace(data) {
    try {
      const response = await placesApi.create(data)
      places.value.unshift(response.data)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, message: err.response?.data?.message || '建立失敗' }
    }
  }

  async function updatePlace(id, data) {
    try {
      const response = await placesApi.update(id, data)
      const index = places.value.findIndex(p => p.id === id)
      if (index !== -1) {
        places.value[index] = response.data
      }
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, message: err.response?.data?.message || '更新失敗' }
    }
  }

  async function deletePlace(id) {
    try {
      await placesApi.delete(id)
      places.value = places.value.filter(p => p.id !== id)
      return { success: true }
    } catch (err) {
      return { success: false, message: err.response?.data?.message || '刪除失敗' }
    }
  }

  async function getPlaceById(id) {
    try {
      const response = await placesApi.getById(id)
      return response.data
    } catch (err) {
      return null
    }
  }

  return {
    places,
    loading,
    error,
    pagination,
    fetchPlaces,
    createPlace,
    updatePlace,
    deletePlace,
    getPlaceById
  }
})
