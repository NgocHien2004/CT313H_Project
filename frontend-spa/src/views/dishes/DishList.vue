<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý món ăn
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <button v-if="authStore.isAdmin" @click="goToCreate" class="btn-primary">
            Thêm món ăn mới
          </button>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white shadow-sm rounded-lg p-6">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div>
            <label class="block text-sm font-medium text-gray-700">Tìm kiếm</label>
            <input
              v-model="filters.search"
              type="text"
              placeholder="Tên món ăn..."
              class="input-field"
              @input="debouncedSearch"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Danh mục</label>
            <select v-model="filters.category_id" class="input-field" @change="loadDishes">
              <option value="">Tất cả danh mục</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Trạng thái</label>
            <select v-model="filters.is_available" class="input-field" @change="loadDishes">
              <option value="">Tất cả</option>
              <option value="true">Có sẵn</option>
              <option value="false">Hết hàng</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Dishes Grid -->
      <div v-else class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        <div
          v-for="dish in dishesWithAvailabilityStatus"
          :key="dish.id"
          class="bg-white overflow-hidden shadow-sm rounded-lg hover:shadow-md transition-shadow"
        >
          <!-- Image -->
          <div class="aspect-w-16 aspect-h-9">
            <img
              :src="getImageUrl(dish)"
              :alt="dish.name"
              class="w-full h-48 object-cover"
              @error="handleImageError"
            />
          </div>

          <!-- Content -->
          <div class="p-4">
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h3 class="text-lg font-medium text-gray-900 mb-1">{{ dish.name }}</h3>
                <p class="text-sm text-gray-500 mb-2 line-clamp-2">
                  {{ dish.description || 'Không có mô tả' }}
                </p>
                <div class="flex items-center justify-between">
                  <span class="text-lg font-bold text-blue-600">
                    {{ formatCurrency(dish.price) }}
                  </span>
                  <span
                    :class="[
                      'px-2 py-1 text-xs font-semibold rounded-full',
                      dish.calculatedAvailability
                        ? 'bg-green-100 text-green-800'
                        : 'bg-red-100 text-red-800',
                    ]"
                  >
                    {{ dish.calculatedAvailability ? 'Có sẵn' : 'Hết hàng' }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Ingredient Status Summary (show only if admin) -->
            <div v-if="authStore.isAdmin && dish.ingredientStatus" class="mt-3 text-xs">
              <div class="flex gap-2 text-gray-600">
                <span v-if="dish.ingredientStatus.sufficient > 0" class="text-green-600">
                  ✓ {{ dish.ingredientStatus.sufficient }} đủ
                </span>
                <span v-if="dish.ingredientStatus.insufficient > 0" class="text-yellow-600">
                  ⚠ {{ dish.ingredientStatus.insufficient }} thiếu
                </span>
                <span v-if="dish.ingredientStatus.outOfStock > 0" class="text-red-600">
                  ✗ {{ dish.ingredientStatus.outOfStock }} hết
                </span>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="mt-4 space-y-2 p-4 pt-0">
            <!-- Recipe Button (All users) -->
            <button
              @click="goToRecipe(dish.id)"
              class="w-full bg-emerald-50 text-emerald-700 text-center py-2 px-3 rounded-md text-sm font-medium hover:bg-emerald-100 transition-colors"
            >
              <svg
                class="w-4 h-4 inline mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                ></path>
              </svg>
              Xem công thức
            </button>

            <!-- Admin Actions -->
            <div v-if="authStore.isAdmin" class="flex space-x-2">
              <button
                @click="goToEdit(dish.id)"
                class="flex-1 bg-blue-50 text-blue-700 text-center py-2 px-3 rounded-md text-sm font-medium hover:bg-blue-100 transition-colors"
              >
                Sửa
              </button>
              <button
                @click="confirmDelete(dish)"
                class="flex-1 bg-red-50 text-red-700 py-2 px-3 rounded-md text-sm font-medium hover:bg-red-100 transition-colors"
              >
                Xóa
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="!loading && dishes.length === 0" class="text-center py-12">
        <svg
          class="mx-auto h-12 w-12 text-gray-400"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
          />
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">Không có món ăn nào</h3>
        <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách tạo món ăn mới.</p>
        <div class="mt-6">
          <button v-if="authStore.isAdmin" @click="goToCreate" class="btn-primary">
            Thêm món ăn mới
          </button>
        </div>
      </div>

      <!-- Pagination -->
      <div
        v-if="totalPages > 1"
        class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6"
      >
        <div class="flex flex-1 justify-between sm:hidden">
          <button
            @click="changePage(currentPage - 1)"
            :disabled="currentPage === 1"
            class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Trước
          </button>
          <button
            @click="changePage(currentPage + 1)"
            :disabled="currentPage === totalPages"
            class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Sau
          </button>
        </div>
        <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700">
              Hiển thị
              <span class="font-medium">{{ (currentPage - 1) * limit + 1 }}</span>
              đến
              <span class="font-medium">{{ Math.min(currentPage * limit, total) }}</span>
              trong tổng số
              <span class="font-medium">{{ total }}</span>
              kết quả
            </p>
          </div>
          <div>
            <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm">
              <button
                @click="changePage(currentPage - 1)"
                :disabled="currentPage === 1"
                class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span class="sr-only">Trang trước</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path
                    fill-rule="evenodd"
                    d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                @click="changePage(page)"
                :class="[
                  page === currentPage
                    ? 'bg-blue-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600'
                    : 'text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0',
                  'relative inline-flex items-center px-4 py-2 text-sm font-semibold focus:z-20',
                ]"
              >
                {{ page }}
              </button>

              <button
                @click="changePage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span class="sr-only">Trang sau</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path
                    fill-rule="evenodd"
                    d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
      v-if="showDeleteModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeDeleteModal"
    >
      <div
        class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white"
        @click.stop
      >
        <div class="mt-3 text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100">
            <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
              ></path>
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa món ăn</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa món ăn "{{ dishToDelete?.name }}"? Hành động này không thể
              hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteDish" :disabled="deleting" class="flex-1 btn-danger">
              {{ deleting ? 'Đang xóa...' : 'Xóa' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import AppLayout from '../../components/layout/AppLayout.vue'
import { dishesAPI, categoriesAPI, inventoryAPI } from '../../services/api'
import axios from 'axios'

// Create axios instance for direct API calls
const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add request interceptor to include auth token
axiosClient.interceptors.request.use(
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

const router = useRouter()
const authStore = useAuthStore()

// Data
const dishes = ref([])
const categories = ref([])
const inventory = ref([])
const dishIngredients = ref({}) // Store ingredients for each dish
const loading = ref(false)
const deleting = ref(false)
const showDeleteModal = ref(false)
const dishToDelete = ref(null)

// Pagination
const currentPage = ref(1)
const limit = ref(12)
const total = ref(0)

// Filters
const filters = ref({
  search: '',
  category_id: '',
  is_available: '',
})

// Computed
const totalPages = computed(() => Math.ceil(total.value / limit.value))

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Calculate availability status for each dish based on ingredients
const dishesWithAvailabilityStatus = computed(() => {
  return dishes.value.map((dish) => {
    const ingredients = dishIngredients.value[dish.id] || []

    // If no ingredients defined, use original availability
    if (ingredients.length === 0) {
      return {
        ...dish,
        calculatedAvailability: dish.is_available,
        ingredientStatus: null,
      }
    }

    // Calculate ingredient status counts
    let sufficient = 0
    let insufficient = 0
    let outOfStock = 0

    ingredients.forEach((ingredient) => {
      const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
      const currentQuantity = inventoryItem?.quantity || 0
      const requiredQuantity = ingredient.quantity_required || 0

      if (currentQuantity >= requiredQuantity) {
        sufficient++
      } else if (currentQuantity > 0) {
        insufficient++
      } else {
        outOfStock++
      }
    })

    // Dish is available only if ALL ingredients are sufficient
    const calculatedAvailability = insufficient === 0 && outOfStock === 0

    return {
      ...dish,
      calculatedAvailability,
      ingredientStatus: {
        sufficient,
        insufficient,
        outOfStock,
      },
    }
  })
})

// Debounced search
let searchTimeout = null
const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 1
    loadDishes()
  }, 500)
}

// Navigation methods
const goToCreate = () => {
  console.log('Navigating to create dish...')
  router.push('/dishes/create')
}

const goToEdit = (dishId) => {
  console.log('Navigating to edit dish:', dishId)
  router.push(`/dishes/${dishId}/edit`)
}

const goToRecipe = (dishId) => {
  console.log('Navigating to recipe detail:', dishId)
  router.push(`/recipes/${dishId}`)
}

// Methods
const loadDishes = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      limit: limit.value,
    }

    if (filters.value.search) params.search = filters.value.search
    if (filters.value.category_id) params.category_id = filters.value.category_id
    if (filters.value.is_available !== '') params.is_available = filters.value.is_available

    console.log('Loading dishes with params:', params)
    const response = await dishesAPI.getAll(params)
    console.log('Dishes response:', response.data)

    dishes.value = response.data.data || []
    total.value = response.data.total || 0

    // Load ingredients for each dish
    await loadDishIngredients()
  } catch (error) {
    console.error('Error loading dishes:', error)
    dishes.value = []
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await categoriesAPI.getAll()
    categories.value = response.data || []
  } catch (error) {
    console.error('Error loading categories:', error)
  }
}

const loadInventory = async () => {
  try {
    const response = await inventoryAPI.getAll({ limit: 100 })
    inventory.value = response.data.data || []
    console.log('Inventory loaded:', inventory.value.length, 'items')
  } catch (error) {
    console.error('Error loading inventory:', error)
  }
}

const loadDishIngredients = async () => {
  try {
    // Load ingredients for all dishes
    const ingredientsPromises = dishes.value.map(async (dish) => {
      try {
        const response = await axiosClient.get(`/dish-ingredients/dish/${dish.id}`)
        return {
          dishId: dish.id,
          ingredients: response.data || [],
        }
      } catch (error) {
        console.error(`Error loading ingredients for dish ${dish.id}:`, error)
        return {
          dishId: dish.id,
          ingredients: [],
        }
      }
    })

    const results = await Promise.all(ingredientsPromises)

    // Create a map of dish ID to ingredients
    const newDishIngredients = {}
    results.forEach((result) => {
      newDishIngredients[result.dishId] = result.ingredients
    })

    dishIngredients.value = newDishIngredients
    console.log('Dish ingredients loaded for', Object.keys(newDishIngredients).length, 'dishes')
  } catch (error) {
    console.error('Error loading dish ingredients:', error)
  }
}

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount)
}

const getImageUrl = (dish) => {
  // Nếu có ảnh upload, dùng relative path (không hardcode domain)
  if (dish.image_url && dish.image_url.startsWith('/uploads/')) {
    return dish.image_url // Chỉ return relative path
  }

  // Nếu là external URL
  if (dish.image_url && dish.image_url.startsWith('http')) {
    return dish.image_url
  }

  // Default placeholder
  return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
}

const handleImageError = (event) => {
  event.target.src =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadDishes()
  }
}

const confirmDelete = (dish) => {
  dishToDelete.value = dish
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  dishToDelete.value = null
}

const deleteDish = async () => {
  if (!dishToDelete.value) return

  deleting.value = true
  try {
    await dishesAPI.delete(dishToDelete.value.id)
    await loadDishes() // Reload the list
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting dish:', error)
    alert('Có lỗi xảy ra khi xóa món ăn')
  } finally {
    deleting.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([loadCategories(), loadInventory()])
  await loadDishes() // Load dishes after categories and inventory are ready
})
</script>
