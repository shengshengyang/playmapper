import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 請求攔截器
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 回應攔截器
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// 認證 API
export const authApi = {
  login: (data) => api.post('/users/login', data),
  logout: () => api.post('/users/logout'),
  getCurrentUser: () => api.get('/users/me')
}

// 景點 API
export const placesApi = {
  getAll: (params) => api.get('/places', { params }),
  getById: (id) => api.get(`/places/${id}`),
  create: (data) => api.post('/places', data),
  update: (id, data) => api.put(`/places/${id}`, data),
  delete: (id) => api.delete(`/places/${id}`),
  getAllStatus: () => api.get('/places/all')
}


// 設施類型 API
export const infrastructureTypesApi = {
  getOptions: () => api.get('/places/infrastructure-types'),
  getAllForAdmin: () => api.get('/admin/infrastructure-types'),
  create: (data) => api.post('/admin/infrastructure-types', data),
  update: (id, data) => api.put(`/admin/infrastructure-types/${id}`, data),
  delete: (id) => api.delete(`/admin/infrastructure-types/${id}`)
}

// 審核 API
export const reviewApi = {
  getPending: () => api.get('/admin/reviews/pending'),
  approve: (placeId, comment) => api.post(`/admin/reviews/${placeId}/approve`, { comment }),
  reject: (placeId, comment) => api.post(`/admin/reviews/${placeId}/reject`, { comment }),
  getHistory: (placeId) => api.get(`/admin/reviews/history/${placeId}`)
}

// 使用者 API
export const usersApi = {
  getAll: () => api.get('/admin/users'),
  updateRole: (userId, role) => api.put(`/admin/users/${userId}/role`, { role }),
  delete: (userId) => api.delete(`/admin/users/${userId}`)
}

// 統計 API
export const statisticsApi = {
  getStats: () => api.get('/admin/statistics')
}

export default api
