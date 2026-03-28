import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 請求攔截器
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
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
      localStorage.removeItem('token')
      window.location.href = '/'
    }
    return Promise.reject(error)
  }
)

// 景點 API
export const placesApi = {
  getAll: () => api.get('/places'),
  // 地圖點位專用端點（預留給後端，需包含 reviewStatus / infrastructureType）
  getMapMarkers: () => api.get('/places/map-markers'),
  getById: (id) => api.get(`/places/${id}`),
  getNearby: (lat, lng, radius, minAge, maxAge) =>
    api.get('/places/nearby', { params: { lat, lng, radius, minAge, maxAge } }),
  search: (keyword, age, facility) =>
    api.get('/places/search', { params: { keyword, age, facility } }),
  create: (data) => api.post('/places', data),
  update: (id, data) => api.put(`/places/${id}`, data),
  delete: (id) => api.delete(`/places/${id}`)
}


// 設施類型 API
export const infrastructureTypesApi = {
  getOptions: () => api.get('/places/infrastructure-types')
}

// 行程規劃 API
export const plannerApi = {
  optimize: (data) => api.post('/planner/optimize', data),
  getDistanceMatrix: (placeIds) => api.post('/planner/distance-matrix', placeIds)
}

// 審核管理 API
export const reviewApi = {
  getPending: () => api.get('/admin/reviews/pending'),
  approve: (placeId, comment) => api.post(`/admin/reviews/${placeId}/approve`, { comment }),
  reject: (placeId, comment) => api.post(`/admin/reviews/${placeId}/reject`, { comment }),
  getHistory: (placeId) => api.get(`/admin/reviews/history/${placeId}`)
}

// 使用者 API
export const userApi = {
  getCurrentUser: () => api.get('/users/me'),
  register: (data) => api.post('/users/register', data),
  login: (data) => api.post('/users/login', data),
  logout: () => api.post('/users/logout')
}

export default api
