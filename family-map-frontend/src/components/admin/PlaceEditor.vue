<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-800">編輯景點</h3>
      <button
        @click="$emit('close')"
        class="text-gray-400 hover:text-gray-600"
      >
        ✕
      </button>
    </div>

    <PlaceForm
      v-if="place"
      :initial-data="place"
      @submit="handleSave"
      @cancel="$emit('close')"
    />
  </div>
</template>

<script setup>
defineProps({
  place: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['save', 'close'])

function handleSave(data) {
  emit('save', data)
}
</script>
