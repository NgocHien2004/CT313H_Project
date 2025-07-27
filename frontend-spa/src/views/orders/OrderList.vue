<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Quản lý đơn hàng</h1>
          <p class="mt-2 text-sm text-gray-700">Danh sách tất cả đơn hàng trong hệ thống.</p>
        </div>
        <div class="mt-4 sm:mt-0">
          <router-link to="/orders/create" class="btn-primary">Tạo đơn hàng mới</router-link>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white p-4 rounded-lg shadow-sm border">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label>
            <select
              v-model="filters.status"
              @change="debouncedSearch"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Tất cả</option>
              <option value="pending">Đang chờ</option>
              <option value="completed">Hoàn thành</option>
              <option value="canceled">Đã hủy</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Số bàn</label>
            <input
              v-model="filters.table_number"
              @input="debouncedSearch"
              type="number"
              placeholder="Nhập số bàn"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày</label>
            <input
              v-model="filters.date"
              @change="debouncedSearch"
              type="date"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
      </div>

      <!-- Orders List -->
      <div class="bg-white shadow-sm rounded-lg border">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-8">
          <div
            class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"
          ></div>
          <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
        </div>

        <!-- Empty state -->
        <div v-else-if="orders.length === 0" class="text-center py-8">
          <p class="text-gray-500">Không có đơn hàng nào.</p>
        </div>

        <!-- Orders table -->
        <div v-else class="overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  #ID
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  SỐ BÀN
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  TỔNG TIỀN
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  TRẠNG THÁI
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  HÀNH ĐỘNG
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="order in orders" :key="order.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">#{{ order.id }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">Bàn {{ order.table_number }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ formatCurrency(order.total_amount) }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <select
                    :value="order.status"
                    @change="updateOrderStatus(order.id, $event.target.value)"
                    :class="{
                      'bg-yellow-100 text-yellow-800 border-yellow-300': order.status === 'pending',
                      'bg-green-100 text-green-800 border-green-300': order.status === 'completed',
                      'bg-red-100 text-red-800 border-red-300': order.status === 'canceled',
                    }"
                    class="text-xs font-semibold rounded-full px-2 py-1 border focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="pending">Đang chờ</option>
                    <option value="completed">Hoàn thành</option>
                    <option value="canceled">Đã hủy</option>
                  </select>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex space-x-2">
                    <button
                      @click="viewOrderDetails(order.id)"
                      class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-blue-700 bg-blue-100 hover:bg-blue-200"
                    >
                      Chi tiết
                    </button>
                    <button
                      v-if="authStore.isAdmin"
                      @click="confirmDelete(order)"
                      class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-red-700 bg-red-100 hover:bg-red-200"
                    >
                      Xóa
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="bg-white px-4 py-3 border-t border-gray-200 sm:px-6">
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <p class="text-sm text-gray-700">
                Hiển thị
                <span class="font-medium">{{ (currentPage - 1) * limit + 1 }}</span>
                đến
                <span class="font-medium">{{ Math.min(currentPage * limit, total) }}</span>
                trong
                <span class="font-medium">{{ total }}</span>
                kết quả
              </p>
            </div>
            <div class="flex items-center space-x-2">
              <button
                @click="previousPage"
                :disabled="currentPage === 1"
                class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Trước
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                @click="goToPage(page)"
                :class="[
                  'px-3 py-2 text-sm font-medium rounded-md',
                  page === currentPage
                    ? 'bg-blue-500 text-white'
                    : 'text-gray-500 bg-white border border-gray-300 hover:bg-gray-50',
                ]"
              >
                {{ page }}
              </button>

              <button
                @click="nextPage"
                :disabled="currentPage === totalPages"
                class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Sau
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Modal -->
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xác nhận xóa đơn hàng</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa đơn hàng #{{ orderToDelete?.id }}? Hành động này không thể
              hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteOrder" :disabled="deleting" class="flex-1 btn-danger">
              {{ deleting ? 'Đang xóa...' : 'Xóa' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Order Details Modal -->
    <div
      v-if="showDetailsModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeDetailsModal"
    >
      <div
        class="relative top-10 mx-auto p-5 border max-w-6xl shadow-lg rounded-md bg-white"
        @click.stop
      >
        <div class="mt-3">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              Chi tiết đơn hàng #{{ selectedOrder?.id }}
            </h3>
            <button @click="closeDetailsModal" class="text-gray-400 hover:text-gray-600">
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                ></path>
              </svg>
            </button>
          </div>

          <!-- Loading state for details -->
          <div v-if="loadingDetails" class="text-center py-8">
            <div
              class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"
            ></div>
            <p class="mt-2 text-sm text-gray-500">Đang tải chi tiết...</p>
          </div>

          <!-- Order Details Content -->
          <div v-else-if="selectedOrder" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Left Column: Order Info and Current Items -->
            <div class="space-y-6">
              <div class="bg-gray-50 p-4 rounded-lg">
                <h4 class="text-md font-medium text-gray-900 mb-3">Thông tin đơn hàng</h4>
                <div class="space-y-2 text-sm">
                  <div class="flex justify-between">
                    <span class="text-gray-600">Số bàn:</span>
                    <span class="font-medium">Bàn {{ selectedOrder.table_number }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Trạng thái:</span>
                    <span
                      :class="{
                        'text-yellow-600': selectedOrder.status === 'pending',
                        'text-green-600': selectedOrder.status === 'completed',
                        'text-red-600': selectedOrder.status === 'canceled',
                      }"
                      class="font-medium"
                    >
                      {{ getStatusText(selectedOrder.status) }}
                    </span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Tổng tiền:</span>
                    <span class="font-medium text-lg text-blue-600">{{
                      formatCurrency(selectedOrder.total_amount)
                    }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Thời gian:</span>
                    <span class="font-medium">{{ formatDate(selectedOrder.order_time) }}</span>
                  </div>
                </div>
              </div>

              <!-- Order Items -->
              <div class="bg-white border border-gray-200 rounded-lg">
                <div class="px-4 py-3 border-b border-gray-200">
                  <h4 class="text-md font-medium text-gray-900">
                    Món ăn trong đơn ({{ selectedOrder.items?.length || 0 }} món)
                  </h4>
                </div>
                <div
                  v-if="selectedOrder.items && selectedOrder.items.length > 0"
                  class="divide-y divide-gray-200"
                >
                  <div v-for="item in selectedOrder.items" :key="item.id" class="p-4">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-3">
                        <div class="flex-shrink-0">
                          <img
                            :src="getItemImageUrl(item)"
                            :alt="item.dish_name"
                            @error="handleImageError"
                            class="h-12 w-12 object-cover rounded"
                          />
                        </div>
                        <div class="flex-1 min-w-0">
                          <p class="text-sm font-medium text-gray-900">{{ item.dish_name }}</p>
                          <p class="text-xs text-gray-500">
                            {{ formatCurrency(item.price) }} / món
                          </p>
                        </div>
                      </div>
                      <div class="flex items-center space-x-2">
                        <button
                          @click="updateOrderItemQuantity(item.id, Math.max(1, item.quantity - 1))"
                          :disabled="updatingItem === item.id || item.quantity <= 1"
                          class="w-6 h-6 flex items-center justify-center bg-gray-100 text-gray-600 rounded hover:bg-gray-200 disabled:opacity-50"
                        >
                          -
                        </button>
                        <span class="w-8 text-center font-medium">{{ item.quantity }}</span>
                        <button
                          @click="updateOrderItemQuantity(item.id, item.quantity + 1)"
                          :disabled="updatingItem === item.id"
                          class="w-6 h-6 flex items-center justify-center bg-gray-100 text-gray-600 rounded hover:bg-gray-200 disabled:opacity-50"
                        >
                          +
                        </button>
                      </div>
                      <div class="text-right">
                        <p class="text-sm font-medium text-gray-900">
                          {{ formatCurrency(item.price * item.quantity) }}
                        </p>
                      </div>
                      <button
                        @click="confirmDeleteOrderItem(item)"
                        class="ml-2 text-red-600 hover:text-red-800"
                      >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                          ></path>
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>

                <div v-else class="text-center py-4 text-gray-500">
                  Đơn hàng chưa có món ăn nào.
                </div>
              </div>
            </div>

            <!-- Right Column: Add Dishes -->
            <div class="space-y-6">
              <div class="bg-blue-50 p-4 rounded-lg">
                <h4 class="text-md font-medium text-gray-900 mb-3">Thêm món ăn vào đơn hàng</h4>

                <!-- Search and filter dishes -->
                <div class="space-y-3 mb-4">
                  <input
                    v-model="dishSearchInModal"
                    @input="debouncedDishSearch"
                    type="text"
                    placeholder="Tìm kiếm món ăn..."
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <select
                    v-model="selectedCategoryInModal"
                    @change="loadDishesInModal"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Tất cả danh mục</option>
                    <option v-for="category in categories" :key="category.id" :value="category.id">
                      {{ category.name }}
                    </option>
                  </select>
                </div>

                <!-- Available dishes list -->
                <div v-if="loadingDishes" class="text-center py-4">
                  <div
                    class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"
                  ></div>
                  <p class="text-sm text-gray-500 mt-2">Đang tải món ăn...</p>
                </div>

                <div v-else class="max-h-96 overflow-y-auto space-y-2">
                  <div
                    v-for="dish in availableDishes"
                    :key="dish.id"
                    class="flex items-center justify-between p-3 bg-white border border-gray-200 rounded-lg hover:bg-gray-50"
                  >
                    <div class="flex items-center space-x-3">
                      <!-- Dish Image -->
                      <div class="flex-shrink-0">
                        <img
                          :src="getDishImageUrl(dish)"
                          :alt="dish.name"
                          @error="handleImageError"
                          class="h-12 w-12 object-cover rounded"
                        />
                      </div>

                      <!-- Dish Info -->
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900">{{ dish.name }}</p>
                        <p class="text-xs text-blue-600">{{ formatCurrency(dish.price) }}</p>
                      </div>
                    </div>

                    <!-- Add Button -->
                    <button
                      @click="addDishToOrder(dish)"
                      :disabled="!dish.is_available || addingDish === dish.id"
                      class="px-3 py-1 text-xs font-medium rounded text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ addingDish === dish.id ? 'Đang thêm...' : 'Thêm' }}
                    </button>
                  </div>

                  <div v-if="availableDishes.length === 0" class="text-center py-4 text-gray-500">
                    Không tìm thấy món ăn nào.
                  </div>
                </div>

                <!-- Nút Xong - PHẦN DUY NHẤT THÊM MỚI -->
                <div class="mt-6 pt-4 border-t border-blue-200">
                  <button
                    @click="closeDetailsModal"
                    class="w-full bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors font-medium"
                  >
                    ✓ Xong
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Order Item Modal -->
    <div
      v-if="showDeleteItemModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeDeleteItemModal"
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xác nhận xóa món</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa món "{{ itemToDelete?.dish_name }}" khỏi đơn hàng? Hành động
              này không thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteItemModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteOrderItem" :disabled="deletingItem" class="flex-1 btn-danger">
              {{ deletingItem ? 'Đang xóa...' : 'Xóa' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ordersAPI, orderItemsAPI, dishesAPI, categoriesAPI } from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import AppLayout from '@/components/layout/AppLayout.vue'

const authStore = useAuthStore()

// Reactive state
const orders = ref([])
const loading = ref(false)
const total = ref(0)
const currentPage = ref(1)
const limit = ref(10)
const filters = ref({
  status: '',
  table_number: '',
  date: '',
})

// Delete modal state
const showDeleteModal = ref(false)
const orderToDelete = ref(null)
const deleting = ref(false)

// Details modal state
const showDetailsModal = ref(false)
const selectedOrder = ref(null)
const loadingDetails = ref(false)

// Order item editing state
const updatingItem = ref(null)
const showDeleteItemModal = ref(false)
const itemToDelete = ref(null)
const deletingItem = ref(false)

// Add dish to order state
const availableDishes = ref([])
const categories = ref([])
const loadingDishes = ref(false)
const addingDish = ref(null)
const dishSearchInModal = ref('')
const selectedCategoryInModal = ref('')

// Store dishes data to get image URLs
const dishesDataMap = ref({})

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
    loadOrders()
  }, 500)
}

let dishSearchTimeout = null
const debouncedDishSearch = () => {
  clearTimeout(dishSearchTimeout)
  dishSearchTimeout = setTimeout(() => {
    loadDishesInModal()
  }, 500)
}

// Methods
const loadOrders = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      limit: limit.value,
    }

    if (filters.value.status) params.status = filters.value.status
    if (filters.value.table_number) params.table_number = filters.value.table_number
    if (filters.value.date) params.date = filters.value.date

    const response = await ordersAPI.getAll(params)
    orders.value = response.data.data || []
    total.value = response.data.total || orders.value.length
  } catch (error) {
    console.error('Error loading orders:', error)
    orders.value = []
  } finally {
    loading.value = false
  }
}

// View order details
const viewOrderDetails = async (orderId) => {
  console.log('Frontend: Viewing order details for ID:', orderId)
  loadingDetails.value = true
  showDetailsModal.value = true

  try {
    console.log('Frontend: Making API call to get order details')
    const response = await ordersAPI.getById(orderId)
    console.log('Frontend: API response:', response)
    console.log('Frontend: Order data:', response.data)

    selectedOrder.value = response.data.data
    console.log('Frontend: Selected order set to:', selectedOrder.value)

    // Load all dishes to get image URLs and other details
    await loadAllDishes()

    // Load dishes and categories for adding new dishes
    await loadDishesInModal()
    await loadCategories()
  } catch (error) {
    console.error('Frontend: Error loading order details:', error)
    console.error('Frontend: Error response:', error.response)
    alert(
      'Có lỗi xảy ra khi tải chi tiết đơn hàng: ' +
        (error.response?.data?.message || error.message),
    )
    closeDetailsModal()
  } finally {
    loadingDetails.value = false
  }
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selectedOrder.value = null
  dishSearchInModal.value = ''
  selectedCategoryInModal.value = ''
  availableDishes.value = []
}

// Load all dishes to create a map for getting dish details
const loadAllDishes = async () => {
  try {
    const response = await dishesAPI.getAll({ limit: 1000 })
    const dishes = response.data.data || []

    // Create a map for quick lookup
    dishesDataMap.value = {}
    dishes.forEach((dish) => {
      dishesDataMap.value[dish.id] = dish
    })
  } catch (error) {
    console.error('Error loading all dishes:', error)
  }
}

// Load categories for filtering
const loadCategories = async () => {
  try {
    const response = await categoriesAPI.getAll()
    categories.value = response.data || []
  } catch (error) {
    console.error('Error loading categories:', error)
  }
}

// Load dishes for adding to order
const loadDishesInModal = async () => {
  loadingDishes.value = true
  try {
    const params = {
      limit: 50,
      is_available: true,
    }

    if (dishSearchInModal.value) params.search = dishSearchInModal.value
    if (selectedCategoryInModal.value) params.category_id = selectedCategoryInModal.value

    const response = await dishesAPI.getAll(params)
    availableDishes.value = response.data.data || []
  } catch (error) {
    console.error('Error loading dishes:', error)
    availableDishes.value = []
  } finally {
    loadingDishes.value = false
  }
}

// Add dish to order
const addDishToOrder = async (dish) => {
  if (!selectedOrder.value || !dish.is_available) return

  addingDish.value = dish.id
  try {
    // Check if dish already exists in order
    const existingItem = selectedOrder.value.items?.find(
      (item) => item.dish_id === parseInt(dish.id),
    )

    if (existingItem) {
      // If dish already exists, update quantity instead of creating new item
      const newQuantity = existingItem.quantity + 1
      await updateOrderItemQuantity(existingItem.id, newQuantity)
      console.log('Updated existing item quantity')
    } else {
      // If dish doesn't exist, create new order item
      const orderItemData = {
        order_id: parseInt(selectedOrder.value.id),
        dish_id: parseInt(dish.id),
        quantity: 1,
        price: parseFloat(dish.price),
      }

      console.log('Adding new dish to order:', orderItemData)
      const response = await orderItemsAPI.create(orderItemData)
      console.log('Order item created:', response.data)

      // Add the new item to the selected order's items
      // Handle different response structures
      const createdItem = response.data.data || response.data
      const newItem = {
        id: createdItem.id,
        dish_id: parseInt(dish.id),
        dish_name: dish.name,
        quantity: 1,
        price: parseFloat(dish.price),
      }

      if (!selectedOrder.value.items) {
        selectedOrder.value.items = []
      }
      selectedOrder.value.items.push(newItem)

      // Update the total amount
      selectedOrder.value.total_amount = selectedOrder.value.items.reduce(
        (sum, item) => sum + parseFloat(item.quantity) * parseFloat(item.price),
        0,
      )

      // Update the order in the main orders list
      const orderInList = orders.value.find((o) => o.id === selectedOrder.value.id)
      if (orderInList) {
        orderInList.total_amount = selectedOrder.value.total_amount
      }

      console.log('Successfully added new dish to order')
    }
  } catch (error) {
    console.error('Error adding dish to order:', error)
    console.error('Error response:', error.response)

    let errorMessage = 'Có lỗi xảy ra khi thêm món ăn vào đơn hàng'
    if (error.response?.data?.error) {
      errorMessage = error.response.data.error
    } else if (error.response?.data?.message) {
      errorMessage = error.response.data.message
    }

    alert(errorMessage)
  } finally {
    addingDish.value = null
  }
}

// Update order item quantity
const updateOrderItemQuantity = async (orderItemId, newQuantity) => {
  try {
    updatingItem.value = orderItemId

    // If quantity is 0 or less, delete the item instead
    if (newQuantity <= 0) {
      const itemToRemove = selectedOrder.value.items.find((item) => item.id === orderItemId)
      if (itemToRemove) {
        await orderItemsAPI.delete(orderItemId)

        // Remove item from local state
        selectedOrder.value.items = selectedOrder.value.items.filter(
          (item) => item.id !== orderItemId,
        )

        // Check if order has no items left, then delete the order
        if (selectedOrder.value.items.length === 0) {
          await deleteEmptyOrder()
          return
        }

        // Recalculate order total
        selectedOrder.value.total_amount = selectedOrder.value.items.reduce(
          (sum, item) => sum + parseFloat(item.quantity) * parseFloat(item.price),
          0,
        )

        // Update the order in the main orders list
        const orderInList = orders.value.find((o) => o.id === selectedOrder.value.id)
        if (orderInList) {
          orderInList.total_amount = selectedOrder.value.total_amount
        }

        console.log('Item automatically removed due to quantity 0')
      }
      return
    }

    // Call API to update order item quantity
    await orderItemsAPI.update(orderItemId, { quantity: parseInt(newQuantity) })

    // Update local state
    const item = selectedOrder.value.items.find((item) => item.id === orderItemId)
    if (item) {
      item.quantity = parseInt(newQuantity)
      // Recalculate order total
      selectedOrder.value.total_amount = selectedOrder.value.items.reduce(
        (sum, item) => sum + parseFloat(item.quantity) * parseFloat(item.price),
        0,
      )
    }

    // Also update the order in the main orders list
    const orderInList = orders.value.find((o) => o.id === selectedOrder.value.id)
    if (orderInList) {
      orderInList.total_amount = selectedOrder.value.total_amount
    }
  } catch (error) {
    console.error('Error updating order item quantity:', error)
    alert('Có lỗi xảy ra khi cập nhật số lượng')
  } finally {
    updatingItem.value = null
  }
}

// Delete confirmation methods
const confirmDelete = (order) => {
  orderToDelete.value = order
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  orderToDelete.value = null
}

const deleteOrder = async () => {
  if (!orderToDelete.value) return

  deleting.value = true
  try {
    await ordersAPI.delete(orderToDelete.value.id)
    orders.value = orders.value.filter((o) => o.id !== orderToDelete.value.id)
    closeDeleteModal()

    // Reload if current page is empty
    if (orders.value.length === 0 && currentPage.value > 1) {
      currentPage.value--
      await loadOrders()
    }
  } catch (error) {
    console.error('Error deleting order:', error)
    alert('Có lỗi xảy ra khi xóa đơn hàng')
  } finally {
    deleting.value = false
  }
}

// Order item delete methods
const confirmDeleteOrderItem = (item) => {
  itemToDelete.value = item
  showDeleteItemModal.value = true
}

const closeDeleteItemModal = () => {
  showDeleteItemModal.value = false
  itemToDelete.value = null
}

const deleteOrderItem = async () => {
  if (!itemToDelete.value) return

  deletingItem.value = true
  try {
    console.log('Deleting order item:', itemToDelete.value.id)
    await orderItemsAPI.delete(itemToDelete.value.id)

    // Remove item from local state
    selectedOrder.value.items = selectedOrder.value.items.filter(
      (item) => item.id !== itemToDelete.value.id,
    )

    // Recalculate total
    selectedOrder.value.total_amount = selectedOrder.value.items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0,
    )

    // If no items left, delete the order
    if (selectedOrder.value.items.length === 0) {
      await deleteEmptyOrder()
      return
    }

    // Update order in main list
    const orderInList = orders.value.find((o) => o.id === selectedOrder.value.id)
    if (orderInList) {
      orderInList.total_amount = selectedOrder.value.total_amount
    }

    closeDeleteItemModal()
  } catch (error) {
    console.error('Error deleting order item:', error)
    alert('Có lỗi xảy ra khi xóa món ăn')
  } finally {
    deletingItem.value = false
  }
}

// Function to delete empty order
const deleteEmptyOrder = async () => {
  if (!selectedOrder.value) return

  try {
    console.log('Deleting empty order:', selectedOrder.value.id)
    await ordersAPI.delete(selectedOrder.value.id)

    // Remove order from main orders list
    orders.value = orders.value.filter((o) => o.id !== selectedOrder.value.id)

    // Close modal
    closeDetailsModal()

    // Show notification
    alert('Đơn hàng đã được xóa tự động vì không còn món ăn nào')

    // Reload orders if current page is empty
    if (orders.value.length === 0 && currentPage.value > 1) {
      currentPage.value--
      await loadOrders()
    }

    console.log('Empty order deleted successfully')
  } catch (error) {
    console.error('Error deleting empty order:', error)
    alert('Có lỗi xảy ra khi xóa đơn hàng rỗng')
  }
}

// Update order status
const updateOrderStatus = async (orderId, newStatus) => {
  try {
    await ordersAPI.update(orderId, { status: newStatus })

    // Update local state
    const order = orders.value.find((o) => o.id === orderId)
    if (order) {
      order.status = newStatus
    }

    // Also update selected order if it's the same
    if (selectedOrder.value && selectedOrder.value.id === orderId) {
      selectedOrder.value.status = newStatus
    }

    console.log('Order status updated successfully')
  } catch (error) {
    console.error('Error updating order status:', error)
    alert('Có lỗi xảy ra khi cập nhật trạng thái đơn hàng')
  }
}

// Pagination methods
const goToPage = (page) => {
  currentPage.value = page
  loadOrders()
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    loadOrders()
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
    loadOrders()
  }
}

// Utility functions
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount)
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString('vi-VN')
}

const getStatusText = (status) => {
  const statusMap = {
    pending: 'Đang chờ',
    completed: 'Hoàn thành',
    canceled: 'Đã hủy',
  }
  return statusMap[status] || status
}

// Image URL functions
const getItemImageUrl = (item) => {
  // First try to get dish details from the map
  const dishData = dishesDataMap.value[item.dish_id]
  if (dishData && dishData.image_url) {
    if (dishData.image_url.startsWith('/uploads/')) {
      return `http://localhost:3000${dishData.image_url}`
    }
    if (dishData.image_url.startsWith('http')) {
      return dishData.image_url
    }
  }

  // Fallback to placeholder
  return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
}

const getDishImageUrl = (dish) => {
  if (dish.image_url && dish.image_url.startsWith('/uploads/')) {
    return `http://localhost:3000${dish.image_url}`
  }

  if (dish.image_url && dish.image_url.startsWith('http')) {
    return dish.image_url
  }

  return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
}

const handleImageError = (event) => {
  event.target.src =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'
}

// Initialize
onMounted(() => {
  loadOrders()
})
</script>
