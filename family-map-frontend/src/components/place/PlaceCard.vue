<template>
  <div
    class="card-hover cursor-pointer overflow-hidden"
    @click="$emit('click', place)"
  >
    <!-- 圖片區域 -->
    <div class="relative h-36 bg-neutral-100">
      <img
        v-if="place.images && place.images.length > 0"
        :src="place.images[0]"
        :alt="place.name"
        class="w-full h-full object-cover"
      />
      <div v-else class="w-full h-full flex items-center justify-center">
        <Image class="w-8 h-8 text-neutral-300" />
      </div>

      <!-- 評分標籤 -->
      <div v-if="place.rating" class="absolute top-2.5 right-2.5 bg-white/95 px-2 py-1 rounded-md shadow-sm flex items-center gap-1">
        <Star class="w-3 h-3 text-amber-500 fill-amber-500" />
        <span class="text-xs font-semibold text-neutral-700">{{ place.rating.toFixed(1) }}</span>
      </div>
    </div>

    <!-- 內容區域 -->
    <div class="p-3.5">
      <!-- 景點名稱 -->
      <h3 class="font-semibold text-neutral-800 truncate">
        {{ place.name }}
      </h3>

      <!-- 地址 -->
      <p class="text-neutral-500 text-sm mt-1 truncate flex items-center gap-1">
        <MapPin class="w-3.5 h-3.5 flex-shrink-0" />
        <span class="truncate">{{ place.address || '尚未提供地址' }}</span>
      </p>

      <!-- 資訊標籤 -->
      <div class="flex items-center justify-between mt-3">
        <!-- 適合年齡 -->
        <div class="flex items-center gap-1.5">
          <Users class="w-3.5 h-3.5 text-neutral-400" />
          <span class="badge-neutral text-xs">
            {{ place.minAge || 0 }}-{{ place.maxAge || 18 }} 歲
          </span>
        </div>

        <!-- 建議時間 -->
        <div class="flex items-center gap-1 text-neutral-400 text-xs">
          <Clock class="w-3.5 h-3.5" />
          <span>{{ place.suggestedDurationMinutes || 60 }} 分鐘</span>
        </div>
      </div>

      <!-- 設施標籤 -->
      <div v-if="place.facilities && place.facilities.length > 0" class="flex flex-wrap gap-1.5 mt-3">
        <span
          v-for="facility in place.facilities.slice(0, 3)"
          :key="facility"
          class="badge-neutral text-xs"
        >
          {{ facility }}
        </span>
        <span
          v-if="place.facilities.length > 3"
          class="badge-neutral text-xs"
        >
          +{{ place.facilities.length - 3 }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Image, Star, MapPin, Users, Clock } from 'lucide-vue-next'

defineProps({
  place: {
    type: Object,
    required: true
  }
})

defineEmits(['click'])
</script>
