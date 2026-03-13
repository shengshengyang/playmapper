<template>
  <div class="space-y-6">
    <div class="bg-white rounded-xl shadow-sm p-6">
      <h2 class="text-lg font-bold text-gray-800 mb-4">新增設施類型</h2>
      <form @submit.prevent="createType" class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">名稱</label>
          <input v-model="newType.name" required maxlength="50" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">排序</label>
          <input v-model.number="newType.sortOrder" type="number" min="0" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        <button class="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">新增</button>
      </form>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-6">
      <h2 class="text-lg font-bold text-gray-800 mb-4">設施類型管理</h2>
      <table class="w-full text-sm">
        <thead>
          <tr class="text-left border-b">
            <th class="py-2">名稱</th>
            <th class="py-2">排序</th>
            <th class="py-2">狀態</th>
            <th class="py-2">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in types" :key="item.id" class="border-b">
            <td class="py-2">
              <input v-model="item.name" maxlength="50" class="px-2 py-1 border rounded w-full" />
            </td>
            <td class="py-2 w-32">
              <input v-model.number="item.sortOrder" type="number" min="0" class="px-2 py-1 border rounded w-full" />
            </td>
            <td class="py-2 w-32">
              <label class="inline-flex items-center gap-2">
                <input type="checkbox" v-model="item.isActive" />
                <span>{{ item.isActive ? '啟用' : '停用' }}</span>
              </label>
            </td>
            <td class="py-2 w-48 space-x-2">
              <button @click="save(item)" class="px-3 py-1 bg-blue-500 text-white rounded">儲存</button>
              <button @click="remove(item.id)" class="px-3 py-1 bg-red-500 text-white rounded">刪除</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { infrastructureTypesApi } from '@/services/api'

const types = ref([])
const newType = ref({ name: '', sortOrder: 0, isActive: true })

async function fetchTypes() {
  const { data } = await infrastructureTypesApi.getAllForAdmin()
  types.value = data
}

async function createType() {
  await infrastructureTypesApi.create(newType.value)
  newType.value = { name: '', sortOrder: 0, isActive: true }
  await fetchTypes()
}

async function save(item) {
  await infrastructureTypesApi.update(item.id, {
    name: item.name,
    sortOrder: item.sortOrder,
    isActive: item.isActive
  })
  await fetchTypes()
}

async function remove(id) {
  if (!confirm('確定刪除這個類型？')) return
  await infrastructureTypesApi.delete(id)
  await fetchTypes()
}

onMounted(fetchTypes)
</script>
