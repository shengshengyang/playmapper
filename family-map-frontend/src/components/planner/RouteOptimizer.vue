<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-800">路線優化控制</h3>

    <div class="bg-gray-50 rounded-lg p-4">
      <h4 class="text-sm font-medium text-gray-700 mb-3">優化選項</h4>

      <div class="space-y-3">
        <label class="flex items-center">
          <input
            v-model="options.minimizeDistance"
            type="checkbox"
            class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
          />
          <span class="ml-2 text-sm text-gray-600">最小化總距離</span>
        </label>

        <label class="flex items-center">
          <input
            v-model="options.considerTraffic"
            type="checkbox"
            class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
          />
          <span class="ml-2 text-sm text-gray-600">考慮交通狀況</span>
        </label>

        <label class="flex items-center">
          <input
            v-model="options.respectOpeningHours"
            type="checkbox"
            class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
          />
          <span class="ml-2 text-sm text-gray-600">遵守營業時間</span>
        </label>
      </div>
    </div>

    <div class="bg-gray-50 rounded-lg p-4">
      <h4 class="text-sm font-medium text-gray-700 mb-3">權重設定</h4>

      <div class="space-y-4">
        <div>
          <div class="flex justify-between text-sm mb-1">
            <span class="text-gray-600">距離權重</span>
            <span class="text-gray-800">{{ options.distanceWeight }}%</span>
          </div>
          <input
            v-model.number="options.distanceWeight"
            type="range"
            min="0"
            max="100"
            class="w-full"
          />
        </div>

        <div>
          <div class="flex justify-between text-sm mb-1">
            <span class="text-gray-600">時間權重</span>
            <span class="text-gray-800">{{ options.timeWeight }}%</span>
          </div>
          <input
            v-model.number="options.timeWeight"
            type="range"
            min="0"
            max="100"
            class="w-full"
          />
        </div>

        <div>
          <div class="flex justify-between text-sm mb-1">
            <span class="text-gray-600">評分權重</span>
            <span class="text-gray-800">{{ options.ratingWeight }}%</span>
          </div>
          <input
            v-model.number="options.ratingWeight"
            type="range"
            min="0"
            max="100"
            class="w-full"
          />
        </div>
      </div>
    </div>

    <button
      @click="optimize"
      :disabled="loading"
      class="w-full py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors disabled:opacity-50"
    >
      {{ loading ? '優化中...' : '開始優化' }}
    </button>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'

const emit = defineEmits(['optimize'])

const loading = ref(false)

const options = reactive({
  minimizeDistance: true,
  considerTraffic: false,
  respectOpeningHours: true,
  distanceWeight: 40,
  timeWeight: 30,
  ratingWeight: 10
})

async function optimize() {
  loading.value = true
  emit('optimize', { ...options })

  // 父組件負責設定 loading = false
  setTimeout(() => {
    loading.value = false
  }, 3000)
}
</script>
