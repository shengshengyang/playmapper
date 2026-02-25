<template>
  <div
    class="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow cursor-pointer overflow-hidden"
    @click="$emit('click', place)"
  >
    <div class="relative h-40 bg-gray-200">
      <img
        v-if="place.images && place.images.length > 0"
        :src="place.images[0]"
        :alt="place.name"
        class="w-full h-full object-cover"
      />
      <div v-else class="w-full h-full flex items-center justify-center text-gray-400">
        <span class="text-4xl">🏞️</span>
      </div>
      <div class="absolute top-2 right-2 bg-white px-2 py-1 rounded-full text-sm font-medium">
        {{ place.rating?.toFixed(1) || 'N/A' }} ★
      </div>
    </div>

    <div class="p-4">
      <h3 class="font-bold text-lg text-gray-800 truncate">{{ place.name }}</h3>
      <p class="text-gray-500 text-sm mt-1 truncate">{{ place.address }}</p>

      <div class="flex items-center mt-3 text-sm">
        <span class="bg-primary-100 text-primary-700 px-2 py-1 rounded">
          {{ place.minAge || 0 }}-{{ place.maxAge || 18 }} 歲
        </span>
        <span class="ml-auto text-gray-400">
          {{ place.suggestedDurationMinutes || 60 }} 分鐘
        </span>
      </div>

      <div v-if="place.facilities && place.facilities.length > 0" class="flex flex-wrap gap-1 mt-3">
        <span
          v-for="facility in place.facilities.slice(0, 3)"
          :key="facility"
          class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded"
        >
          {{ facility }}
        </span>
        <span
          v-if="place.facilities.length > 3"
          class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded"
        >
          +{{ place.facilities.length - 3 }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  place: {
    type: Object,
    required: true
  }
})

defineEmits(['click'])
</script>
