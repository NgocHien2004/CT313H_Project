<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý nguyên liệu món ăn
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <button @click="openCreateModal" class="btn-primary">Thêm công thức mới</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Dish Ingredients Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
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
                  Nguyên liệu
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Số lượng cần
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
                v-for="ingredient in dishIngredients"
                :key="ingredient.id"
                class="hover:bg-gray-50"
              >
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">
                    {{ ingredient.dish_name || 'N/A' }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ ingredient.ingredient_name || 'N/A' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ ingredient.quantity_required }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex justify-end space-x-2">
                    <button
                      @click="openEditModal(ingredient)"
                      class="text-primary-600 hover:text-primary-500"
                    >
                      Sửa
                    </button>
                    <button
                      @click="confirmDelete(ingredient)"
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
        <div v-if="dishIngredients.length === 0" class="text-center py-12">
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
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có công thức nào</h3>
          <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách thêm công thức mới.</p>
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
            {{ editingIngredient ? 'Chỉnh sửa công thức' : 'Thêm công thức mới' }}
          </h3>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label for="dish_id" class="block text-sm font-medium text-gray-700">
                Món ăn <span class="text-red-500">*</span>
              </label>
              <select id="dish_id" v-model="form.dish_id" required class="input-field">
                <option value="">Chọn món ăn</option>
                <option v-for="dish in dishes" :key="dish.id" :value="dish.id">
                  {{ dish.name }}
                </option>
              </select>
            </div>

            <div>
              <label for="inventory_id" class="block text-sm font-medium text-gray-700">
                Nguyên liệu <span class="text-red-500">*</span>
              </label>
              <select id="inventory_id" v-model="form.inventory_id" required class="input-field">
                <option value="">Chọn nguyên liệu</option>
                <option v-for="item in inventory" :key="item.id" :value="item.id">
                  {{ item.name }} ({{ item.unit }})
                </option>
              </select>
            </div>

            <div>
              <label for="quantity_required" class="block text-sm font-medium text-gray-700">
                Số lượng cần <span class="text-red-500">*</span>
              </label>
              <input
                id="quantity_required"
                v-model.number="form.quantity_required"
                type="number"
                min="0.1"
                step="0.1"
                required
                class="input-field"
                placeholder="Nhập số lượng"
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
                {{ submitting ? 'Đang lưu...' : editingIngredient ? 'Cập nhật' : 'Tạo mới' }}
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa công thức</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa công thức này? Hành động này không thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteIngredient" :disabled="deleting" class="flex-1 btn-danger">
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
import { dishIngredientsAPI, dishesAPI, inventoryAPI } from '../../services/api'

// Data
const dishIngredients = ref([])
const dishes = ref([])
const inventory = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingIngredient = ref(null)
const ingredientToDelete = ref(null)
const error = ref('')

const form = reactive({
  dish_id: '',
  inventory_id: '',
  quantity_required: '',
})

// Methods
const loadDishIngredients = async () => {
  loading.value = true
  try {
    const response = await dishIngredientsAPI.getAll()
    dishIngredients.value = response.data || []
  } catch (error) {
    console.error('Error loading dish ingredients:', error)
  } finally {
    loading.value = false
  }
}

const loadDishes = async () => {
  try {
    const response = await dishesAPI.getAll({ limit: 100 })
    dishes.value = response.data.data || []
  } catch (error) {
    console.error('Error loading dishes:', error)
  }
}

const loadInventory = async () => {
  try {
    const response = await inventoryAPI.getAll({ limit: 100 })
    inventory.value = response.data.data || []
  } catch (error) {
    console.error('Error loading inventory:', error)
  }
}

const openCreateModal = () => {
  editingIngredient.value = null
  Object.assign(form, {
    dish_id: '',
    inventory_id: '',
    quantity_required: '',
  })
  error.value = ''
  showModal.value = true
}

const openEditModal = (ingredient) => {
  editingIngredient.value = ingredient
  Object.assign(form, {
    dish_id: ingredient.dish_id,
    inventory_id: ingredient.inventory_id,
    quantity_required: ingredient.quantity_required,
  })
  error.value = ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingIngredient.value = null
  error.value = ''
}

const handleSubmit = async () => {
  error.value = ''
  submitting.value = true

  try {
    const data = {
      dish_id: parseInt(form.dish_id),
      inventory_id: parseInt(form.inventory_id),
      quantity_required: parseFloat(form.quantity_required),
    }

    if (editingIngredient.value) {
      const response = await dishIngredientsAPI.update(editingIngredient.value.id, data)
      const index = dishIngredients.value.findIndex((i) => i.id === editingIngredient.value.id)
      if (index !== -1) {
        dishIngredients.value[index] = response.data.data
      }
    } else {
      const response = await dishIngredientsAPI.create(data)
      dishIngredients.value.push(response.data.data)
    }

    closeModal()
    // Reload to get updated names
    loadDishIngredients()
  } catch (err) {
    console.error('Error saving dish ingredient:', err)
    error.value = err.response?.data?.error || 'Có lỗi xảy ra khi lưu công thức'
  } finally {
    submitting.value = false
  }
}

const confirmDelete = (ingredient) => {
  ingredientToDelete.value = ingredient
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  ingredientToDelete.value = null
}

const deleteIngredient = async () => {
  if (!ingredientToDelete.value) return

  deleting.value = true
  try {
    await dishIngredientsAPI.delete(ingredientToDelete.value.id)
    dishIngredients.value = dishIngredients.value.filter(
      (i) => i.id !== ingredientToDelete.value.id,
    )
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting dish ingredient:', error)
    alert('Có lỗi xảy ra khi xóa công thức')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadDishIngredients()
  loadDishes()
  loadInventory()
})
</script>
