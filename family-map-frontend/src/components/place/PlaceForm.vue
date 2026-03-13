<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">
設施點名稱 <span class="text-red-500">*</span>
      </label>
      <input
        v-model="form.name"
        type="text"
        required
        maxlength="200"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="請輸入設施點名稱"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">設施描述</label>
      <textarea
        v-model="form.description"
        rows="3"
        maxlength="2000"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="請輸入設施描述"
      ></textarea>
    </div>


    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">設施類型 <span class="text-red-500">*</span></label>
      <select
        v-model="form.infrastructureType"
        required
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
      >
        <option value="">請選擇設施類型</option>
        <option v-for="type in infrastructureTypeOptions" :key="type" :value="type">{{ type }}</option>
      </select>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">地址</label>
      <input
        v-model="form.address"
        type="text"
        maxlength="500"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="請輸入地址"
      />
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">緯度</label>
        <input
          v-model.number="form.latitude"
          type="number"
          step="any"
          class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          placeholder="24.1477"
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">經度</label>
        <input
          v-model.number="form.longitude"
          type="number"
          step="any"
          class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          placeholder="120.6736"
        />
      </div>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">最小適合年齡</label>
        <input
          v-model.number="form.minAge"
          type="number"
          min="0"
          max="18"
          class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">最大適合年齡</label>
        <input
          v-model.number="form.maxAge"
          type="number"
          min="0"
          max="18"
          class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        />
      </div>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">建議停留時間（分鐘）</label>
      <input
        v-model.number="form.suggestedDurationMinutes"
        type="number"
        min="15"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="60"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">票價</label>
      <input
        v-model.number="form.ticketPrice"
        type="number"
        min="0"
        step="any"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="0"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">聯絡電話</label>
      <input
        v-model="form.phone"
        type="tel"
        maxlength="20"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="04-12345678"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">官方網站</label>
      <input
        v-model="form.website"
        type="url"
        maxlength="500"
        class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        placeholder="https://example.com"
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">設施標籤</label>
      <div class="flex flex-wrap gap-2">
        <label
          v-for="facility in facilityOptions"
          :key="facility"
          class="flex items-center cursor-pointer"
        >
          <input
            type="checkbox"
            :value="facility"
            v-model="form.facilities"
            class="mr-1"
          />
          <span class="text-sm">{{ facility }}</span>
        </label>
      </div>
    </div>

    <div class="flex justify-end gap-3 pt-4">
      <button
        type="button"
        @click="$emit('cancel')"
        class="px-4 py-2 border rounded-lg hover:bg-gray-100 transition-colors"
      >
        取消
      </button>
      <button
        type="submit"
        class="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
      >
        提交
      </button>
    </div>
  </form>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { infrastructureTypesApi } from '@/services/api'

const emit = defineEmits(['submit', 'cancel'])

const form = reactive({
  name: '',
  infrastructureType: '',
  description: '',
  address: '',
  latitude: null,
  longitude: null,
  minAge: 0,
  maxAge: 18,
  suggestedDurationMinutes: 60,
  ticketPrice: null,
  phone: '',
  website: '',
  facilities: [],
  images: []
})

const infrastructureTypeOptions = ref([])

const facilityOptions = [
  '遊樂場',
  '餐廳',
  '停車場',
  '哺集乳室',
  '嬰兒車租借',
  '無障礙設施',
  '廁所',
  '親子廁所',
  '販賣部',
  '野餐區'
]



onMounted(async () => {
  try {
    const { data } = await infrastructureTypesApi.getOptions()
    infrastructureTypeOptions.value = data.map(type => type.name)
  } catch (error) {
    console.error('Error fetching infrastructure types:', error)
    infrastructureTypeOptions.value = ['親子廁所', '尿布台', '哺乳室', '無障礙廁所', '休息區']
  }
})

function handleSubmit() {
  emit('submit', { ...form })
}
</script>
