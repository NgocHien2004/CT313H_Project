// frontend-spa/src/services/api.js
import axios from 'axios'

// Sử dụng environment variable thay vì hardcode
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

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

// Dishes API
export const dishesAPI = {
  getAll: (params) => api.get('/dishes', { params }),
  getById: (id) => api.get(`/dishes/${id}/detail`),
  create: (formData) => {
    return api.post('/dishes', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
  update: (id, formData) => {
    return api.put(`/dishes/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
  delete: (id) => api.delete(`/dishes/${id}`),
}

// Dish Ingredients API
export const dishIngredientsAPI = {
  getByDishId: (dishId) => api.get(`/dish-ingredients/dish/${dishId}`),
  create: (data) => api.post('/dish-ingredients', data),
  update: (id, data) => api.put(`/dish-ingredients/${id}`, data),
  delete: (id) => api.delete(`/dish-ingredients/${id}`),
}

// Inventory API
export const inventoryAPI = {
  getAll: (params) => api.get('/inventory', { params }),
  getById: (id) => api.get(`/inventory/${id}`),
  create: (data) => api.post('/inventory', data),
  update: (id, data) => api.put(`/inventory/${id}`, data),
  delete: (id) => api.delete(`/inventory/${id}`),
}

// Orders API
export const ordersAPI = {
  getAll: (params) => api.get('/orders', { params }),
  getById: (id) => api.get(`/orders/${id}`),
  create: (data) => api.post('/orders', data),
  update: (id, data) => api.put(`/orders/${id}`, data),
  delete: (id) => api.delete(`/orders/${id}`),
}

// Order Items API
export const orderItemsAPI = {
  getByOrderId: (orderId) => api.get(`/order-items/order/${orderId}`),
  create: (data) => api.post('/order-items', data),
  update: (id, data) => api.put(`/order-items/${id}`, data),
  delete: (id) => api.delete(`/order-items/${id}`),
}

// Reservations API
export const reservationsAPI = {
  getAll: (params) => api.get('/reservations', { params }),
  getById: (id) => api.get(`/reservations/${id}`),
  create: (data) => api.post('/reservations', data),
  update: (id, data) => api.put(`/reservations/${id}`, data),
  delete: (id) => api.delete(`/reservations/${id}`),
}

// Inventory Logs API
export const inventoryLogsAPI = {
  getAll: (params) => api.get('/inventory-logs', { params }),
  create: (data) => api.post('/inventory-logs', data),
}

export default api
