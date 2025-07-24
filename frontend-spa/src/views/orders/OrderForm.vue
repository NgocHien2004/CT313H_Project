<template>
  <AppLayout>
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-6">
        <div class="flex items-center space-x-4">
          <router-link to="/orders" class="text-gray-400 hover:text-gray-600">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              ></path>
            </svg>
          </router-link>
          <h1 class="text-2xl font-bold text-gray-900">Tạo đơn hàng mới</h1>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Dishes Selection -->
        <div class="lg:col-span-2">
          <div class="bg-white shadow-sm rounded-lg p-6">
            <h2 class="text-lg font-medium text-gray-900 mb-4">Chọn món ăn</h2>

            <!-- Search and Filter -->
            <div class="mb-4 grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <input
                  v-model="dishSearch"
                  type="text"
                  placeholder="Tìm kiếm món ăn..."
                  class="input-field"
                  @input="debouncedDishSearch"
                />
              </div>
              <div>
                <select v-model="selectedCategory" class="input-field" @change="loadDishes">
                  <option value="">Tất cả danh mục</option>
                  <option v-for="category in categories" :key="category.id" :value="category.id">
                    {{ category.name }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Loading -->
            <div v-if="dishesLoading" class="text-center py-8">
              <div
                class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"
              ></div>
              <p class="mt-2 text-sm text-gray-500">Đang tải món ăn...</p>
            </div>

            <!-- Dishes Grid -->
            <div
              v-else-if="dishes && dishes.length > 0"
              class="grid grid-cols-1 sm:grid-cols-2 gap-4 max-h-96 overflow-y-auto"
            >
              <div
                v-for="dish in dishes"
                :key="dish.id"
                class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
              >
                <!-- Dish Image với loading state -->
                <div class="aspect-square mb-3 bg-gray-100 rounded-lg overflow-hidden relative">
                  <div
                    v-if="imageLoadingStates[dish.id]"
                    class="absolute inset-0 flex items-center justify-center"
                  >
                    <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
                  </div>
                  <img
                    :src="getImageUrl(dish)"
                    :alt="dish.name"
                    class="w-full h-full object-cover transition-opacity duration-200"
                    :class="{ 'opacity-0': imageLoadingStates[dish.id] }"
                    @load="handleImageLoad(dish.id)"
                    @error="handleImageError($event, dish.id)"
                  />
                </div>

                <div class="flex-1">
                  <h3 class="font-medium text-gray-900 mb-1">{{ dish.name }}</h3>
                  <p class="text-sm text-gray-500 mb-2 line-clamp-2">
                    {{ dish.description || 'Không có mô tả' }}
                  </p>
                  <div class="flex items-center justify-between">
                    <span class="font-bold text-blue-600">
                      {{ formatCurrency(dish.price) }}
                    </span>
                    <button
                      @click="addToCart(dish)"
                      :disabled="!dish.is_available"
                      :class="[
                        'px-3 py-1 rounded text-sm font-medium transition-colors',
                        dish.is_available
                          ? isInCart(dish.id)
                            ? 'bg-green-100 text-green-800'
                            : 'bg-blue-600 text-white hover:bg-blue-700'
                          : 'bg-gray-300 text-gray-500 cursor-not-allowed',
                      ]"
                    >
                      {{ !dish.is_available ? 'Hết hàng' : isInCart(dish.id) ? 'Đã thêm' : 'Thêm' }}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Empty State -->
            <div v-else class="text-center py-8">
              <p class="text-gray-500">Không có món ăn nào.</p>
            </div>
          </div>
        </div>

        <!-- Order Summary -->
        <div class="lg:col-span-1">
          <div class="bg-white shadow-sm rounded-lg p-6 sticky top-6">
            <h2 class="text-lg font-medium text-gray-900 mb-4">Thông tin đơn hàng</h2>

            <!-- Table Number -->
            <div class="mb-4">
              <label for="table_number" class="block text-sm font-medium text-gray-700 mb-1">
                Số bàn *
              </label>
              <input
                id="table_number"
                v-model="form.table_number"
                type="number"
                min="1"
                required
                class="input-field"
                placeholder="Nhập số bàn"
              />
            </div>

            <!-- Cart Items -->
            <div class="mb-4">
              <h3 class="text-sm font-medium text-gray-700 mb-2">
                Món đã chọn ({{ cartItems.length }})
              </h3>

              <div v-if="cartItems.length === 0" class="text-center py-4 text-gray-500 text-sm">
                Chưa có món nào được chọn
              </div>

              <div v-else class="space-y-2 max-h-64 overflow-y-auto">
                <div
                  v-for="item in cartItems"
                  :key="item.dish_id"
                  class="flex items-center justify-between p-2 bg-gray-50 rounded"
                >
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-900">{{ item.name }}</p>
                    <p class="text-xs text-gray-500">{{ formatCurrency(item.price) }}</p>
                  </div>
                  <div class="flex items-center space-x-2">
                    <button
                      @click="decreaseQuantity(item.dish_id)"
                      class="w-6 h-6 flex items-center justify-center bg-gray-200 text-gray-600 rounded hover:bg-gray-300"
                    >
                      -
                    </button>
                    <span class="text-sm font-medium w-8 text-center">{{ item.quantity }}</span>
                    <button
                      @click="increaseQuantity(item.dish_id)"
                      class="w-6 h-6 flex items-center justify-center bg-gray-200 text-gray-600 rounded hover:bg-gray-300"
                    >
                      +
                    </button>
                    <button
                      @click="removeFromCart(item.dish_id)"
                      class="w-6 h-6 flex items-center justify-center bg-red-100 text-red-600 rounded hover:bg-red-200 ml-2"
                    >
                      ×
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Total -->
            <div class="mb-4 p-3 bg-gray-50 rounded">
              <div class="flex justify-between items-center">
                <span class="font-medium text-gray-900">Tổng tiền:</span>
                <span class="text-lg font-bold text-blue-600">
                  {{ formatCurrency(totalAmount) }}
                </span>
              </div>
            </div>

            <!-- Error Message -->
            <div v-if="error" class="mb-4 p-3 bg-red-50 rounded">
              <p class="text-sm text-red-700">{{ error }}</p>
            </div>

            <!-- Actions -->
            <div class="space-y-2">
              <button
                @click="handleSubmit"
                :disabled="loading || cartItems.length === 0"
                class="w-full btn-primary"
              >
                {{ loading ? 'Đang tạo...' : 'Tạo đơn hàng' }}
              </button>

              <router-link to="/orders" class="w-full btn-secondary text-center block">
                Hủy
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import AppLayout from '../../components/layout/AppLayout.vue'
import { ordersAPI, dishesAPI, categoriesAPI } from '../../services/api'

const router = useRouter()
const authStore = useAuthStore()

// Initialize all reactive data
const dishes = ref([])
const categories = ref([])
const cartItems = ref([])
const dishesLoading = ref(false)
const loading = ref(false)
const error = ref('')
const dishSearch = ref('')
const selectedCategory = ref('')
const imageLoadingStates = ref({}) // Track image loading states

const form = reactive({
  table_number: '',
  user_id: authStore.user?.id,
})

// Computed
const totalAmount = computed(() => {
  return cartItems.value.reduce((total, item) => {
    return total + item.price * item.quantity
  }, 0)
})

// Debounced search
let searchTimeout = null
const debouncedDishSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    loadDishes()
  }, 500)
}

// Image handling methods
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

const handleImageLoad = (dishId) => {
  imageLoadingStates.value[dishId] = false
}

const handleImageError = (event, dishId) => {
  console.log('Image error for dish:', dishId)
  event.target.src = '/placeholder-dish.jpg'
  imageLoadingStates.value[dishId] = false
}

// Methods
const loadDishes = async () => {
  dishesLoading.value = true
  try {
    const params = {
      limit: 50,
      is_available: true,
    }

    if (dishSearch.value) params.search = dishSearch.value
    if (selectedCategory.value) params.category_id = selectedCategory.value

    const response = await dishesAPI.getAll(params)
    dishes.value = response.data.data || []

    // Initialize image loading states
    dishes.value.forEach((dish) => {
      imageLoadingStates.value[dish.id] = true
    })
  } catch (error) {
    console.error('Error loading dishes:', error)
    dishes.value = []
  } finally {
    dishesLoading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await categoriesAPI.getAll()
    categories.value = response.data || []
  } catch (error) {
    console.error('Error loading categories:', error)
    categories.value = []
  }
}

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount)
}

const isInCart = (dishId) => {
  return cartItems.value.some((item) => item.dish_id === dishId)
}

const addToCart = (dish) => {
  if (!dish.is_available) return

  const existingItem = cartItems.value.find((item) => item.dish_id === dish.id)

  if (existingItem) {
    existingItem.quantity++
  } else {
    cartItems.value.push({
      dish_id: dish.id,
      name: dish.name,
      price: dish.price,
      quantity: 1,
    })
  }
}

const removeFromCart = (dishId) => {
  const index = cartItems.value.findIndex((item) => item.dish_id === dishId)
  if (index !== -1) {
    cartItems.value.splice(index, 1)
  }
}

const increaseQuantity = (dishId) => {
  const item = cartItems.value.find((item) => item.dish_id === dishId)
  if (item) {
    item.quantity++
  }
}

const decreaseQuantity = (dishId) => {
  const item = cartItems.value.find((item) => item.dish_id === dishId)
  if (item) {
    if (item.quantity > 1) {
      item.quantity--
    } else {
      removeFromCart(dishId)
    }
  }
}

const handleSubmit = async () => {
  error.value = ''

  if (!form.table_number) {
    error.value = 'Vui lòng nhập số bàn'
    return
  }

  if (cartItems.value.length === 0) {
    error.value = 'Vui lòng chọn ít nhất một món ăn'
    return
  }

  loading.value = true

  try {
    const orderData = {
      user_id: form.user_id,
      table_number: parseInt(form.table_number),
      items: cartItems.value.map((item) => ({
        dish_id: item.dish_id,
        quantity: item.quantity,
      })),
    }

    await ordersAPI.create(orderData)
    router.push('/orders')
  } catch (err) {
    console.error('Error creating order:', err)
    error.value = err.response?.data?.error || 'Có lỗi xảy ra khi tạo đơn hàng'
  } finally {
    loading.value = false
  }
}

// Initialize data on mount
onMounted(() => {
  console.log('OrderForm mounted, loading data...')
  loadDishes()
  loadCategories()
})
</script>
