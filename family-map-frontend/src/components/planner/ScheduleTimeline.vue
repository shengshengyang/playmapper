<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-800">行程時間軸</h3>

    <div v-if="schedule.length === 0" class="text-center text-gray-400 py-8">
      尚未建立行程
    </div>

    <div v-else class="relative">
      <!-- 時間線 -->
      <div class="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>

      <!-- 行程項目 -->
      <div class="space-y-4">
        <div
          v-for="(item, index) in schedule"
          :key="index"
          class="relative pl-10"
        >
          <!-- 節點 -->
          <div
            class="absolute left-2 w-5 h-5 rounded-full border-2 flex items-center justify-center"
            :class="getItemColor(item.type)"
          >
            <span class="text-xs">{{ getItemIcon(item.type) }}</span>
          </div>

          <!-- 內容 -->
          <div
            class="p-3 rounded-lg"
            :class="getItemBgColor(item.type)"
          >
            <div class="flex items-center justify-between">
              <span class="font-medium">{{ item.placeName || item.description }}</span>
              <span class="text-sm text-gray-500">
                {{ formatTime(item.startTime) }} - {{ formatTime(item.endTime) }}
              </span>
            </div>
            <div class="text-sm text-gray-500 mt-1">
              {{ item.durationMinutes }} 分鐘
              <span v-if="item.distance" class="ml-2">
                ({{ item.distance.toFixed(1) }} 公里)
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 統計資訊 -->
    <div v-if="schedule.length > 0" class="flex justify-between text-sm text-gray-500 border-t pt-4">
      <span>總距離: {{ totalDistance }} 公里</span>
      <span>總時間: {{ formatDuration(totalDuration) }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { formatTime as formatTimeUtil, formatDuration as formatDurationUtil } from '@/utils/timeCalculator'

const props = defineProps({
  schedule: {
    type: Array,
    default: () => []
  },
  totalDistance: {
    type: [Number, String],
    default: 0
  },
  totalDuration: {
    type: Number,
    default: 0
  }
})

function getItemColor(type) {
  const colors = {
    place: 'bg-primary-500 border-primary-500 text-white',
    driving: 'bg-gray-300 border-gray-300 text-gray-600',
    meal: 'bg-orange-500 border-orange-500 text-white',
    break: 'bg-green-500 border-green-500 text-white'
  }
  return colors[type] || colors.place
}

function getItemBgColor(type) {
  const colors = {
    place: 'bg-primary-50',
    driving: 'bg-gray-50',
    meal: 'bg-orange-50',
    break: 'bg-green-50'
  }
  return colors[type] || colors.place
}

function getItemIcon(type) {
  const icons = {
    place: '📍',
    driving: '🚗',
    meal: '🍽️',
    break: '☕'
  }
  return icons[type] || '📍'
}

function formatTime(date) {
  if (!date) return ''
  return formatTimeUtil(date)
}

function formatDuration(minutes) {
  return formatDurationUtil(minutes)
}
</script>
