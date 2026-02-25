<template>
  <div class="flex items-center gap-4">
    <span class="text-sm text-gray-600">適合年齡</span>
    <div class="flex items-center gap-2">
      <input
        type="number"
        v-model.number="localMinAge"
        min="0"
        max="18"
        class="w-16 px-2 py-1 border rounded text-center"
        @change="updateFilter"
      />
      <span class="text-gray-400">-</span>
      <input
        type="number"
        v-model.number="localMaxAge"
        min="0"
        max="18"
        class="w-16 px-2 py-1 border rounded text-center"
        @change="updateFilter"
      />
      <span class="text-sm text-gray-500">歲</span>
    </div>

    <!-- 快捷選項 -->
    <div class="flex gap-2">
      <button
        v-for="preset in presets"
        :key="preset.label"
        @click="applyPreset(preset)"
        class="text-xs px-2 py-1 rounded border hover:bg-gray-100 transition-colors"
        :class="{ 'bg-primary-100 border-primary-300 text-primary-700': isActive(preset) }"
      >
        {{ preset.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  minAge: {
    type: Number,
    default: 0
  },
  maxAge: {
    type: Number,
    default: 18
  }
})

const emit = defineEmits(['update:minAge', 'update:maxAge', 'change'])

const localMinAge = ref(props.minAge)
const localMaxAge = ref(props.maxAge)

const presets = [
  { label: '嬰幼兒', minAge: 0, maxAge: 3 },
  { label: '幼兒園', minAge: 3, maxAge: 6 },
  { label: '國小', minAge: 6, maxAge: 12 },
  { label: '青少年', minAge: 12, maxAge: 18 }
]

watch(() => props.minAge, (val) => {
  localMinAge.value = val
})

watch(() => props.maxAge, (val) => {
  localMaxAge.value = val
})

function updateFilter() {
  emit('update:minAge', localMinAge.value)
  emit('update:maxAge', localMaxAge.value)
  emit('change', { minAge: localMinAge.value, maxAge: localMaxAge.value })
}

function applyPreset(preset) {
  localMinAge.value = preset.minAge
  localMaxAge.value = preset.maxAge
  updateFilter()
}

function isActive(preset) {
  return localMinAge.value === preset.minAge && localMaxAge.value === preset.maxAge
}
</script>
