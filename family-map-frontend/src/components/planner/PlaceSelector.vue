<template>
  <div class="space-y-4">
    <h3 class="text-lg font-semibold text-gray-800">選擇景點</h3>

    <!-- 搜尋框 -->
    <div class="relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="搜尋景點..."
        class="w-full px-4 py-2 pl-10 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
      />
      <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
    </div>

    <!-- 景點列表 -->
    <div class="max-h-96 overflow-y-auto space-y-2">
      <div
        v-for="place in filteredPlaces"
        :key="place.id"
        @click="togglePlace(place)"
        class="flex items-center p-3 border rounded-lg cursor-pointer transition-colors"
        :class="isSelected(place.id)
          ? 'bg-primary-50 border-primary-300'
          : 'hover:bg-gray-50'"
      >
        <div
          class="w-5 h-5 rounded border-2 mr-3 flex items-center justify-center"
          :class="isSelected(place.id)
            ? 'bg-primary-500 border-primary-500'
            : 'border-gray-300'"
        >
          <span v-if="isSelected(place.id)" class="text-white text-xs">✓</span>
        </div>

        <div class="flex-1 min-w-0">
          <h4 class="font-medium text-gray-800 truncate">{{ place.name }}</h4>
          <p class="text-sm text-gray-500 truncate">{{ place.address }}</p>
        </div>

        <span class="text-sm text-gray-400">
          {{ place.minAge }}-{{ place.maxAge }}歲
        </span>
      </div>

      <p v-if="filteredPlaces.length === 0" class="text-center text-gray-400 py-4">
        沒有找到符合條件的景點
      </p>
    </div>

    <!-- 已選擇數量 -->
    <div class="text-sm text-gray-500">
      已選擇 {{ selectedPlaces.length }} 個景點
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  places: {
    type: Array,
    default: () => []
  },
  selectedPlaces: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select', 'deselect'])

const searchQuery = ref('')

const filteredPlaces = computed(() => {
  if (!searchQuery.value) return props.places

  const query = searchQuery.value.toLowerCase()
  return props.places.filter(place =>
    place.name.toLowerCase().includes(query) ||
    (place.address && place.address.toLowerCase().includes(query))
  )
})

function isSelected(placeId) {
  return props.selectedPlaces.some(p => p.id === placeId)
}

function togglePlace(place) {
  if (isSelected(place.id)) {
    emit('deselect', place)
  } else {
    emit('select', place)
  }
}
</script>
