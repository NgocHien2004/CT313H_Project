<template>
  <AppLayout>
    <div class="max-w-2xl mx-auto">
      <!-- Header -->
      <div class="mb-6">
        <div class="flex items-center space-x-4">
          <router-link to="/dishes" class="text-gray-400 hover:text-gray-600">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              ></path>
            </svg>
          </router-link>
          <h1 class="text-2xl font-bold text-gray-900">
            {{ isEdit ? 'Chỉnh sửa món ăn' : 'Thêm món ăn mới' }}
          </h1>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loadingData" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải dữ liệu...</p>
      </div>

      <!-- Form -->
      <div v-else class="bg-white shadow-sm rounded-lg">
        <form @submit.prevent="handleSubmit" class="space-y-6 p-6">
          <!-- Name -->
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700">
              Tên món ăn <span class="text-red-500">*</span>
            </label>
            <input
              id="name"
              v-model="form.name"
              type="text"
              required
              class="input-field"
              placeholder="Nhập tên món ăn"
            />
          </div>

          <!-- Description -->
          <div>
            <label for="description" class="block text-sm font-medium text-gray-700"> Mô tả </label>
            <textarea
              id="description"
              v-model="form.description"
              rows="3"
              class="input-field"
              placeholder="Nhập mô tả món ăn"
            ></textarea>
          </div>

          <!-- Price -->
          <div>
            <label for="price" class="block text-sm font-medium text-gray-700">
              Giá <span class="text-red-500">*</span>
            </label>
            <div class="relative">
              <input
                id="price"
                v-model.number="form.price"
                type="number"
                min="0"
                step="1000"
                required
                class="input-field pr-12"
                placeholder="0"
              />
              <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                <span class="text-gray-500 sm:text-sm">VNĐ</span>
              </div>
            </div>
          </div>

          <!-- Category -->
          <div>
            <label for="category_id" class="block text-sm font-medium text-gray-700">
              Danh mục <span class="text-red-500">*</span>
            </label>
            <select id="category_id" v-model="form.category_id" required class="input-field">
              <option value="">Chọn danh mục</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.name }}
              </option>
            </select>
          </div>

          <!-- Image Upload -->
          <div>
            <label class="block text-sm font-medium text-gray-700"> Hình ảnh món ăn </label>
            <div
              class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md"
            >
              <div class="space-y-1 text-center">
                <!-- Preview Image -->
                <div v-if="imagePreview" class="mb-4">
                  <img
                    :src="imagePreview"
                    alt="Preview"
                    class="mx-auto h-32 w-32 object-cover rounded-lg"
                  />
                  <button
                    type="button"
                    @click="removeImage"
                    class="mt-2 text-sm text-red-600 hover:text-red-500"
                  >
                    Xóa ảnh
                  </button>
                </div>

                <!-- Upload Interface -->
                <div v-else>
                  <svg
                    class="mx-auto h-12 w-12 text-gray-400"
                    stroke="currentColor"
                    fill="none"
                    viewBox="0 0 48 48"
                  >
                    <path
                      d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                      stroke-width="2"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    />
                  </svg>
                  <div class="flex text-sm text-gray-600">
                    <label
                      for="file-upload"
                      class="relative cursor-pointer bg-white rounded-md font-medium text-blue-600 hover:text-blue-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-blue-500"
                    >
                      <span>Tải lên file</span>
                      <input
                        id="file-upload"
                        ref="imageInput"
                        name="file-upload"
                        type="file"
                        accept="image/*"
                        class="sr-only"
                        @change="handleImageChange"
                      />
                    </label>
                    <p class="pl-1">hoặc kéo thả</p>
                  </div>
                  <p class="text-xs text-gray-500">PNG, JPG, WEBP tối đa 4MB</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Error Message -->
          <div v-if="error" class="rounded-md bg-red-50 p-4">
            <div class="text-sm text-red-700">
              {{ error }}
            </div>
          </div>

          <!-- Success Message -->
          <div v-if="success" class="rounded-md bg-green-50 p-4">
            <div class="text-sm text-green-700">
              {{ success }}
            </div>
          </div>

          <!-- Actions -->
          <div class="flex justify-end space-x-4 pt-6 border-t">
            <router-link to="/dishes" class="btn-secondary"> Hủy </router-link>
            <button type="submit" :disabled="loading" class="btn-primary">
              {{ loading ? 'Đang lưu...' : isEdit ? 'Cập nhật' : 'Tạo món ăn' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppLayout from '../../components/layout/AppLayout.vue'
import { dishesAPI, categoriesAPI } from '../../services/api'

const route = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.params.id)
const dishId = computed(() => route.params.id)

// Data
const categories = ref([])
const loading = ref(false)
const loadingData = ref(false)
const error = ref('')
const success = ref('')
const imagePreview = ref('')
const imageFile = ref(null)
const imageInput = ref(null)

// Form data - removed is_available field since it's now auto-calculated
const form = reactive({
  name: '',
  description: '',
  price: '',
  category_id: '',
})

// Methods
const loadCategories = async () => {
  try {
    console.log('Loading categories...')
    const response = await categoriesAPI.getAll()
    categories.value = response.data || []
    console.log('Categories loaded:', categories.value.length)
  } catch (err) {
    console.error('Error loading categories:', err)
    error.value = 'Không thể tải danh sách danh mục'
  }
}

const loadDish = async () => {
  if (!isEdit.value) return

  loadingData.value = true
  try {
    console.log('Loading dish with ID:', dishId.value)

    // Get dish by ID - using existing API pattern
    const response = await dishesAPI.getAll({ page: 1, limit: 1000 })
    const allDishes = response.data.data || []
    const dish = allDishes.find((d) => d.id == dishId.value)

    if (dish) {
      console.log('Dish found:', dish)
      // Only load the editable fields, ignore is_available since it's auto-calculated
      Object.assign(form, {
        name: dish.name || '',
        description: dish.description || '',
        price: dish.price || '',
        category_id: dish.category_id || '',
      })

      if (dish.image_url) {
        imagePreview.value = `http://localhost:3000${dish.image_url}`
      }
    } else {
      error.value = 'Không tìm thấy món ăn'
    }
  } catch (err) {
    console.error('Error loading dish:', err)
    error.value = 'Không thể tải thông tin món ăn'
  } finally {
    loadingData.value = false
  }
}

const handleImageChange = (event) => {
  const file = event.target.files[0]
  if (!file) return

  // Validate file type
  if (!file.type.startsWith('image/')) {
    error.value = 'Vui lòng chọn file ảnh'
    return
  }

  // Validate file size (4MB)
  if (file.size > 4 * 1024 * 1024) {
    error.value = 'Kích thước ảnh không được vượt quá 4MB'
    return
  }

  imageFile.value = file

  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target.result
  }
  reader.readAsDataURL(file)

  error.value = ''
}

const removeImage = () => {
  imagePreview.value = ''
  imageFile.value = null
  if (imageInput.value) {
    imageInput.value.value = ''
  }
}

const validateForm = () => {
  error.value = ''

  if (!form.name?.trim()) {
    error.value = 'Vui lòng nhập tên món ăn'
    return false
  }

  if (!form.price || form.price <= 0) {
    error.value = 'Vui lòng nhập giá hợp lệ'
    return false
  }

  if (!form.category_id) {
    error.value = 'Vui lòng chọn danh mục'
    return false
  }

  return true
}

const handleSubmit = async () => {
  console.log('Form submitted')

  if (!validateForm()) {
    return
  }

  loading.value = true
  error.value = ''
  success.value = ''

  try {
    // Prepare form data
    const formData = new FormData()
    formData.append('name', form.name.trim())
    formData.append('description', form.description?.trim() || '')
    formData.append('price', parseFloat(form.price))
    formData.append('category_id', parseInt(form.category_id))

    // Set default availability to true - it will be auto-calculated based on ingredients
    formData.append('is_available', 'true')

    if (imageFile.value) {
      formData.append('image', imageFile.value)
    }

    console.log('Sending data:', {
      name: form.name,
      price: form.price,
      category_id: form.category_id,
      is_available: true, // Default value
      hasImage: !!imageFile.value,
    })

    let response
    if (isEdit.value) {
      response = await dishesAPI.update(dishId.value, formData)
      success.value = 'Cập nhật món ăn thành công!'
    } else {
      response = await dishesAPI.create(formData)
      success.value = 'Tạo món ăn thành công!'
    }

    console.log('API Response:', response)

    // Navigate after 1 second
    setTimeout(() => {
      router.push('/dishes')
    }, 1000)
  } catch (err) {
    console.error('Error saving dish:', err)
    if (err.response?.data?.error) {
      error.value = err.response.data.error
    } else if (err.response?.data?.message) {
      error.value = err.response.data.message
    } else {
      error.value = 'Có lỗi xảy ra khi lưu món ăn'
    }
  } finally {
    loading.value = false
  }
}

// Initialize data
onMounted(async () => {
  console.log('DishForm mounted, isEdit:', isEdit.value)
  loadingData.value = true

  try {
    await loadCategories()
    if (isEdit.value) {
      await loadDish()
    }
  } finally {
    loadingData.value = false
  }
})
</script>
