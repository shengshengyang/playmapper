<template>
  <div class="bg-neutral-50 rounded-xl p-3.5">
    <div class="flex items-center gap-2 mb-3">
      <Users class="w-4 h-4 text-neutral-500" />
      <span class="text-sm font-medium text-neutral-700">適合年齡</span>
    </div>

    <!-- 年齡輸入 -->
    <div class="flex items-center gap-2 mb-3">
      <div class="flex-1">
        <label class="text-xs text-neutral-500 mb-1 block">最小</label>
        <input
          type="number"
          v-model.number="localMinAge"
          min="0"
          max="18"
          class="input text-center text-sm"
          @change="updateFilter"
        />
      </div>
      <span class="text-neutral-300 mt-4">~</span>
      <div class="flex-1">
        <label class="text-xs text-neutral-500 mb-1 block">最大</label>
        <input
          type="number"
          v-model.number="localMaxAge"
          min="0"
          max="18"
          class="input text-center text-sm"
          @change="updateFilter"
        />
      </div>
      <span class="text-sm text-neutral-400 mt-4">歲</span>
    </div>

    <!-- 快捷選項 -->
    <div class="flex flex-wrap gap-1.5">
      <button
        v-for="preset in presets"
        :key="preset.label"
        @click="applyPreset(preset)"
        class="age-preset-btn"
        :class="{ 'age-preset-btn-active': isActive(preset) }"
      >
        {{ preset.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Users } from 'lucide-vue-next'

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
  { label: '青少年', minAge: 12, maxAge: 18 },
  { label: '全部', minAge: 0, maxAge: 18 }
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

<style scoped>
.age-preset-btn {
  @apply px-2.5 py-1.5 rounded-lg text-xs font-medium border border-neutral-200 bg-white
         text-neutral-600 transition-all duration-200
         hover:border-primary-300 hover:text-primary-600;
}

.age-preset-btn-active {
  @apply border-primary-400 bg-primary-50 text-primary-700;
}
</style>
