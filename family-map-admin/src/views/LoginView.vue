<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8">
      <!-- Logo -->
      <div class="text-center mb-8">
        <div class="text-4xl mb-2">🗺️</div>
        <h1 class="text-2xl font-bold text-gray-800">親子遊玩地圖</h1>
        <p class="text-gray-500 mt-1">管理後台登入</p>
      </div>

      <!-- 登入表單 -->
      <form @submit.prevent="handleLogin" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">帳號</label>
          <input
            v-model="form.username"
            type="text"
            required
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
            placeholder="請輸入帳號"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">密碼</label>
          <input
            v-model="form.password"
            type="password"
            required
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
            placeholder="請輸入密碼"
          />
        </div>

        <div class="flex items-center justify-between">
          <label class="flex items-center">
            <input v-model="form.remember" type="checkbox" class="rounded border-gray-300 text-primary-600" />
            <span class="ml-2 text-sm text-gray-600">記住我</span>
          </label>
        </div>

        <!-- 錯誤訊息 -->
        <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">
          {{ error }}
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-primary-500 text-white py-3 rounded-lg font-medium hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="loading" class="flex items-center justify-center">
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            登入中...
          </span>
          <span v-else>登入</span>
        </button>
      </form>

      <!-- 預設帳號提示 -->
      <div class="mt-6 p-4 bg-gray-50 rounded-lg">
        <p class="text-xs text-gray-500 text-center">
          預設管理員帳號: admin / admin123
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const error = ref('')

const form = reactive({
  username: '',
  password: '',
  remember: false
})

async function handleLogin() {
  if (!form.username || !form.password) {
    error.value = '請輸入帳號和密碼'
    return
  }

  loading.value = true
  error.value = ''

  try {
    // 模擬登入（開發階段）
    if (form.username === 'admin' && form.password === 'admin123') {
      localStorage.setItem('admin_token', 'mock-jwt-token')
      authStore.user = { username: 'admin', role: 'admin' }
      router.push('/dashboard')
      return
    }

    const result = await authStore.login(form.username, form.password)

    if (result.success) {
      router.push('/dashboard')
    } else {
      error.value = result.message
    }
  } catch (err) {
    error.value = '登入發生錯誤，請稍後再試'
  } finally {
    loading.value = false
  }
}
</script>
