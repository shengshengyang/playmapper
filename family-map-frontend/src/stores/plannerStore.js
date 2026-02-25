import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { plannerApi } from '@/services/api'

export const usePlannerStore = defineStore('planner', () => {
  const selectedPlaces = ref([])
  const optimizedRoute = ref([])
  const schedule = ref([])
  const childAge = ref(5)
  const startTime = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const totalDistance = computed(() => {
    // 計算總距離
    let total = 0
    for (const item of schedule.value) {
      if (item.type === 'driving' && item.distance) {
        total += item.distance
      }
    }
    return total.toFixed(1)
  })

  const totalDuration = computed(() => {
    if (schedule.value.length === 0) return 0
    const lastItem = schedule.value[schedule.value.length - 1]
    return lastItem.durationMinutes || 0
  })

  function addPlace(place) {
    if (!selectedPlaces.value.find(p => p.id === place.id)) {
      selectedPlaces.value.push(place)
    }
  }

  function removePlace(placeId) {
    selectedPlaces.value = selectedPlaces.value.filter(p => p.id !== placeId)
  }

  function clearPlaces() {
    selectedPlaces.value = []
    optimizedRoute.value = []
    schedule.value = []
  }

  function setChildAge(age) {
    childAge.value = age
  }

  function setStartTime(time) {
    startTime.value = time
  }

  async function optimizeRoute() {
    if (selectedPlaces.value.length < 2) {
      error.value = '請至少選擇兩個景點'
      return false
    }

    if (!startTime.value) {
      error.value = '請設定開始時間'
      return false
    }

    loading.value = true
    error.value = null

    try {
      const request = {
        placeIds: selectedPlaces.value.map(p => p.id),
        childAge: childAge.value,
        startTime: startTime.value,
        preferences: {
          includeRestaurants: true,
          maxDrivingTimePerSegment: 60,
          autoInsertMeals: true,
          autoInsertBreaks: true
        }
      }

      const response = await plannerApi.optimize(request)
      optimizedRoute.value = response.data.optimizedRoute
      schedule.value = response.data.schedule
      return true
    } catch (err) {
      error.value = err.message || '路徑優化失敗'
      console.error('Error optimizing route:', err)
      return false
    } finally {
      loading.value = false
    }
  }

  return {
    selectedPlaces,
    optimizedRoute,
    schedule,
    childAge,
    startTime,
    loading,
    error,
    totalDistance,
    totalDuration,
    addPlace,
    removePlace,
    clearPlaces,
    setChildAge,
    setStartTime,
    optimizeRoute
  }
})
