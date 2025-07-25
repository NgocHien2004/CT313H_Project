<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý đặt bàn
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <button @click="openCreateModal" class="btn-primary">Đặt bàn mới</button>
        </div>
      </div>

      <!-- Filters -->
      <div class="bg-white shadow-sm rounded-lg p-6">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div>
            <label class="block text-sm font-medium text-gray-700">Trạng thái</label>
            <select v-model="filters.status" class="input-field" @change="loadReservations">
              <option value="">Tất cả trạng thái</option>
              <option value="booked">Đã đặt</option>
              <option value="canceled">Đã hủy</option>
              <option value="done">Hoàn thành</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Tên khách hàng</label>
            <input
              v-model="filters.customer_name"
              type="text"
              placeholder="Tên khách hàng..."
              class="input-field"
              @input="debouncedSearch"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Ngày đặt</label>
            <input
              v-model="filters.date"
              type="date"
              class="input-field"
              @change="loadReservations"
            />
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Reservations Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Khách hàng
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Số điện thoại
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Số khách
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Thời gian đặt
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Trạng thái
                </th>
                <th
                  class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Hành động
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr
                v-for="reservation in reservations"
                :key="reservation.id"
                class="hover:bg-gray-50"
              >
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">
                    {{ reservation.customer_name }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ reservation.phone_number }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ reservation.number_of_guests }} người</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">
                    {{ formatDateTime(reservation.reservation_time) }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      reservation.status === 'booked'
                        ? 'bg-green-100 text-green-800'
                        : reservation.status === 'canceled'
                          ? 'bg-red-100 text-red-800'
                          : 'bg-blue-100 text-blue-800',
                    ]"
                  >
                    {{ getStatusText(reservation.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex justify-end space-x-2">
                    <button
                      v-if="reservation.status === 'booked'"
                      @click="updateReservationStatus(reservation.id, 'done')"
                      class="text-blue-600 hover:text-blue-500"
                    >
                      Hoàn thành
                    </button>
                    <button
                      v-if="reservation.status === 'booked'"
                      @click="updateReservationStatus(reservation.id, 'canceled')"
                      class="text-red-600 hover:text-red-500"
                    >
                      Hủy
                    </button>
                    <button
                      @click="openEditModal(reservation)"
                      class="text-primary-600 hover:text-primary-500"
                    >
                      Sửa
                    </button>
                    <button
                      v-if="authStore.isAdmin"
                      @click="confirmDelete(reservation)"
                      class="text-red-600 hover:text-red-500"
                    >
                      Xóa
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty State -->
        <div v-if="reservations.length === 0" class="text-center py-12">
          <svg
            class="mx-auto h-12 w-12 text-gray-400"
            stroke="currentColor"
            fill="none"
            viewBox="0 0 48 48"
          >
            <path
              d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có đặt bàn nào</h3>
          <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách tạo đặt bàn mới.</p>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeModal"
    >
      <div
        class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white"
        @click.stop
      >
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ editingReservation ? 'Chỉnh sửa đặt bàn' : 'Đặt bàn mới' }}
          </h3>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label for="customer_name" class="block text-sm font-medium text-gray-700">
                Tên khách hàng <span class="text-red-500">*</span>
              </label>
              <input
                id="customer_name"
                v-model="form.customer_name"
                type="text"
                required
                class="input-field"
                placeholder="Nhập tên khách hàng"
              />
            </div>

            <div>
              <label for="phone_number" class="block text-sm font-medium text-gray-700">
                Số điện thoại <span class="text-red-500">*</span>
              </label>
              <input
                id="phone_number"
                v-model="form.phone_number"
                type="tel"
                required
                class="input-field"
                placeholder="Nhập số điện thoại"
              />
            </div>

            <div>
              <label for="number_of_guests" class="block text-sm font-medium text-gray-700">
                Số lượng khách <span class="text-red-500">*</span>
              </label>
              <input
                id="number_of_guests"
                v-model.number="form.number_of_guests"
                type="number"
                min="1"
                required
                class="input-field"
                placeholder="Số lượng khách"
              />
            </div>

            <div>
              <label for="reservation_time" class="block text-sm font-medium text-gray-700">
                Thời gian đặt bàn <span class="text-red-500">*</span>
              </label>
              <input
                id="reservation_time"
                v-model="form.reservation_time"
                type="datetime-local"
                required
                class="input-field"
              />
            </div>

            <div v-if="error" class="rounded-md bg-red-50 p-4">
              <div class="text-sm text-red-700">
                {{ error }}
              </div>
            </div>

            <div class="flex gap-3 pt-4">
              <button type="button" @click="closeModal" class="flex-1 btn-secondary">Hủy</button>
              <button type="submit" :disabled="submitting" class="flex-1 btn-primary">
                {{ submitting ? 'Đang lưu...' : editingReservation ? 'Cập nhật' : 'Đặt bàn' }}
              </button>
            </div>
          </form>
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa đặt bàn</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa đặt bàn của "{{ reservationToDelete?.customer_name }}"? Hành
              động này không thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteReservation" :disabled="deleting" class="flex-1 btn-danger">
              {{ deleting ? 'Đang xóa...' : 'Xóa' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import AppLayout from '../../components/layout/AppLayout.vue'
import { reservationsAPI } from '../../services/api'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

// Data
const reservations = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingReservation = ref(null)
const reservationToDelete = ref(null)
const error = ref('')

// Filters
const filters = ref({
  status: '',
  customer_name: '',
  date: '',
})

const form = reactive({
  customer_name: '',
  phone_number: '',
  number_of_guests: '',
  reservation_time: '',
})

// Debounced search
let searchTimeout = null
const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    loadReservations()
  }, 500)
}

// Methods
const loadReservations = async () => {
  loading.value = true
  try {
    const params = { limit: 100 }

    if (filters.value.status) params.status = filters.value.status
    if (filters.value.customer_name) params.customer_name = filters.value.customer_name
    if (filters.value.date) params.date = filters.value.date

    const response = await reservationsAPI.getAll(params)
    reservations.value = response.data.data || []
  } catch (error) {
    console.error('Error loading reservations:', error)
  } finally {
    loading.value = false
  }
}

const formatDateTime = (dateString) => {
  return new Date(dateString).toLocaleString('vi-VN')
}

const getStatusText = (status) => {
  const statusMap = {
    booked: 'Đã đặt',
    canceled: 'Đã hủy',
    done: 'Hoàn thành',
  }
  return statusMap[status] || status
}

const updateReservationStatus = async (reservationId, status) => {
  try {
    await reservationsAPI.update(reservationId, { status })
    const reservation = reservations.value.find((r) => r.id === reservationId)
    if (reservation) {
      reservation.status = status
    }
  } catch (error) {
    console.error('Error updating reservation status:', error)
    alert('Có lỗi xảy ra khi cập nhật trạng thái đặt bàn')
  }
}

const openCreateModal = () => {
  editingReservation.value = null
  Object.assign(form, {
    customer_name: '',
    phone_number: '',
    number_of_guests: '',
    reservation_time: '',
  })
  error.value = ''
  showModal.value = true
}

const openEditModal = (reservation) => {
  editingReservation.value = reservation
  Object.assign(form, {
    customer_name: reservation.customer_name,
    phone_number: reservation.phone_number,
    number_of_guests: reservation.number_of_guests,
    reservation_time: new Date(reservation.reservation_time).toISOString().slice(0, 16),
  })
  error.value = ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingReservation.value = null
  error.value = ''
}

const handleSubmit = async () => {
  error.value = ''
  submitting.value = true

  try {
    const data = {
      customer_name: form.customer_name,
      phone_number: form.phone_number,
      number_of_guests: parseInt(form.number_of_guests),
      reservation_time: new Date(form.reservation_time).toISOString(),
    }

    if (editingReservation.value) {
      const response = await reservationsAPI.update(editingReservation.value.id, data)
      const index = reservations.value.findIndex((r) => r.id === editingReservation.value.id)
      if (index !== -1) {
        reservations.value[index] = response.data.data
      }
    } else {
      const response = await reservationsAPI.create(data)
      reservations.value.push(response.data.data)
    }

    closeModal()
  } catch (err) {
    console.error('Error saving reservation:', err)
    const apiError = err.response?.data?.error

    if (typeof apiError === 'object' && apiError?.message && apiError?.field) {
      error.value = `${apiError.field}: ${apiError.message}`
    } else if (typeof apiError === 'string') {
      error.value = apiError
    } else {
      error.value = 'Có lỗi xảy ra khi lưu đặt bàn'
    }
  } finally {
    submitting.value = false
  }
}

const confirmDelete = (reservation) => {
  reservationToDelete.value = reservation
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  reservationToDelete.value = null
}

const deleteReservation = async () => {
  if (!reservationToDelete.value) return

  deleting.value = true
  try {
    await reservationsAPI.delete(reservationToDelete.value.id)
    reservations.value = reservations.value.filter((r) => r.id !== reservationToDelete.value.id)
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting reservation:', error)
    alert('Có lỗi xảy ra khi xóa đặt bàn')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadReservations()
})
</script>
