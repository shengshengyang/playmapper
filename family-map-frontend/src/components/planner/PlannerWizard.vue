<template>
  <div class="bg-white rounded-lg shadow-lg p-6">
    <h2 class="text-xl font-bold text-gray-800 mb-6">智慧行程規劃</h2>

    <!-- 步驟指示器 -->
    <div class="flex items-center mb-8">
      <div
        v-for="(step, index) in steps"
        :key="index"
        class="flex items-center"
      >
        <div
          class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium"
          :class="currentStep > index
            ? 'bg-primary-500 text-white'
            : currentStep === index
              ? 'bg-primary-100 text-primary-700 border-2 border-primary-500'
              : 'bg-gray-200 text-gray-500'"
        >
          {{ currentStep > index ? '✓' : index + 1 }}
        </div>
        <span class="ml-2 text-sm" :class="currentStep >= index ? 'text-gray-800' : 'text-gray-400'">
          {{ step }}
        </span>
        <div v-if="index < steps.length - 1" class="w-12 h-0.5 mx-2 bg-gray-200"></div>
      </div>
    </div>

    <!-- 步驟內容 -->
    <div class="min-h-[400px]">
      <!-- 步驟 1: 選擇景點 -->
      <div v-if="currentStep === 0">
        <PlaceSelector
          :places="availablePlaces"
          :selected-places="selectedPlaces"
          @select="addPlace"
          @deselect="removePlace"
        />
      </div>

      <!-- 步驟 2: 設定偏好 -->
      <div v-if="currentStep === 1" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            同行孩童年齡
          </label>
          <input
            v-model.number="childAge"
            type="number"
            min="0"
            max="18"
            class="w-32 px-3 py-2 border rounded-lg"
          />
          <span class="ml-2 text-gray-500">歲</span>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            出發時間
          </label>
          <input
            v-model="startTime"
            type="datetime-local"
            class="px-3 py-2 border rounded-lg"
          />
        </div>

        <div>
          <label class="flex items-center">
            <input v-model="autoInsertMeals" type="checkbox" class="mr-2" />
            <span class="text-sm text-gray-700">自動插入用餐時間</span>
          </label>
        </div>

        <div>
          <label class="flex items-center">
            <input v-model="autoInsertBreaks" type="checkbox" class="mr-2" />
            <span class="text-sm text-gray-700">每 2 小時自動插入休息時間</span>
          </label>
        </div>
      </div>

      <!-- 步驟 3: 優化結果 -->
      <div v-if="currentStep === 2">
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full mx-auto"></div>
          <p class="mt-4 text-gray-500">正在優化路線...</p>
        </div>

        <ScheduleTimeline
          v-else
          :schedule="schedule"
          :total-distance="totalDistance"
          :total-duration="totalDuration"
        />
      </div>
    </div>

    <!-- 導航按鈕 -->
    <div class="flex justify-between mt-6 pt-6 border-t">
      <button
        v-if="currentStep > 0"
        @click="prevStep"
        class="px-4 py-2 border rounded-lg hover:bg-gray-100 transition-colors"
      >
        上一步
      </button>
      <div v-else></div>

      <button
        v-if="currentStep < 2"
        @click="nextStep"
        :disabled="!canProceed"
        class="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        下一步
      </button>
      <button
        v-else
        @click="saveTrip"
        class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
      >
        儲存行程
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import PlaceSelector from './PlaceSelector.vue'
import ScheduleTimeline from './ScheduleTimeline.vue'

const props = defineProps({
  availablePlaces: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['save'])

const steps = ['選擇景點', '設定偏好', '優化結果']
const currentStep = ref(0)

const selectedPlaces = ref([])
const childAge = ref(5)
const startTime = ref('')
const autoInsertMeals = ref(true)
const autoInsertBreaks = ref(true)
const loading = ref(false)
const schedule = ref([])
const totalDistance = ref(0)
const totalDuration = ref(0)

const canProceed = computed(() => {
  if (currentStep.value === 0) {
    return selectedPlaces.value.length >= 2
  }
  if (currentStep.value === 1) {
    return startTime.value !== ''
  }
  return true
})

function addPlace(place) {
  selectedPlaces.value.push(place)
}

function removePlace(place) {
  selectedPlaces.value = selectedPlaces.value.filter(p => p.id !== place.id)
}

function nextStep() {
  if (!canProceed.value) return

  if (currentStep.value === 1) {
    optimizeRoute()
  }

  currentStep.value++
}

function prevStep() {
  currentStep.value--
}

async function optimizeRoute() {
  loading.value = true

  // 模擬優化過程
  await new Promise(resolve => setTimeout(resolve, 1500))

  // TODO: 呼叫實際 API
  // 這裡先建立模擬資料
  schedule.value = selectedPlaces.value.map((place, index) => ({
    type: 'place',
    placeId: place.id,
    placeName: place.name,
    startTime: new Date(),
    endTime: new Date(Date.now() + (place.suggestedDurationMinutes || 60) * 60000),
    durationMinutes: place.suggestedDurationMinutes || 60
  }))

  totalDistance.value = 15.5
  totalDuration.value = schedule.value.reduce((sum, item) => sum + item.durationMinutes, 0)

  loading.value = false
}

function saveTrip() {
  emit('save', {
    places: selectedPlaces.value,
    childAge: childAge.value,
    startTime: startTime.value,
    schedule: schedule.value
  })
}
</script>
