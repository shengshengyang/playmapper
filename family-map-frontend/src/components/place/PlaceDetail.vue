<template>
  <div class="h-full flex flex-col bg-white">
    <!-- 圖片區域 -->
    <div class="relative h-48 flex-shrink-0 bg-neutral-100">
      <img
        v-if="place.images && place.images.length > 0"
        :src="place.images[0]"
        :alt="place.name"
        class="w-full h-full object-cover"
      />
      <div v-else class="w-full h-full flex items-center justify-center">
        <Image class="w-10 h-10 text-neutral-300" />
      </div>

      <!-- 關閉按鈕 -->
      <button
        @click="$emit('close')"
        class="absolute top-3 right-3 icon-btn bg-white/90"
      >
        <X class="w-4 h-4" />
      </button>

      <!-- 圖片指示器 -->
      <div v-if="place.images && place.images.length > 1" class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5">
        <span
          v-for="(img, index) in place.images.slice(0, 5)"
          :key="index"
          class="w-1.5 h-1.5 rounded-full bg-white/60"
          :class="{ 'bg-white w-4': index === 0 }"
        ></span>
      </div>
    </div>

    <!-- 內容區域 -->
    <div class="flex-1 overflow-y-auto p-5">
      <!-- 標題和評分 -->
      <div class="flex items-start justify-between gap-3">
        <h2 class="text-lg font-semibold text-neutral-800 flex-1">{{ place.name }}</h2>
        <div v-if="place.rating" class="flex items-center gap-1.5 bg-amber-50 px-2.5 py-1 rounded-lg flex-shrink-0">
          <Star class="w-3.5 h-3.5 text-amber-500 fill-amber-500" />
          <span class="text-sm font-semibold text-amber-700">{{ place.rating.toFixed(1) }}</span>
        </div>
      </div>

      <!-- 地址 -->
      <p class="text-neutral-500 text-sm mt-2 flex items-center gap-1.5">
        <MapPin class="w-4 h-4 flex-shrink-0" />
        <span>{{ place.address || '尚未提供地址' }}</span>
      </p>

      <!-- 資訊卡片 -->
      <div class="grid grid-cols-2 gap-3 mt-5">
        <!-- 設施類型 -->
        <div class="bg-neutral-50 rounded-xl p-3">
          <div class="flex items-center gap-2 mb-1.5">
            <Users class="w-4 h-4 text-primary-500" />
            <span class="text-xs text-neutral-500 font-medium">設施類型</span>
          </div>
          <p class="text-sm font-semibold text-neutral-700">
            {{ place.infrastructureType || "一般設施" }}
          </p>
        </div>

        <!-- 建議時間 -->
        <div class="bg-neutral-50 rounded-xl p-3">
          <div class="flex items-center gap-2 mb-1.5">
            <Clock class="w-4 h-4 text-primary-500" />
            <span class="text-xs text-neutral-500 font-medium">建議停留</span>
          </div>
          <p class="text-sm font-semibold text-neutral-700">
            {{ place.suggestedDurationMinutes || 60 }} 分鐘
          </p>
        </div>

        <!-- 票價 -->
        <div v-if="place.ticketPrice" class="bg-neutral-50 rounded-xl p-3">
          <div class="flex items-center gap-2 mb-1.5">
            <Ticket class="w-4 h-4 text-primary-500" />
            <span class="text-xs text-neutral-500 font-medium">門票價格</span>
          </div>
          <p class="text-sm font-semibold text-neutral-700">
            NT$ {{ place.ticketPrice }}
          </p>
        </div>

        <!-- 評論數 -->
        <div class="bg-neutral-50 rounded-xl p-3">
          <div class="flex items-center gap-2 mb-1.5">
            <MessageSquare class="w-4 h-4 text-primary-500" />
            <span class="text-xs text-neutral-500 font-medium">評論數</span>
          </div>
          <p class="text-sm font-semibold text-neutral-700">
            {{ place.reviewCount || 0 }} 則
          </p>
        </div>
      </div>

      <!-- 設施標籤 -->
      <div v-if="place.facilities && place.facilities.length > 0" class="mt-5">
        <h3 class="text-sm font-medium text-neutral-700 mb-2">設施</h3>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="facility in place.facilities"
            :key="facility"
            class="badge-neutral"
          >
            {{ facility }}
          </span>
        </div>
      </div>

      <!-- 景點介紹 -->
      <div v-if="place.description" class="mt-5">
        <h3 class="text-sm font-medium text-neutral-700 mb-2">介紹</h3>
        <p class="text-neutral-600 text-sm leading-relaxed">
          {{ place.description }}
        </p>
      </div>

      <!-- 聯絡資訊 -->
      <div class="mt-5 pt-4 border-t border-neutral-100 space-y-2">
        <a
          v-if="place.phone"
          :href="`tel:${place.phone}`"
          class="flex items-center gap-3 text-sm text-neutral-600 hover:text-primary-600 transition-colors py-1"
        >
          <div class="w-8 h-8 bg-secondary-50 rounded-lg flex items-center justify-center">
            <Phone class="w-4 h-4 text-secondary-600" />
          </div>
          {{ place.phone }}
        </a>
        <a
          v-if="place.website"
          :href="place.website"
          target="_blank"
          class="flex items-center gap-3 text-sm text-neutral-600 hover:text-primary-600 transition-colors py-1"
        >
          <div class="w-8 h-8 bg-primary-50 rounded-lg flex items-center justify-center">
            <Globe class="w-4 h-4 text-primary-600" />
          </div>
          <span class="truncate">{{ place.website }}</span>
        </a>
      </div>
    </div>

    <!-- 底部操作按鈕 -->
    <div class="flex-shrink-0 p-4 border-t border-neutral-100 bg-white">
      <div class="flex gap-3">
        <button
          @click="$emit('add-to-plan', place)"
          class="flex-1 btn-primary"
        >
          <Heart class="w-4 h-4" />
          加入行程
        </button>
        <button
          @click="openInMaps"
          class="btn-outline"
        >
          <Navigation class="w-4 h-4" />
          導航
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { X, Star, MapPin, Users, Clock, Ticket, MessageSquare, Phone, Globe, Heart, Navigation, Image } from 'lucide-vue-next'

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
