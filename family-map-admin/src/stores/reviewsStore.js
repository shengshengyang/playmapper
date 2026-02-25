import { defineStore } from 'pinia'
import { ref } from 'vue'
import { reviewApi } from '@/services/api'

export const useReviewsStore = defineStore('reviews', () => {
  const pendingPlaces = ref([])
  const reviewHistory = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function fetchPendingPlaces() {
    loading.value = true
    error.value = null
    try {
      const response = await reviewApi.getPending()
      pendingPlaces.value = response.data
    } catch (err) {
      error.value = err.message
      console.error('Error fetching pending places:', err)
    } finally {
      loading.value = false
    }
  }

  async function approvePlace(placeId, comment = '') {
    try {
      await reviewApi.approve(placeId, comment)
      pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== placeId)
      return { success: true }
    } catch (err) {
      return { success: false, message: err.response?.data?.message || '審核失敗' }
    }
  }

  async function rejectPlace(placeId, comment = '') {
    try {
      await reviewApi.reject(placeId, comment)
      pendingPlaces.value = pendingPlaces.value.filter(p => p.id !== placeId)
      return { success: true }
    } catch (err) {
      return { success: false, message: err.response?.data?.message || '拒絕失敗' }
    }
  }

  async function fetchReviewHistory(placeId) {
    try {
      const response = await reviewApi.getHistory(placeId)
      reviewHistory.value = response.data
    } catch (err) {
      console.error('Error fetching review history:', err)
    }
  }

  return {
    pendingPlaces,
    reviewHistory,
    loading,
    error,
    fetchPendingPlaces,
    approvePlace,
    rejectPlace,
    fetchReviewHistory
  }
})
