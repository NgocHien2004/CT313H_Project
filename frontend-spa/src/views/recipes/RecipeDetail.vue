<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-4">
          <button
            @click="goBack"
            class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              ></path>
            </svg>
            Quay lại
          </button>
          <h1 class="text-2xl font-bold text-gray-900">Công thức món ăn</h1>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-8">
        <div
          class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto"
        ></div>
        <p class="mt-2 text-gray-600">Đang tải...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-md p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800">Lỗi</h3>
            <div class="mt-2 text-sm text-red-700">
              <p>{{ error }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Recipe Content -->
      <div v-else-if="dish" class="space-y-6">
        <!-- Dish Information -->
        <div class="bg-white shadow rounded-lg p-6">
          <div class="flex items-start space-x-6">
            <!-- Dish Image -->
            <div class="flex-shrink-0">
              <img
                :src="getImageUrl(dish)"
                :alt="dish.name"
                class="h-32 w-32 object-cover rounded-lg shadow-md"
                @error="handleImageError"
              />
            </div>

            <!-- Dish Details -->
            <div class="flex-1">
              <h2 class="text-xl font-bold text-gray-900 mb-2">{{ dish.name }}</h2>
              <p v-if="dish.description" class="text-gray-600 mb-3">{{ dish.description }}</p>

              <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="font-medium text-gray-700">Giá bán:</span>
                  <span class="ml-2 text-green-600 font-semibold">{{
                    formatCurrency(dish.price)
                  }}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700">Danh mục:</span>
                  <span class="ml-2">{{ getCategoryName(dish.category_id) }}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700">Trạng thái:</span>
                  <span
                    :class="dish.is_available ? 'text-green-600' : 'text-red-600'"
                    class="ml-2 font-medium"
                  >
                    {{ dish.is_available ? 'Có sẵn' : 'Hết hàng' }}
                  </span>
                </div>
                <div>
                  <span class="font-medium text-gray-700">Số nguyên liệu:</span>
                  <span class="ml-2 text-blue-600 font-medium"
                    >{{ dishIngredients.length || 0 }} loại</span
                  >
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recipe Ingredients Table -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <div>
              <h3 class="text-lg font-medium text-gray-900">Công thức nguyên liệu</h3>
              <p class="mt-1 text-sm text-gray-600">
                Danh sách các nguyên liệu cần thiết để chế biến món ăn
              </p>
            </div>
            <div v-if="authStore.isAdmin">
              <button
                @click="openAddIngredientModal"
                class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                  ></path>
                </svg>
                Thêm nguyên liệu
              </button>
            </div>
          </div>

          <div class="overflow-hidden">
            <!-- Empty State -->
            <div
              v-if="!dishIngredients || dishIngredients.length === 0"
              class="px-6 py-8 text-center"
            >
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
                  d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-6m-4 0H4"
                />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">Chưa có công thức</h3>
              <p class="mt-1 text-sm text-gray-500">
                Món ăn này chưa được thiết lập công thức nguyên liệu.
              </p>
            </div>

            <!-- Ingredients Table -->
            <div v-else class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      STT
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Tên nguyên liệu
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Số lượng cần
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Đơn vị
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Tồn kho hiện tại
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Trạng thái
                    </th>
                    <th
                      v-if="authStore.isAdmin"
                      scope="col"
                      class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Hành động
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr
                    v-for="(ingredient, index) in dishIngredients"
                    :key="ingredient.id || index"
                    class="hover:bg-gray-50"
                  >
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ index + 1 }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm font-medium text-gray-900">
                        {{ getInventoryName(ingredient.inventory_id) }}
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900 font-semibold">
                        {{ ingredient.quantity_required }}
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-600">
                        {{ getInventoryUnit(ingredient.inventory_id) || 'Không có' }}
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900">
                        {{ getInventoryQuantity(ingredient.inventory_id) || 0 }}
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span
                        :class="getStockStatusClass(ingredient)"
                        class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                      >
                        {{ getStockStatusText(ingredient) }}
                      </span>
                    </td>
                    <td
                      v-if="authStore.isAdmin"
                      class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium"
                    >
                      <div class="flex justify-end space-x-2">
                        <button
                          @click="openEditIngredientModal(ingredient)"
                          class="text-primary-600 hover:text-primary-500"
                        >
                          Sửa
                        </button>
                        <button
                          @click="confirmDeleteIngredient(ingredient)"
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
          </div>

          <!-- Table Footer with Summary -->
          <div
            v-if="dishIngredients && dishIngredients.length > 0"
            class="bg-gray-50 px-6 py-3 border-t border-gray-200"
          >
            <div class="flex justify-between items-center text-sm text-gray-600">
              <span>Tổng cộng: {{ dishIngredients.length }} nguyên liệu</span>
              <div class="flex space-x-4">
                <span class="text-green-600">✓ Đủ: {{ sufficientCount }}</span>
                <span class="text-yellow-600">⚠ Thiếu: {{ insufficientCount }}</span>
                <span class="text-red-600">✗ Hết: {{ outOfStockCount }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div v-if="authStore.isAdmin" class="flex justify-end space-x-3">
          <router-link
            :to="`/dishes/${dish.id}/edit`"
            class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
              ></path>
            </svg>
            Sửa món ăn
          </router-link>
        </div>
      </div>
    </div>

    <!-- Add/Edit Ingredient Modal -->
    <div
      v-if="showIngredientModal"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="closeIngredientModal"
    >
      <div
        class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white"
        @click.stop
      >
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900">
            {{ editingIngredient ? 'Sửa nguyên liệu' : 'Thêm nguyên liệu mới' }}
          </h3>
          <form @submit.prevent="handleIngredientSubmit" class="mt-4 space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Nguyên liệu</label>
              <select v-model="ingredientForm.inventory_id" required class="input-field">
                <option value="">Chọn nguyên liệu</option>
                <option v-for="item in inventory" :key="item.id" :value="item.id">
                  {{ item.name }} ({{ item.unit || 'Đơn vị' }}) - Tồn kho: {{ item.quantity }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Số lượng cần</label>
              <input
                v-model="ingredientForm.quantity_required"
                type="number"
                step="0.1"
                required
                class="input-field"
                placeholder="Nhập số lượng cần thiết"
              />
            </div>

            <div v-if="ingredientError" class="rounded-md bg-red-50 p-4">
              <div class="text-sm text-red-700">{{ ingredientError }}</div>
            </div>

            <div class="flex gap-4 mt-6">
              <button type="button" @click="closeIngredientModal" class="flex-1 btn-secondary">
                Hủy
              </button>
              <button type="submit" :disabled="submittingIngredient" class="flex-1 btn-primary">
                {{
                  submittingIngredient ? 'Đang lưu...' : editingIngredient ? 'Cập nhật' : 'Thêm mới'
                }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Delete Ingredient Confirmation Modal -->
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
              Bạn có chắc chắn muốn xóa nguyên liệu "{{
                getInventoryName(ingredientToDelete?.inventory_id)
              }}" khỏi công thức? Hành động này không thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button
              @click="deleteIngredient"
              :disabled="deletingIngredient"
              class="flex-1 btn-danger"
            >
              {{ deletingIngredient ? 'Đang xóa...' : 'Xóa' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted, computed, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import AppLayout from '../../components/layout/AppLayout.vue'
import { dishIngredientsAPI, inventoryAPI, categoriesAPI } from '../../services/api'
import axios from 'axios'

// Tạo axios instance với base config
const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor để thêm token
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

// Composables
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

// Reactive data
const dish = ref(null)
const dishIngredients = ref([])
const inventory = ref([])
const categories = ref([])
const loading = ref(false)
const error = ref(null)

// Ingredient management
const showIngredientModal = ref(false)
const showDeleteModal = ref(false)
const editingIngredient = ref(null)
const ingredientToDelete = ref(null)
const submittingIngredient = ref(false)
const deletingIngredient = ref(false)
const ingredientError = ref('')

const ingredientForm = reactive({
  inventory_id: '',
  quantity_required: '',
})

// Computed properties
const sufficientCount = computed(() => {
  if (!dishIngredients.value) return 0
  return dishIngredients.value.filter((ingredient) => {
    const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
    const current = inventoryItem?.quantity || 0
    const required = ingredient.quantity_required || 0
    return current >= required
  }).length
})

const insufficientCount = computed(() => {
  if (!dishIngredients.value) return 0
  return dishIngredients.value.filter((ingredient) => {
    const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
    const current = inventoryItem?.quantity || 0
    const required = ingredient.quantity_required || 0
    return current > 0 && current < required
  }).length
})

const outOfStockCount = computed(() => {
  if (!dishIngredients.value) return 0
  return dishIngredients.value.filter((ingredient) => {
    const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
    return (inventoryItem?.quantity || 0) === 0
  }).length
})

// Methods
const loadDishWithRecipe = async () => {
  loading.value = true
  error.value = null

  try {
    const dishId = route.params.id
    console.log('Loading dish recipe for ID:', dishId)

    const response = await axiosClient.get(`/dishes/${dishId}/detail`)
    console.log('Dish recipe response:', response.data)

    dish.value = response.data

    // Load dish ingredients using correct API
    await loadDishIngredients()
  } catch (err) {
    console.error('Error loading dish recipe:', err)
    error.value = err.response?.data?.message || 'Không thể tải thông tin công thức món ăn'
  } finally {
    loading.value = false
  }
}

const loadDishIngredients = async () => {
  try {
    const dishId = route.params.id
    // Use the specific API endpoint for dish ingredients
    const response = await axiosClient.get(`/dish-ingredients/dish/${dishId}`)
    dishIngredients.value = response.data || []
    console.log('Loaded dish ingredients:', dishIngredients.value)
  } catch (err) {
    console.error('Error loading dish ingredients:', err)
    dishIngredients.value = []
  }
}

const loadInventory = async () => {
  try {
    const response = await inventoryAPI.getAll({ limit: 100 })
    inventory.value = response.data.data || []
    console.log('Inventory loaded:', inventory.value)
  } catch (err) {
    console.error('Error loading inventory:', err)
  }
}

const loadCategories = async () => {
  try {
    const response = await categoriesAPI.getAll()
    categories.value = response.data || []
    console.log('Categories loaded:', categories.value)
  } catch (err) {
    console.error('Error loading categories:', err)
  }
}

const getCategoryName = (categoryId) => {
  if (!categoryId) return 'Không có'
  const category = categories.value.find((cat) => cat.id === categoryId)
  return category ? category.name : 'Không có'
}

const getInventoryName = (inventoryId) => {
  const item = inventory.value.find((inv) => inv.id === inventoryId)
  return item ? item.name : 'N/A'
}

const getInventoryUnit = (inventoryId) => {
  const item = inventory.value.find((inv) => inv.id === inventoryId)
  return item ? item.unit : null
}

const getInventoryQuantity = (inventoryId) => {
  const item = inventory.value.find((inv) => inv.id === inventoryId)
  return item ? item.quantity : 0
}

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount)
}

const getImageUrl = (dish) => {
  if (dish.image_url && dish.image_url.startsWith('/uploads/')) {
    return dish.image_url // Không hardcode localhost:3000
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

const getStockStatusClass = (ingredient) => {
  const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
  const current = inventoryItem?.quantity || 0
  const required = ingredient.quantity_required || 0

  if (current >= required) {
    return 'bg-green-100 text-green-800'
  } else if (current > 0) {
    return 'bg-yellow-100 text-yellow-800'
  } else {
    return 'bg-red-100 text-red-800'
  }
}

const getStockStatusText = (ingredient) => {
  const inventoryItem = inventory.value.find((inv) => inv.id === ingredient.inventory_id)
  const current = inventoryItem?.quantity || 0
  const required = ingredient.quantity_required || 0

  if (current >= required) {
    return 'Đủ'
  } else if (current > 0) {
    return 'Thiếu'
  } else {
    return 'Hết hàng'
  }
}

const goBack = () => {
  router.push('/dishes')
}

// Ingredient management methods
const openAddIngredientModal = () => {
  editingIngredient.value = null
  Object.assign(ingredientForm, {
    inventory_id: '',
    quantity_required: '',
  })
  ingredientError.value = ''
  showIngredientModal.value = true
}

const openEditIngredientModal = (ingredient) => {
  editingIngredient.value = ingredient
  Object.assign(ingredientForm, {
    inventory_id: ingredient.inventory_id,
    quantity_required: ingredient.quantity_required,
  })
  ingredientError.value = ''
  showIngredientModal.value = true
}

const closeIngredientModal = () => {
  showIngredientModal.value = false
  editingIngredient.value = null
  ingredientError.value = ''
}

const handleIngredientSubmit = async () => {
  ingredientError.value = ''
  submittingIngredient.value = true

  try {
    const data = {
      dish_id: parseInt(route.params.id),
      inventory_id: parseInt(ingredientForm.inventory_id),
      quantity_required: parseFloat(ingredientForm.quantity_required),
    }

    if (editingIngredient.value) {
      await dishIngredientsAPI.update(editingIngredient.value.id, data)
    } else {
      await dishIngredientsAPI.create(data)
    }

    closeIngredientModal()
    // Reload ingredients after adding/updating
    await loadDishIngredients()
  } catch (err) {
    console.error('Error saving ingredient:', err)
    ingredientError.value = err.response?.data?.error || 'Có lỗi xảy ra khi lưu nguyên liệu'
  } finally {
    submittingIngredient.value = false
  }
}

const confirmDeleteIngredient = (ingredient) => {
  ingredientToDelete.value = ingredient
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  ingredientToDelete.value = null
}

const deleteIngredient = async () => {
  if (!ingredientToDelete.value) return

  deletingIngredient.value = true
  try {
    await dishIngredientsAPI.delete(ingredientToDelete.value.id)
    closeDeleteModal()
    // Reload ingredients after deleting
    await loadDishIngredients()
  } catch (error) {
    console.error('Error deleting ingredient:', error)
    alert('Có lỗi xảy ra khi xóa nguyên liệu')
  } finally {
    deletingIngredient.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([loadDishWithRecipe(), loadInventory(), loadCategories()])
})
</script>
