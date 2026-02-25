<template>
  <div class="max-w-4xl mx-auto p-6">
    <div v-if="loading" class="text-center py-12">
      <div class="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full mx-auto"></div>
      <p class="mt-4 text-gray-500">載入中...</p>
    </div>

    <div v-else-if="!place" class="text-center py-12">
      <p class="text-gray-500">找不到此景點</p>
      <router-link to="/" class="text-primary-500 hover:underline mt-2 inline-block">
        返回首頁
      </router-link>
    </div>

    <div v-else>
      <!-- 返回按鈕 -->
      <router-link
        to="/"
        class="inline-flex items-center text-gray-600 hover:text-primary-600 mb-4"
      >
        ← 返回地圖
      </router-link>

      <!-- 景點詳情 -->
      <div class="bg-white rounded-lg shadow-lg overflow-hidden">
        <!-- 圖片輪播 -->
        <div class="relative h-80 bg-gray-200">
          <img
            v-if="place.images && place.images.length > 0"
            :src="place.images[currentImageIndex]"
            :alt="place.name"
            class="w-full h-full object-cover"
          />
          <div v-else class="w-full h-full flex items-center justify-center text-gray-400">
            <span class="text-6xl">🏞️</span>
          </div>

          <!-- 圖片導航 -->
          <div
            v-if="place.images && place.images.length > 1"
            class="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2"
          >
            <button
              v-for="(_, index) in place.images"
              :key="index"
              @click="currentImageIndex = index"
              class="w-3 h-3 rounded-full transition-colors"
              :class="currentImageIndex === index ? 'bg-white' : 'bg-white/50'"
            ></button>
          </div>
        </div>

        <!-- 內容 -->
        <div class="p-6">
          <div class="flex items-start justify-between">
            <div>
              <h1 class="text-2xl font-bold text-gray-800">{{ place.name }}</h1>
              <p class="text-gray-500 mt-1">{{ place.address }}</p>
            </div>
            <div class="flex items-center bg-yellow-100 px-4 py-2 rounded-full">
              <span class="text-yellow-500 text-xl">★</span>
              <span class="ml-2 font-bold text-lg">{{ place.rating?.toFixed(1) || 'N/A' }}</span>
              <span class="ml-1 text-sm text-gray-500">({{ place.reviewCount || 0 }})</span>
            </div>
          </div>

          <!-- 資訊卡片 -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
            <div class="bg-gray-50 rounded-lg p-4 text-center">
              <div class="text-gray-500 text-sm">適合年齡</div>
              <div class="font-bold text-lg mt-1">{{ place.minAge || 0 }} - {{ place.maxAge || 18 }} 歲</div>
            </div>
            <div class="bg-gray-50 rounded-lg p-4 text-center">
              <div class="text-gray-500 text-sm">建議停留</div>
              <div class="font-bold text-lg mt-1">{{ place.suggestedDurationMinutes || 60 }} 分鐘</div>
            </div>
            <div class="bg-gray-50 rounded-lg p-4 text-center">
              <div class="text-gray-500 text-sm">票價</div>
              <div class="font-bold text-lg mt-1">
                {{ place.ticketPrice ? `NT$ ${place.ticketPrice}` : '免費' }}
              </div>
            </div>
            <div class="bg-gray-50 rounded-lg p-4 text-center">
              <div class="text-gray-500 text-sm">評論數</div>
              <div class="font-bold text-lg mt-1">{{ place.reviewCount || 0 }} 則</div>
            </div>
          </div>

          <!-- 設施標籤 -->
          <div v-if="place.facilities && place.facilities.length > 0" class="mt-6">
            <h3 class="font-semibold text-gray-800 mb-2">設施標籤</h3>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="facility in place.facilities"
                :key="facility"
                class="bg-primary-100 text-primary-700 px-3 py-1 rounded-full text-sm"
              >
                {{ facility }}
              </span>
            </div>
          </div>

          <!-- 描述 -->
          <div v-if="place.description" class="mt-6">
            <h3 class="font-semibold text-gray-800 mb-2">景點介紹</h3>
            <p class="text-gray-700 leading-relaxed">{{ place.description }}</p>
          </div>

          <!-- 聯絡資訊 -->
          <div class="mt-6 border-t pt-6">
            <h3 class="font-semibold text-gray-800 mb-4">聯絡資訊</h3>
            <div class="space-y-2">
              <div v-if="place.phone" class="flex items-center">
                <span class="w-20 text-gray-500">電話</span>
                <a :href="`tel:${place.phone}`" class="text-primary-600 hover:underline">
                  {{ place.phone }}
                </a>
              </div>
              <div v-if="place.website" class="flex items-center">
                <span class="w-20 text-gray-500">網站</span>
                <a :href="place.website" target="_blank" class="text-primary-600 hover:underline truncate">
                  {{ place.website }}
                </a>
              </div>
            </div>
          </div>

          <!-- 操作按鈕 -->
          <div class="mt-6 flex gap-3">
            <button
              @click="addToPlan"
              class="flex-1 bg-primary-500 text-white py-3 px-6 rounded-lg hover:bg-primary-600 transition-colors font-medium"
            >
              加入行程規劃
            </button>
            <button
              @click="navigate"
              class="bg-gray-100 text-gray-700 py-3 px-6 rounded-lg hover:bg-gray-200 transition-colors"
            >
              導航前往
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { usePlacesStore } from '@/stores/placesStore'
import { usePlannerStore } from '@/stores/plannerStore'

const route = useRoute()
const placesStore = usePlacesStore()
const plannerStore = usePlannerStore()

const place = ref(null)
const loading = ref(true)
const currentImageIndex = ref(0)

onMounted(async () => {
  const placeId = route.params.id
  place.value = await placesStore.fetchPlaceById(placeId)
  loading.value = false
})

function addToPlan() {
  if (place.value) {
    plannerStore.addPlace(place.value)
    alert(`已將「${place.value.name}」加入行程規劃`)
  }
}

function navigate() {
  if (place.value && place.value.latitude && place.value.longitude) {
    const url = `https://www.google.com/maps/dir/?api=1&destination=${place.value.latitude},${place.value.longitude}`
    window.open(url, '_blank')
  }
}
</script>
