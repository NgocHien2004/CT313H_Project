<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý đơn hàng
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <router-link to="/orders/create" class="btn-primary"> Tạo đơn hàng mới </router-link>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white shadow-sm rounded-lg p-6">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div>
            <label class="block text-sm font-medium text-gray-700">Trạng thái</label>
            <select v-model="filters.status" class="input-field" @change="debouncedSearch">
              <option value="">Tất cả</option>
              <option value="pending">Đang chờ</option>
              <option value="completed">Hoàn thành</option>
              <option value="canceled">Đã hủy</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Số bàn</label>
            <input
              v-model="filters.table_number"
              type="text"
              placeholder="Nhập số bàn..."
              class="input-field"
              @input="debouncedSearch"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Ngày</label>
            <input
              v-model="filters.date"
              type="date"
              class="input-field"
              @change="debouncedSearch"
            />
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

      <!-- Orders Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  ID
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Số bàn
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Tổng tiền
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Trạng thái
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Thời gian
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Hành động
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="order in orders" :key="order.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  #{{ order.id }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  Bàn {{ order.table_number }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatCurrency(order.total_amount) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <select
                    v-if="authStore.isAdmin"
                    :value="order.status"
                    @change="updateOrderStatus(order.id, $event.target.value)"
                    class="text-sm rounded-full px-3 py-1 font-semibold border-0 focus:ring-2 focus:ring-primary-500"
                    :class="{
                      'bg-yellow-100 text-yellow-800': order.status === 'pending',
                      'bg-green-100 text-green-800': order.status === 'completed',
                      'bg-red-100 text-red-800': order.status === 'canceled',
                    }"
                  >
                    <option value="pending">Đang chờ</option>
                    <option value="completed">Hoàn thành</option>
                    <option value="canceled">Đã hủy</option>
                  </select>
                  <span
                    v-else
                    class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                    :class="{
                      'bg-yellow-100 text-yellow-800': order.status === 'pending',
                      'bg-green-100 text-green-800': order.status === 'completed',
                      'bg-red-100 text-red-800': order.status === 'canceled',
                    }"
                  >
                    {{ getStatusText(order.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(order.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  <!-- NEW: View Details Button -->
                  <button
                    @click="viewOrderDetails(order.id)"
                    class="text-blue-600 hover:text-blue-900"
                  >
                    Xem chi tiết
                  </button>

                  <button
                    v-if="authStore.isAdmin"
                    @click="confirmDelete(order)"
                    class="text-red-600 hover:text-red-900 ml-4"
                  >
                    Xóa
                  </button>
                </td>
              </tr>
            </tbody>
          </table>

          <!-- Empty state -->
          <div v-if="orders.length === 0" class="text-center py-12">
            <p class="text-sm text-gray-500">Không có đơn hàng nào</p>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="pagination-container">
          <nav class="pagination">
            <button
              @click="previousPage"
              :disabled="currentPage === 1"
              class="pagination-button"
              :class="{ 'pagination-button-disabled': currentPage === 1 }"
            >
              Trước
            </button>

            <button
              v-for="page in visiblePages"
              :key="page"
              @click="goToPage(page)"
              class="pagination-button"
              :class="{ 'pagination-button-active': currentPage === page }"
            >
              {{ page }}
            </button>

            <button
              @click="nextPage"
              :disabled="currentPage === totalPages"
              class="pagination-button"
              :class="{ 'pagination-button-disabled': currentPage === totalPages }"
            >
              Sau
            </button>
          </nav>
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
        <div class="mt-3">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100">
            <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
              ></path>
            </svg>
          </div>
          <div class="mt-2 text-center">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Xác nhận xóa</h3>
            <p class="mt-2 text-sm text-gray-500">
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

    <!-- NEW: Order Details Modal -->
    <div
      v-if="showDetailsModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeDetailsModal"
    >
      <div
        class="relative top-10 mx-auto p-5 border max-w-4xl shadow-lg rounded-md bg-white"
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

          <!-- Order Info -->
          <div class="bg-gray-50 p-4 rounded-lg mb-4">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
              <div>
                <span class="font-medium text-gray-700">Số bàn:</span>
                <p class="text-gray-900">Bàn {{ selectedOrder?.table_number }}</p>
              </div>
              <div>
                <span class="font-medium text-gray-700">Trạng thái:</span>
                <p class="text-gray-900">{{ getStatusText(selectedOrder?.status) }}</p>
              </div>
              <div>
                <span class="font-medium text-gray-700">Tổng tiền:</span>
                <p class="text-gray-900 font-semibold">
                  {{ formatCurrency(selectedOrder?.total_amount) }}
                </p>
              </div>
              <div>
                <span class="font-medium text-gray-700">Thời gian:</span>
                <p class="text-gray-900">{{ formatDate(selectedOrder?.created_at) }}</p>
              </div>
            </div>
          </div>

          <!-- Order Items -->
          <div>
            <h4 class="font-medium text-gray-900 mb-3">Món ăn đã đặt:</h4>

            <div v-if="loadingDetails" class="text-center py-8">
              <div
                class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"
              ></div>
              <p class="mt-2 text-sm text-gray-500">Đang tải chi tiết...</p>
            </div>

            <div v-else-if="selectedOrder?.items && selectedOrder.items.length > 0">
              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-50">
                    <tr>
                      <th
                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Món ăn
                      </th>
                      <th
                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Số lượng
                      </th>
                      <th
                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Đơn giá
                      </th>
                      <th
                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Thành tiền
                      </th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr v-for="item in selectedOrder.items" :key="item.id">
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="flex items-center">
                          <div class="flex-shrink-0 h-10 w-10">
                            <img
                              :src="getImageUrl(item)"
                              :alt="item.dish_name"
                              class="h-10 w-10 rounded-full object-cover"
                              @error="handleImageError"
                            />
                          </div>
                          <div class="ml-4">
                            <div class="text-sm font-medium text-gray-900">
                              {{ item.dish_name }}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {{ item.quantity }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {{ formatCurrency(item.price) }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {{ formatCurrency(item.price * item.quantity) }}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div v-else class="text-center py-8 text-gray-500">
              Không có món ăn nào trong đơn hàng này
            </div>
          </div>

          <div class="flex justify-end mt-6">
            <button @click="closeDetailsModal" class="btn-secondary">Đóng</button>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth'
import AppLayout from '../../components/layout/AppLayout.vue'
import { ordersAPI } from '../../services/api'

const authStore = useAuthStore()

// Data
const orders = ref([])
const loading = ref(false)
const deleting = ref(false)
const loadingDetails = ref(false)
const showDeleteModal = ref(false)
const showDetailsModal = ref(false)
const orderToDelete = ref(null)
const selectedOrder = ref(null)

// Pagination
const currentPage = ref(1)
const limit = ref(10)
const total = ref(0)

// Filters
const filters = ref({
  status: '',
  table_number: '',
  date: '',
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
    loadOrders()
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

// NEW: View order details
const viewOrderDetails = async (orderId) => {
  console.log('Frontend: Viewing order details for ID:', orderId)
  loadingDetails.value = true
  showDetailsModal.value = true

  try {
    console.log('Frontend: Making API call to get order details')
    const response = await ordersAPI.getById(orderId)
    console.log('Frontend: API response:', response)
    console.log('Frontend: Order data:', response.data)

    selectedOrder.value = response.data
    console.log('Frontend: Selected order set to:', selectedOrder.value)
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
}

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

const getImageUrl = (item) => {
  if (item.image_url && item.image_url.startsWith('/uploads/')) {
    return `http://localhost:3000${item.image_url}`
  }
  return '/placeholder-dish.jpg'
}

const handleImageError = (event) => {
  event.target.src = '/placeholder-dish.jpg'
}

const updateOrderStatus = async (orderId, status) => {
  try {
    await ordersAPI.update(orderId, { status })
    const order = orders.value.find((o) => o.id === orderId)
    if (order) {
      order.status = status
    }
  } catch (error) {
    console.error('Error updating order status:', error)
    alert('Có lỗi xảy ra khi cập nhật trạng thái đơn hàng')
  }
}

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
      loadOrders()
    }
  } catch (error) {
    console.error('Error deleting order:', error)
    alert('Có lỗi xảy ra khi xóa đơn hàng')
  } finally {
    deleting.value = false
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

onMounted(() => {
  loadOrders()
})
</script>
