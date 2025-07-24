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
          v-for="dish in dishes"
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
                      dish.is_available ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800',
                    ]"
                  >
                    {{ dish.is_available ? 'Có sẵn' : 'Hết hàng' }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div v-if="authStore.isAdmin" class="mt-4 flex space-x-2">
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
          stroke="currentColor"
          fill="none"
          viewBox="0 0 48 48"
        >
          <path
            d="M34 40h10v-4a6 6 0 00-10.712-3.714M34 40H14m20 0v-4a9.971 9.971 0 00-.712-3.714M14 40H4v-4a6 6 0 0110.713-3.714M14 40v-4c0-1.313.253-2.566.713-3.714m0 0A10.003 10.003 0 0124 26c4.21 0 7.813 2.602 9.288 6.286M30 14a6 6 0 11-12 0 6 6 0 0112 0zm12 6a4 4 0 11-8 0 4 4 0 018 0zm-28 0a4 4 0 11-8 0 4 4 0 018 0z"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
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
        class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6 rounded-lg"
      >
        <div class="flex-1 flex justify-between sm:hidden">
          <button
            @click="previousPage"
            :disabled="currentPage === 1"
            class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            Trước
          </button>
          <button
            @click="nextPage"
            :disabled="currentPage === totalPages"
            class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            Sau
          </button>
        </div>
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700">
              Hiển thị {{ (currentPage - 1) * limit + 1 }} đến
              {{ Math.min(currentPage * limit, total) }} của {{ total }} kết quả
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
              <button
                @click="previousPage"
                :disabled="currentPage === 1"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
              >
                Trước
              </button>
              <button
                v-for="page in visiblePages"
                :key="page"
                @click="goToPage(page)"
                :class="[
                  'relative inline-flex items-center px-4 py-2 border text-sm font-medium',
                  page === currentPage
                    ? 'z-10 bg-blue-50 border-blue-500 text-blue-600'
                    : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50',
                ]"
              >
                {{ page }}
              </button>
              <button
                @click="nextPage"
                :disabled="currentPage === totalPages"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
              >
                Sau
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
import { dishesAPI, categoriesAPI } from '../../services/api'

const router = useRouter()
const authStore = useAuthStore()

// Data
const dishes = ref([])
const categories = ref([])
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

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount)
}

const getImageUrl = (dish) => {
  // If dish has uploaded image, use it
  if (dish.image_url && dish.image_url.startsWith('/uploads/')) {
    return `http://localhost:3000${dish.image_url}`
  }

  // If external URL fails, use placeholder
  if (dish.image_url && dish.image_url.includes('loremflickr.com')) {
    return '/placeholder-dish.jpg'
  }

  // Default placeholder
  return '/placeholder-dish.jpg'
}

const handleImageError = (event) => {
  console.log('Image error, using placeholder')
  event.target.src = '/placeholder-dish.jpg'
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
    dishes.value = dishes.value.filter((d) => d.id !== dishToDelete.value.id)
    closeDeleteModal()

    // Reload if current page is empty
    if (dishes.value.length === 0 && currentPage.value > 1) {
      currentPage.value--
      loadDishes()
    }
  } catch (error) {
    console.error('Error deleting dish:', error)
    alert('Có lỗi xảy ra khi xóa món ăn')
  } finally {
    deleting.value = false
  }
}

// Pagination methods
const goToPage = (page) => {
  currentPage.value = page
  loadDishes()
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    loadDishes()
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
    loadDishes()
  }
}

onMounted(() => {
  console.log('DishList mounted')
  console.log('Auth store:', authStore.user, authStore.isAdmin)
  loadDishes()
  loadCategories()
})
</script>
