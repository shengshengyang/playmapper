<template>
  <div class="space-y-6">
    <!-- 頂部操作列 -->
    <div class="bg-white rounded-xl shadow-sm p-4">
      <div class="flex items-center justify-between">
        <div class="relative flex-1 max-w-md">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜尋使用者..."
            class="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
          />
          <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
        </div>

        <div class="flex items-center gap-3">
          <select
            v-model="roleFilter"
            class="px-4 py-2 border rounded-lg"
          >
            <option value="">全部角色</option>
            <option value="admin">管理員</option>
            <option value="user">一般使用者</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 使用者列表 -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">使用者</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">信箱</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">角色</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">註冊時間</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">操作</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <tr
            v-for="user in filteredUsers"
            :key="user.id"
            class="hover:bg-gray-50"
          >
            <td class="px-6 py-4">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 font-medium">
                  {{ user.username[0].toUpperCase() }}
                </div>
                <div class="ml-3">
                  <div class="font-medium text-gray-900">{{ user.username }}</div>
                  <div class="text-sm text-gray-500">ID: {{ user.id }}</div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 text-sm text-gray-500">
              {{ user.email }}
            </td>
            <td class="px-6 py-4">
              <span
                class="inline-flex px-2 py-1 text-xs font-medium rounded-full"
                :class="user.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-700'"
              >
                {{ user.role === 'admin' ? '管理員' : '使用者' }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm text-gray-500">
              {{ formatDate(user.createdAt) }}
            </td>
            <td class="px-6 py-4 text-right">
              <div class="flex justify-end gap-2">
                <button
                  v-if="user.role !== 'admin'"
                  @click="makeAdmin(user)"
                  class="text-purple-600 hover:text-purple-800 text-sm"
                >
                  設為管理員
                </button>
                <button
                  v-if="user.id !== currentUserId"
                  @click="deleteUser(user)"
                  class="text-red-600 hover:text-red-800 text-sm"
                >
                  刪除
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="filteredUsers.length === 0" class="text-center py-12">
        <p class="text-gray-500">沒有找到符合條件的使用者</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import dayjs from 'dayjs'

const searchQuery = ref('')
const roleFilter = ref('')
const currentUserId = 1 // 當前登入的使用者 ID

const users = ref([
  { id: 1, username: 'admin', email: 'admin@familymap.com', role: 'admin', createdAt: '2024-01-01T00:00:00' },
  { id: 2, username: 'user1', email: 'user1@example.com', role: 'user', createdAt: '2024-02-15T10:30:00' },
  { id: 3, username: 'user2', email: 'user2@example.com', role: 'user', createdAt: '2024-02-20T14:45:00' },
  { id: 4, username: 'tester', email: 'tester@example.com', role: 'user', createdAt: '2024-03-01T09:00:00' },
  { id: 5, username: 'demo', email: 'demo@example.com', role: 'user', createdAt: '2024-03-10T16:20:00' },
])

const filteredUsers = computed(() => {
  let result = users.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(u =>
      u.username.toLowerCase().includes(query) ||
      u.email.toLowerCase().includes(query)
    )
  }

  if (roleFilter.value) {
    result = result.filter(u => u.role === roleFilter.value)
  }

  return result
})

function formatDate(date) {
  return dayjs(date).format('YYYY-MM-DD')
}

function makeAdmin(user) {
  if (confirm(`確定要將「${user.username}」設為管理員嗎？`)) {
    user.role = 'admin'
    alert('已設為管理員')
  }
}

function deleteUser(user) {
  if (confirm(`確定要刪除使用者「${user.username}」嗎？此操作無法復原。`)) {
    users.value = users.value.filter(u => u.id !== user.id)
    alert('已刪除使用者')
  }
}
</script>
