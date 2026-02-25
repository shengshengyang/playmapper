import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/services/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('admin_token') || null)

  const isLoggedIn = computed(() => !!token.value)
  const username = computed(() => user.value?.username || '')

  async function login(username, password) {
    try {
      const response = await authApi.login({ username, password })
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('admin_token', response.data.token)
      return { success: true }
    } catch (error) {
      return { success: false, message: error.response?.data?.message || '登入失敗' }
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('admin_token')
  }

  function checkAuth() {
    const savedToken = localStorage.getItem('admin_token')
    if (savedToken) {
      token.value = savedToken
      // TODO: 驗證 token 有效性
    }
  }

  return {
    user,
    token,
    isLoggedIn,
    username,
    login,
    logout,
    checkAuth
  }
})
