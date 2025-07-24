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
                class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-primary-500"
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
                class="border border-gray-200 rounded-lg p-4 hover:border-primary-300 transition-colors cursor-pointer"
                :class="{ 'border-primary-500 bg-primary-50': isInCart(dish.id) }"
                @click="addToCart(dish)"
              >
                <div class="flex items-center space-x-3">
                  <img
                    :src="dish.image_url || '/placeholder-dish.jpg'"
                    :alt="dish.name"
                    class="w-12 h-12 object-cover rounded-lg"
                    @error="handleImageError"
                  />
                  <div class="flex-1">
                    <h3 class="font-medium text-gray-900">{{ dish.name }}</h3>
                    <p class="text-sm text-gray-500">{{ formatCurrency(dish.price) }}</p>
                    <span
                      v-if="!dish.is_available"
                      class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800"
                    >
                      Hết hàng
                    </span>
                  </div>
                  <div v-if="isInCart(dish.id)" class="text-primary-600">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path
                        fill-rule="evenodd"
                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        clip-rule="evenodd"
                      ></path>
                    </svg>
                  </div>
                </div>
              </div>
            </div>

            <!-- Empty State -->
            <div v-else class="text-center py-8">
              <p class="text-sm text-gray-500">Không tìm thấy món ăn nào</p>
            </div>
          </div>
        </div>

        <!-- Order Summary -->
        <div class="lg:col-span-1">
          <div class="bg-white shadow-sm rounded-lg p-6 sticky top-6">
            <h2 class="text-lg font-medium text-gray-900 mb-4">Thông tin đơn hàng</h2>

            <!-- Order Info -->
            <div class="space-y-4 mb-4">
              <div>
                <label for="table_number" class="block text-sm font-medium text-gray-700">
                  Số bàn <span class="text-red-500">*</span>
                </label>
                <input
                  id="table_number"
                  v-model.number="form.table_number"
                  type="number"
                  min="1"
                  required
                  class="input-field"
                  placeholder="Nhập số bàn"
                />
              </div>
            </div>

            <!-- Cart Items -->
            <div class="space-y-3 mb-4">
              <h3 class="text-sm font-medium text-gray-900">Món đã chọn</h3>

              <div v-if="cartItems.length === 0" class="text-center py-4">
                <p class="text-sm text-gray-500">Chưa có món nào được chọn</p>
              </div>

              <div v-else class="space-y-2 max-h-40 overflow-y-auto">
                <div
                  v-for="item in cartItems"
                  :key="item.dish_id"
                  class="flex items-center justify-between p-2 bg-gray-50 rounded-lg"
                >
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-900">{{ item.name }}</p>
                    <p class="text-xs text-gray-500">{{ formatCurrency(item.price) }}</p>
                  </div>
                  <div class="flex items-center space-x-2">
                    <button
                      @click="decreaseQuantity(item.dish_id)"
                      class="w-6 h-6 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
                    >
                      <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                        <path
                          fill-rule="evenodd"
                          d="M3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z"
                          clip-rule="evenodd"
                        ></path>
                      </svg>
                    </button>
                    <span class="text-sm font-medium w-8 text-center">{{ item.quantity }}</span>
                    <button
                      @click="increaseQuantity(item.dish_id)"
                      class="w-6 h-6 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
                    >
                      <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                        <path
                          fill-rule="evenodd"
                          d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
                          clip-rule="evenodd"
                        ></path>
                      </svg>
                    </button>
                    <button
                      @click="removeFromCart(item.dish_id)"
                      class="w-6 h-6 rounded-full bg-red-100 hover:bg-red-200 text-red-600 flex items-center justify-center ml-2"
                    >
                      <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                        <path
                          fill-rule="evenodd"
                          d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                          clip-rule="evenodd"
                        ></path>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Total -->
            <div class="border-t pt-4 mb-4">
              <div class="flex justify-between text-lg font-medium">
                <span>Tổng cộng:</span>
                <span>{{ formatCurrency(totalAmount) }}</span>
              </div>
            </div>

            <!-- Error Message -->
            <div v-if="error" class="rounded-md bg-red-50 p-4 mb-4">
              <div class="text-sm text-red-700">
                {{ error }}
              </div>
            </div>

            <!-- Actions -->
            <div class="space-y-3">
              <button
                @click="handleSubmit"
                :disabled="loading || cartItems.length === 0 || !form.table_number"
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

const handleImageError = (event) => {
  event.target.src = '/placeholder-dish.jpg'
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
