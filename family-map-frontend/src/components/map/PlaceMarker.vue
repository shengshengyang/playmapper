<template>
  <div class="marker-wrapper" @click="$emit('click', place)">
    <div
      class="marker-icon"
      :class="{ 'marker-selected': isSelected }"
      :style="{ backgroundColor: markerColor }"
    >
      <span class="marker-label">{{ index + 1 }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { getColorByAge } from '@/services/mapService'

const props = defineProps({
  place: {
    type: Object,
    required: true
  },
  index: {
    type: Number,
    default: 0
  },
  isSelected: {
    type: Boolean,
    default: false
  }
})

defineEmits(['click'])

const markerColor = computed(() => {
  return getColorByAge(props.place.minAge, props.place.maxAge)
})
</script>

<style scoped>
.marker-wrapper {
  cursor: pointer;
}

.marker-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  font-size: 14px;
  border: 3px solid white;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
  transition: transform 0.2s;
}

.marker-icon:hover {
  transform: scale(1.1);
}

.marker-selected {
  animation: pulse 1.5s infinite;
  box-shadow: 0 0 10px rgba(217, 70, 239, 0.6);
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(217, 70, 239, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(217, 70, 239, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(217, 70, 239, 0);
  }
}
</style>
