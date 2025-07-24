<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý kho hàng
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4 space-x-3">
          <button @click="openCreateModal" class="btn-primary">Thêm nguyên liệu mới</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Inventory Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Tên nguyên liệu
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Số lượng
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Đơn vị
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Tồn kho tối thiểu
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
              <tr v-for="item in inventory" :key="item.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ item.name }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ item.quantity }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ item.unit }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ item.min_quantity || 0 }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      item.quantity <= (item.min_quantity || 0)
                        ? 'bg-red-100 text-red-800'
                        : item.quantity <= (item.min_quantity || 0) * 2
                          ? 'bg-yellow-100 text-yellow-800'
                          : 'bg-green-100 text-green-800',
                    ]"
                  >
                    {{
                      item.quantity <= (item.min_quantity || 0)
                        ? 'Hết hàng'
                        : item.quantity <= (item.min_quantity || 0) * 2
                          ? 'Sắp hết'
                          : 'Đủ hàng'
                    }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex justify-end space-x-2">
                    <button
                      @click="openStockModal(item)"
                      class="text-green-600 hover:text-green-500 text-sm"
                    >
                      Nhập kho
                    </button>
                    <button
                      @click="openEditModal(item)"
                      class="text-primary-600 hover:text-primary-500 text-sm"
                    >
                      Sửa
                    </button>
                    <button
                      @click="confirmDelete(item)"
                      class="text-red-600 hover:text-red-500 text-sm"
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
        <div v-if="inventory.length === 0" class="text-center py-12">
          <svg
            class="mx-auto h-12 w-12 text-gray-400"
            stroke="currentColor"
            fill="none"
            viewBox="0 0 48 48"
          >
            <path
              d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có nguyên liệu nào</h3>
          <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách thêm nguyên liệu mới.</p>
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
            {{ editingItem ? 'Chỉnh sửa nguyên liệu' : 'Thêm nguyên liệu mới' }}
          </h3>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700">
                Tên nguyên liệu <span class="text-red-500">*</span>
              </label>
              <input
                id="name"
                v-model="form.name"
                type="text"
                required
                class="input-field"
                placeholder="Nhập tên nguyên liệu"
              />
            </div>

            <div>
              <label for="quantity" class="block text-sm font-medium text-gray-700">
                Số lượng <span class="text-red-500">*</span>
              </label>
              <input
                id="quantity"
                v-model.number="form.quantity"
                type="number"
                min="0"
                required
                class="input-field"
                placeholder="Nhập số lượng"
              />
            </div>

            <div>
              <label for="unit" class="block text-sm font-medium text-gray-700">
                Đơn vị <span class="text-red-500">*</span>
              </label>
              <input
                id="unit"
                v-model="form.unit"
                type="text"
                required
                class="input-field"
                placeholder="kg, g, lít, ml, cái..."
              />
            </div>

            <div>
              <label for="min_quantity" class="block text-sm font-medium text-gray-700">
                Tồn kho tối thiểu
              </label>
              <input
                id="min_quantity"
                v-model.number="form.min_quantity"
                type="number"
                min="0"
                class="input-field"
                placeholder="Số lượng tối thiểu"
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
                {{ submitting ? 'Đang lưu...' : editingItem ? 'Cập nhật' : 'Tạo mới' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Stock In Modal -->
    <div
      v-if="showStockModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeStockModal"
    >
      <div
        class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white"
        @click.stop
      >
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Nhập kho: {{ stockItem?.name }}</h3>

          <form @submit.prevent="handleStockIn" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">
                Số lượng hiện tại: {{ stockItem?.quantity }} {{ stockItem?.unit }}
              </label>
            </div>

            <div>
              <label for="quantity_added" class="block text-sm font-medium text-gray-700">
                Số lượng nhập <span class="text-red-500">*</span>
              </label>
              <input
                id="quantity_added"
                v-model.number="stockForm.quantity_added"
                type="number"
                min="1"
                required
                class="input-field"
                placeholder="Nhập số lượng"
              />
            </div>

            <div>
              <label for="note" class="block text-sm font-medium text-gray-700">
                Ghi chú <span class="text-red-500">*</span>
              </label>
              <textarea
                id="note"
                v-model="stockForm.note"
                required
                rows="3"
                class="input-field"
                placeholder="Nhập ghi chú về lần nhập kho này"
              ></textarea>
            </div>

            <div v-if="stockError" class="rounded-md bg-red-50 p-4">
              <div class="text-sm text-red-700">
                {{ stockError }}
              </div>
            </div>

            <div class="flex gap-3 pt-4">
              <button type="button" @click="closeStockModal" class="flex-1 btn-secondary">
                Hủy
              </button>
              <button type="submit" :disabled="stockSubmitting" class="flex-1 btn-primary">
                {{ stockSubmitting ? 'Đang nhập...' : 'Nhập kho' }}
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa nguyên liệu</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa nguyên liệu "{{ itemToDelete?.name }}"? Hành động này không
              thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteItem" :disabled="deleting" class="flex-1 btn-danger">
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
import { inventoryAPI, inventoryLogsAPI } from '../../services/api'

// Data
const inventory = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const stockSubmitting = ref(false)
const showModal = ref(false)
const showStockModal = ref(false)
const showDeleteModal = ref(false)
const editingItem = ref(null)
const stockItem = ref(null)
const itemToDelete = ref(null)
const error = ref('')
const stockError = ref('')

const form = reactive({
  name: '',
  quantity: '',
  unit: '',
  min_quantity: '',
})

const stockForm = reactive({
  quantity_added: '',
  note: '',
})

// Methods
const loadInventory = async () => {
  loading.value = true
  try {
    const response = await inventoryAPI.getAll({ limit: 100 })
    inventory.value = response.data.data || []
  } catch (error) {
    console.error('Error loading inventory:', error)
  } finally {
    loading.value = false
  }
}

const openCreateModal = () => {
  editingItem.value = null
  Object.assign(form, {
    name: '',
    quantity: '',
    unit: '',
    min_quantity: '',
  })
  error.value = ''
  showModal.value = true
}

const openEditModal = (item) => {
  editingItem.value = item
  Object.assign(form, {
    name: item.name,
    quantity: item.quantity,
    unit: item.unit,
    min_quantity: item.min_quantity || '',
  })
  error.value = ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingItem.value = null
  error.value = ''
}

const openStockModal = (item) => {
  stockItem.value = item
  Object.assign(stockForm, {
    quantity_added: '',
    note: '',
  })
  stockError.value = ''
  showStockModal.value = true
}

const closeStockModal = () => {
  showStockModal.value = false
  stockItem.value = null
  stockError.value = ''
}

const handleSubmit = async () => {
  error.value = ''
  submitting.value = true

  try {
    const data = {
      name: form.name,
      quantity: parseInt(form.quantity),
      unit: form.unit,
      min_quantity: form.min_quantity ? parseInt(form.min_quantity) : null,
    }

    if (editingItem.value) {
      const response = await inventoryAPI.update(editingItem.value.id, data)
      const index = inventory.value.findIndex((i) => i.id === editingItem.value.id)
      if (index !== -1) {
        inventory.value[index] = response.data.data
      }
    } else {
      const response = await inventoryAPI.create(data)
      inventory.value.push(response.data.data)
    }

    closeModal()
  } catch (err) {
    console.error('Error saving inventory item:', err)
    error.value = err.response?.data?.error || 'Có lỗi xảy ra khi lưu nguyên liệu'
  } finally {
    submitting.value = false
  }
}

const handleStockIn = async () => {
  stockError.value = ''
  stockSubmitting.value = true

  try {
    const logData = {
      inventory_id: stockItem.value.id,
      quantity_added: parseInt(stockForm.quantity_added),
      note: stockForm.note,
    }

    await inventoryLogsAPI.create(logData)

    // Update inventory quantity
    const newQuantity = stockItem.value.quantity + parseInt(stockForm.quantity_added)
    await inventoryAPI.update(stockItem.value.id, { quantity: newQuantity })

    // Update local data
    stockItem.value.quantity = newQuantity
    const index = inventory.value.findIndex((i) => i.id === stockItem.value.id)
    if (index !== -1) {
      inventory.value[index].quantity = newQuantity
    }

    closeStockModal()
  } catch (err) {
    console.error('Error adding stock:', err)
    stockError.value = err.response?.data?.error || 'Có lỗi xảy ra khi nhập kho'
  } finally {
    stockSubmitting.value = false
  }
}

const confirmDelete = (item) => {
  itemToDelete.value = item
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  itemToDelete.value = null
}

const deleteItem = async () => {
  if (!itemToDelete.value) return

  deleting.value = true
  try {
    await inventoryAPI.delete(itemToDelete.value.id)
    inventory.value = inventory.value.filter((i) => i.id !== itemToDelete.value.id)
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting inventory item:', error)
    alert('Có lỗi xảy ra khi xóa nguyên liệu')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadInventory()
})
</script>
