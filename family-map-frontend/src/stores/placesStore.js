import { defineStore } from 'pinia'
import { ref } from 'vue'
import { placesApi } from '@/services/api'

const taichungMockPlaces = [
  {
    id: 'tc-approved-1',
    name: '台中公園親子遊戲區',
    address: '台中市中區公園路37-1號',
    latitude: 24.1452,
    longitude: 120.684,
    reviewStatus: 'approved',
    infrastructureType: '兒童遊戲區',
    facilities: ['兒童遊戲區', '休息區', '親子廁所'],
    rating: 4.6,
    reviewCount: 126,
    minAge: 3,
    maxAge: 12
  },
  {
    id: 'tc-approved-2',
    name: '國立自然科學博物館哺乳室',
    address: '台中市北區館前路1號',
    latitude: 24.1577,
    longitude: 120.6662,
    reviewStatus: 'approved',
    infrastructureType: '哺乳室',
    facilities: ['哺乳室', '尿布台', '無障礙廁所'],
    rating: 4.8,
    reviewCount: 93,
    minAge: 0,
    maxAge: 4
  },
  {
    id: 'tc-pending-1',
    name: '秋紅谷景觀生態公園親子廁所',
    address: '台中市西屯區朝富路30號',
    latitude: 24.1676,
    longitude: 120.6395,
    reviewStatus: 'pending',
    infrastructureType: '親子廁所',
    facilities: ['親子廁所', '無障礙廁所'],
    rating: 0,
    reviewCount: 0,
    minAge: 1,
    maxAge: 10
  },
  {
    id: 'tc-pending-2',
    name: '台中火車站旅服中心尿布台',
    address: '台中市中區台灣大道一段1號',
    latitude: 24.1367,
    longitude: 120.685,
    reviewStatus: 'pending',
    infrastructureType: '尿布台',
    facilities: ['尿布台', '休息區'],
    rating: 0,
    reviewCount: 0,
    minAge: 0,
    maxAge: 3
  }
]

function normalizePlace(place) {
  return {
    ...place,
    reviewStatus: place.reviewStatus || place.status || 'approved',
    infrastructureType: place.infrastructureType || place.type || '一般設施'
  }
}

function getMockTaichungPlaces() {
  return taichungMockPlaces.map(normalizePlace)
}

export const usePlacesStore = defineStore('places', () => {
  const places = ref([])
  const selectedPlace = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function fetchPlaces() {
    loading.value = true
    error.value = null
    try {
      // 預留串接後端地圖點位 API：回傳時請包含 reviewStatus 與 infrastructureType。
      const response = await placesApi.getMapMarkers()
      const backendPlaces = Array.isArray(response.data) ? response.data : []
      places.value = backendPlaces.length > 0
        ? backendPlaces.map(normalizePlace)
        : getMockTaichungPlaces()
    } catch (err) {
      error.value = err.message || '獲取景點失敗，已使用台中測試資料'
      console.error('Error fetching places:', err)
      places.value = getMockTaichungPlaces()
    } finally {
      loading.value = false
    }
  }

  async function fetchNearbyPlaces(lat, lng, radius = 10) {
    loading.value = true
    error.value = null
    try {
      const response = await placesApi.getNearby(lat, lng, radius)
      places.value = response.data.map(normalizePlace)
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
      selectedPlace.value = normalizePlace(response.data)
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
