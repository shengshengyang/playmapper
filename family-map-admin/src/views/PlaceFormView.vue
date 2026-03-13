<template>
  <div class="max-w-3xl mx-auto">
    <div class="bg-white rounded-xl shadow-sm">
      <div class="p-6 border-b">
        <h2 class="text-xl font-bold text-gray-800">
          {{ isEdit ? '編輯設施點' : '新增設施點' }}
        </h2>
      </div>

      <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
        <!-- 基本資訊 -->
        <div class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">基本資訊</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">
                設施點名稱 <span class="text-red-500">*</span>
              </label>
              <input
                v-model="form.name"
                type="text"
                required
                maxlength="200"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="請輸入設施點名稱"
              />
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">設施描述</label>
              <textarea
                v-model="form.description"
                rows="4"
                maxlength="2000"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="請輸入設施描述"
              ></textarea>
            </div>


            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">設施類型 <span class="text-red-500">*</span></label>
              <select
                v-model="form.infrastructureType"
                required
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">請選擇</option>
                <option v-for="type in infrastructureTypeOptions" :key="type" :value="type">{{ type }}</option>
              </select>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">地址</label>
              <input
                v-model="form.address"
                type="text"
                maxlength="500"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="請輸入地址"
              />
            </div>
          </div>
        </div>

        <!-- 位置選擇 -->
        <div class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">
            位置座標
            <span class="text-sm font-normal text-gray-500 ml-2">（可直接輸入或點擊地圖選擇）</span>
          </h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">緯度 <span class="text-red-500">*</span></label>
              <input
                v-model.number="form.latitude"
                @input="syncMapFromInput"
                type="number"
                step="any"
                required
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="24.1477"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">經度 <span class="text-red-500">*</span></label>
              <input
                v-model.number="form.longitude"
                @input="syncMapFromInput"
                type="number"
                step="any"
                required
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="120.6736"
              />
            </div>
          </div>

          <!-- 地圖選擇器 -->
          <div class="border rounded-lg overflow-hidden">
            <div class="bg-gray-50 px-4 py-2 border-b flex items-center justify-between">
              <span class="text-sm text-gray-600">點擊地圖選擇位置</span>
              <div class="flex gap-2">
                <button
                  type="button"
                  @click="centerOnTaiwan"
                  class="text-xs px-2 py-1 bg-gray-200 hover:bg-gray-300 rounded transition-colors"
                >
                  回到台灣
                </button>
                <button
                  type="button"
                  @click="centerOnCurrentLocation"
                  class="text-xs px-2 py-1 bg-blue-100 text-blue-700 hover:bg-blue-200 rounded transition-colors"
                >
                  我的定位
                </button>
              </div>
            </div>
            <div class="h-80 relative">
              <l-map
                ref="mapRef"
                v-model:zoom="mapZoom"
                v-model:center="mapCenter"
                @click="onMapClick"
                class="w-full h-full"
              >
                <l-tile-layer
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  layer-type="base"
                  name="OpenStreetMap"
                  attribution="&copy; OpenStreetMap contributors"
                />
                <l-marker
                  v-if="form.latitude && form.longitude"
                  :lat-lng="[form.latitude, form.longitude]"
                  draggable
                  @dragend="onMarkerDrag"
                />
              </l-map>
            </div>
          </div>
        </div>

        <!-- 親子屬性 -->
        <div class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">親子屬性</h3>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">最小適合年齡</label>
              <input
                v-model.number="form.minAge"
                type="number"
                min="0"
                max="18"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">最大適合年齡</label>
              <input
                v-model.number="form.maxAge"
                type="number"
                min="0"
                max="18"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">建議停留（分鐘）</label>
              <input
                v-model.number="form.suggestedDurationMinutes"
                type="number"
                min="15"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="60"
              />
            </div>
          </div>
        </div>

        <!-- 票價與聯絡 -->
        <div class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">票價與聯絡資訊</h3>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">票價（元）</label>
              <input
                v-model.number="form.ticketPrice"
                type="number"
                min="0"
                step="any"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="0 為免費"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">聯絡電話</label>
              <input
                v-model="form.phone"
                type="tel"
                maxlength="20"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="04-12345678"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">官方網站</label>
              <input
                v-model="form.website"
                type="url"
                maxlength="500"
                class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="https://"
              />
            </div>
          </div>
        </div>

        <!-- 設施標籤 -->
        <div class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">設施標籤</h3>

          <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
            <label
              v-for="facility in facilityOptions"
              :key="facility"
              class="flex items-center p-3 border rounded-lg cursor-pointer transition-colors"
              :class="form.facilities.includes(facility)
                ? 'bg-primary-50 border-primary-300'
                : 'hover:bg-gray-50'"
            >
              <input
                type="checkbox"
                :value="facility"
                v-model="form.facilities"
                class="sr-only"
              />
              <span
                class="w-4 h-4 border-2 rounded mr-2 flex items-center justify-center"
                :class="form.facilities.includes(facility)
                  ? 'bg-primary-500 border-primary-500'
                  : 'border-gray-300'"
              >
                <span v-if="form.facilities.includes(facility)" class="text-white text-xs">✓</span>
              </span>
              <span class="text-sm text-gray-700">{{ facility }}</span>
            </label>
          </div>
        </div>

        <!-- 審核狀態（編輯時顯示） -->
        <div v-if="isEdit" class="space-y-4">
          <h3 class="font-medium text-gray-700 border-b pb-2">審核狀態</h3>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">狀態</label>
            <div class="flex gap-4">
              <label class="flex items-center">
                <input type="radio" value="approved" v-model="form.status" class="mr-2" />
                <span class="text-sm">已通過</span>
              </label>
              <label class="flex items-center">
                <input type="radio" value="pending" v-model="form.status" class="mr-2" />
                <span class="text-sm">待審核</span>
              </label>
              <label class="flex items-center">
                <input type="radio" value="rejected" v-model="form.status" class="mr-2" />
                <span class="text-sm">已拒絕</span>
              </label>
            </div>
          </div>
        </div>

        <!-- 提交按鈕 -->
        <div class="flex justify-end gap-3 pt-6 border-t">
          <button
            type="button"
            @click="handleCancel"
            class="px-6 py-2 border rounded-lg hover:bg-gray-50 transition-colors"
          >
            取消
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="px-6 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors disabled:opacity-50"
          >
            {{ loading ? '儲存中...' : '儲存' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { usePlacesStore } from '@/stores/placesStore'
import { LMap, LTileLayer, LMarker } from '@vue-leaflet/vue-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

// 修復 Leaflet 預設 icon 問題
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
})

const route = useRoute()
const router = useRouter()
const placesStore = usePlacesStore()

const isEdit = computed(() => !!route.params.id)
const loading = ref(false)

// 地圖相關
const mapRef = ref(null)
const mapZoom = ref(12)
const mapCenter = ref([24.1477, 120.6736]) // 預設台中市

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
  status: 'approved'
})

const infrastructureTypeOptions = ['親子廁所', '尿布台', '哺乳室', '無障礙廁所', '休息區']

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
  '野餐區',
  '沙坑',
  '戲水池',
  '溜滑梯',
  '盪秋千',
  '攀爬架'
]

onMounted(async () => {
  if (isEdit.value) {
    // 載入景點資料
    const place = await placesStore.getPlaceById(route.params.id)
    if (place) {
      Object.assign(form, {
        name: place.name || '',
        infrastructureType: place.infrastructureType || '',
        description: place.description || '',
        address: place.address || '',
        latitude: place.latitude,
        longitude: place.longitude,
        minAge: place.minAge ?? 0,
        maxAge: place.maxAge ?? 18,
        suggestedDurationMinutes: place.suggestedDurationMinutes || 60,
        ticketPrice: place.ticketPrice,
        phone: place.phone || '',
        website: place.website || '',
        facilities: place.facilities || [],
        status: place.status || 'approved'
      })
    }

    // 模擬資料
    if (route.params.id === '1') {
      Object.assign(form, {
        name: '科博館親子廁所',
        infrastructureType: '親子廁所',
        description: '台中國立自然科學博物館是一個非常適合親子同遊的景點...',
        address: '台中市北區館前路1號',
        latitude: 24.1578,
        longitude: 120.6652,
        minAge: 3,
        maxAge: 18,
        suggestedDurationMinutes: 180,
        ticketPrice: 100,
        phone: '04-23226940',
        website: 'https://www.nmns.edu.tw',
        facilities: ['停車場', '餐廳', '哺集乳室', '無障礙設施', '廁所'],
        status: 'approved'
      })
    }
  }

  // 如果有座標，將地圖中心移到該位置
  if (form.latitude && form.longitude) {
    mapCenter.value = [form.latitude, form.longitude]
    mapZoom.value = 15
  }
})

// 地圖相關函數
function onMapClick(event) {
  form.latitude = Number(event.latlng.lat.toFixed(6))
  form.longitude = Number(event.latlng.lng.toFixed(6))
}

function onMarkerDrag(event) {
  const latlng = event.target.getLatLng()
  form.latitude = Number(latlng.lat.toFixed(6))
  form.longitude = Number(latlng.lng.toFixed(6))
}

function syncMapFromInput() {
  if (form.latitude && form.longitude) {
    mapCenter.value = [form.latitude, form.longitude]
  }
}

function centerOnTaiwan() {
  mapCenter.value = [23.97565, 120.973882]
  mapZoom.value = 8
}

function centerOnCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        mapCenter.value = [position.coords.latitude, position.coords.longitude]
        mapZoom.value = 15
        form.latitude = Number(position.coords.latitude.toFixed(6))
        form.longitude = Number(position.coords.longitude.toFixed(6))
      },
      (error) => {
        alert('無法獲取您的位置，請手動選擇或輸入座標')
      }
    )
  } else {
    alert('您的瀏覽器不支援地理定位功能')
  }
}

async function handleSubmit() {
  loading.value = true

  try {
    let result
    if (isEdit.value) {
      result = await placesStore.updatePlace(route.params.id, { ...form })
    } else {
      result = await placesStore.createPlace({ ...form })
    }

    // 模擬成功
    await new Promise(resolve => setTimeout(resolve, 500))

    alert(isEdit.value ? '設施點已更新' : '設施點已建立')
    router.push('/places')
  } catch (error) {
    alert('儲存失敗，請稍後再試')
  } finally {
    loading.value = false
  }
}

function handleCancel() {
  if (confirm('確定要取消嗎？未儲存的變更將會遺失。')) {
    router.push('/places')
  }
}
</script>
