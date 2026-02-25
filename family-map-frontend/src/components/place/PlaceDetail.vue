<template>
  <div class="bg-white rounded-lg shadow-lg">
    <!-- 圖片區域 -->
    <div class="relative h-64 bg-gray-200 rounded-t-lg overflow-hidden">
      <img
        v-if="place.images && place.images.length > 0"
        :src="place.images[0]"
        :alt="place.name"
        class="w-full h-full object-cover"
      />
      <div v-else class="w-full h-full flex items-center justify-center text-gray-400">
        <span class="text-6xl">🏞️</span>
      </div>
      <button
        @click="$emit('close')"
        class="absolute top-4 right-4 bg-white rounded-full p-2 shadow-md hover:bg-gray-100"
      >
        ✕
      </button>
    </div>

    <!-- 內容區域 -->
    <div class="p-6">
      <div class="flex items-start justify-between">
        <h2 class="text-2xl font-bold text-gray-800">{{ place.name }}</h2>
        <div class="flex items-center bg-yellow-100 px-3 py-1 rounded-full">
          <span class="text-yellow-500">★</span>
          <span class="ml-1 font-medium">{{ place.rating?.toFixed(1) || 'N/A' }}</span>
        </div>
      </div>

      <p class="text-gray-600 mt-2">{{ place.address }}</p>

      <!-- 年齡範圍 -->
      <div class="mt-4">
        <span class="text-sm text-gray-500">適合年齡</span>
        <div class="flex items-center mt-1">
          <span class="bg-primary-100 text-primary-700 px-3 py-1 rounded-full font-medium">
            {{ place.minAge || 0 }} - {{ place.maxAge || 18 }} 歲
          </span>
        </div>
      </div>

      <!-- 建議停留時間 -->
      <div class="mt-4">
        <span class="text-sm text-gray-500">建議停留時間</span>
        <p class="font-medium">{{ place.suggestedDurationMinutes || 60 }} 分鐘</p>
      </div>

      <!-- 票價 -->
      <div v-if="place.ticketPrice" class="mt-4">
        <span class="text-sm text-gray-500">票價</span>
        <p class="font-medium text-lg text-green-600">NT$ {{ place.ticketPrice }}</p>
      </div>

      <!-- 設施 -->
      <div v-if="place.facilities && place.facilities.length > 0" class="mt-4">
        <span class="text-sm text-gray-500">設施標籤</span>
        <div class="flex flex-wrap gap-2 mt-1">
          <span
            v-for="facility in place.facilities"
            :key="facility"
            class="bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-sm"
          >
            {{ facility }}
          </span>
        </div>
      </div>

      <!-- 描述 -->
      <div v-if="place.description" class="mt-4">
        <span class="text-sm text-gray-500">景點介紹</span>
        <p class="mt-1 text-gray-700">{{ place.description }}</p>
      </div>

      <!-- 聯絡資訊 -->
      <div class="mt-6 border-t pt-4">
        <div v-if="place.phone" class="flex items-center text-sm text-gray-600">
          <span class="mr-2">📞</span>
          <a :href="`tel:${place.phone}`" class="hover:text-primary-600">{{ place.phone }}</a>
        </div>
        <div v-if="place.website" class="flex items-center text-sm text-gray-600 mt-2">
          <span class="mr-2">🌐</span>
          <a :href="place.website" target="_blank" class="hover:text-primary-600 truncate">
            {{ place.website }}
          </a>
        </div>
      </div>

      <!-- 操作按鈕 -->
      <div class="mt-6 flex gap-3">
        <button
          @click="$emit('add-to-plan', place)"
          class="flex-1 bg-primary-500 text-white py-2 px-4 rounded-lg hover:bg-primary-600 transition-colors"
        >
          加入行程
        </button>
        <button
          @click="openInMaps"
          class="bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
        >
          導航
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  place: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close', 'add-to-plan'])

function openInMaps() {
  const url = `https://www.google.com/maps/dir/?api=1&destination=${props.place.latitude},${props.place.longitude}`
  window.open(url, '_blank')
}
</script>
