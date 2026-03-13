<template>
  <div class="bg-white rounded-xl shadow-sm p-6">
    <h3 class="font-semibold text-gray-800 mb-4">審核狀態分布</h3>
    <div class="h-64">
      <Pie v-if="hasData" :data="chartData" :options="chartOptions" />
      <div v-else class="h-full flex items-center justify-center text-gray-400">
        暫無數據
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Pie } from 'vue-chartjs'
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend
} from 'chart.js'

ChartJS.register(ArcElement, Tooltip, Legend)

const props = defineProps({
  stats: {
    type: Object,
    default: () => ({
      pendingReview: 0,
      approved: 0,
      rejected: 0
    })
  }
})

const hasData = computed(() => {
  return props.stats.pendingReview > 0 || props.stats.approved > 0 || props.stats.rejected > 0
})

const chartData = computed(() => ({
  labels: ['待審核', '已通過', '已拒絕'],
  datasets: [
    {
      data: [props.stats.pendingReview, props.stats.approved, props.stats.rejected],
      backgroundColor: ['#F59E0B', '#10B981', '#EF4444'],
      borderColor: ['#D97706', '#059669', '#DC2626'],
      borderWidth: 1
    }
  ]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom'
    }
  }
}
</script>
