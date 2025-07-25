import axios from 'axios'

const API_BASE_URL = 'http://localhost:3000/api'

// Tạo axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor để thêm token
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
  },
)

// Response interceptor để xử lý lỗi
api.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  },
)

// Auth API
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (userData) => api.post('/auth/register', userData),
}

// Users API
export const usersAPI = {
  getAll: (params) => api.get('/users', { params }),
  create: (userData) => api.post('/users', userData),
  update: (id, userData) => api.put(`/users/${id}`, userData),
  delete: (id) => api.delete(`/users/${id}`),
}

// Categories API
export const categoriesAPI = {
  getAll: () => api.get('/categories'),
  create: (categoryData) => api.post('/categories', categoryData),
  update: (id, categoryData) => api.put(`/categories/${id}`, categoryData),
  delete: (id) => api.delete(`/categories/${id}`),
}

// Dishes API - FIXED VERSION
export const dishesAPI = {
  getAll: (params) => api.get('/dishes', { params }),
  create: (dishData) => {
    // Nếu đã là FormData thì không tạo lại
    if (dishData instanceof FormData) {
      return api.post('/dishes', dishData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    }

    // Nếu là object thường thì tạo FormData
    const formData = new FormData()
    Object.keys(dishData).forEach((key) => {
      if (dishData[key] !== null && dishData[key] !== undefined) {
        formData.append(key, dishData[key])
      }
    })
    return api.post('/dishes', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
  update: (id, dishData) => {
    // Nếu đã là FormData thì không tạo lại
    if (dishData instanceof FormData) {
      return api.put(`/dishes/${id}`, dishData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    }

    // Nếu là object thường thì tạo FormData
    const formData = new FormData()
    Object.keys(dishData).forEach((key) => {
      if (dishData[key] !== null && dishData[key] !== undefined) {
        formData.append(key, dishData[key])
      }
    })
    return api.put(`/dishes/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
  delete: (id) => api.delete(`/dishes/${id}`),
}

// Orders API - UPDATED WITH getById
export const ordersAPI = {
  getAll: (params) => api.get('/orders', { params }),
  getById: (id) => api.get(`/orders/${id}`),
  create: (orderData) => api.post('/orders', orderData),
  update: (id, orderData) => api.put(`/orders/${id}`, orderData),
  delete: (id) => api.delete(`/orders/${id}`),
}

// Order Items API - NEW
export const orderItemsAPI = {
  getByOrderId: (orderId) => api.get(`/order-items/order/${orderId}`),
  create: (orderItemData) => api.post('/order-items', orderItemData),
  update: (id, orderItemData) => api.put(`/order-items/${id}`, orderItemData),
  delete: (id) => api.delete(`/order-items/${id}`),
}

// Inventory API
export const inventoryAPI = {
  getAll: (params) => api.get('/inventory', { params }),
  create: (inventoryData) => api.post('/inventory', inventoryData),
  update: (id, inventoryData) => api.put(`/inventory/${id}`, inventoryData),
  delete: (id) => api.delete(`/inventory/${id}`),
}

// Inventory Logs API
export const inventoryLogsAPI = {
  getAll: (params) => api.get('/inventory-logs', { params }),
  create: (logData) => api.post('/inventory-logs', logData),
}

// Reservations API
export const reservationsAPI = {
  getAll: (params) => api.get('/reservations', { params }),
  create: (reservationData) => api.post('/reservations', reservationData),
  update: (id, reservationData) => api.put(`/reservations/${id}`, reservationData),
  delete: (id) => api.delete(`/reservations/${id}`),
}

// Dish Ingredients API
export const dishIngredientsAPI = {
  getAll: (params) => api.get('/dish-ingredients', { params }),
  create: (dishIngredientData) => api.post('/dish-ingredients', dishIngredientData),
  update: (id, dishIngredientData) => api.put(`/dish-ingredients/${id}`, dishIngredientData),
  delete: (id) => api.delete(`/dish-ingredients/${id}`),
}
