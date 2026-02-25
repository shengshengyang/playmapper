<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-800">待審核景點</h3>
      <span class="bg-orange-100 text-orange-700 px-2 py-1 rounded-full text-sm">
        {{ places.length }} 個待審核
      </span>
    </div>

    <div v-if="places.length === 0" class="text-center py-8 text-gray-400">
      目前沒有待審核的景點
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="place in places"
        :key="place.id"
        class="bg-white border rounded-lg p-4 hover:shadow-md transition-shadow"
      >
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <h4 class="font-semibold text-gray-800">{{ place.name }}</h4>
            <p class="text-sm text-gray-500 mt-1">{{ place.address }}</p>
            <div class="flex items-center gap-4 mt-2 text-sm text-gray-600">
              <span>適合 {{ place.minAge }}-{{ place.maxAge }} 歲</span>
              <span v-if="place.suggestedDurationMinutes">
                建議停留 {{ place.suggestedDurationMinutes }} 分鐘
              </span>
            </div>
            <p v-if="place.description" class="text-sm text-gray-600 mt-2">
              {{ place.description.substring(0, 100) }}{{ place.description.length > 100 ? '...' : '' }}
            </p>
          </div>

          <div class="flex gap-2 ml-4">
            <button
              @click="viewDetail(place)"
              class="px-3 py-1 text-sm border rounded hover:bg-gray-100 transition-colors"
            >
              查看
            </button>
          </div>
        </div>

        <div class="flex gap-2 mt-4 pt-4 border-t">
          <button
            @click="approve(place)"
            class="flex-1 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
          >
            通過
          </button>
          <button
            @click="showRejectDialog(place)"
            class="flex-1 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
          >
            拒絕
          </button>
        </div>
      </div>
    </div>

    <!-- 拒絕原因對話框 -->
    <div
      v-if="rejectingPlace"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold mb-4">拒絕原因</h3>
        <textarea
          v-model="rejectReason"
          rows="4"
          class="w-full px-3 py-2 border rounded-lg"
          placeholder="請輸入拒絕原因..."
        ></textarea>
        <div class="flex justify-end gap-2 mt-4">
          <button
            @click="cancelReject"
            class="px-4 py-2 border rounded-lg hover:bg-gray-100"
          >
            取消
          </button>
          <button
            @click="confirmReject"
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
          >
            確認拒絕
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  places: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['approve', 'reject', 'view'])

const rejectingPlace = ref(null)
const rejectReason = ref('')

function viewDetail(place) {
  emit('view', place)
}

function approve(place) {
  emit('approve', place)
}

function showRejectDialog(place) {
  rejectingPlace.value = place
  rejectReason.value = ''
}

function cancelReject() {
  rejectingPlace.value = null
  rejectReason.value = ''
}

function confirmReject() {
  emit('reject', rejectingPlace.value, rejectReason.value)
  cancelReject()
}
</script>
