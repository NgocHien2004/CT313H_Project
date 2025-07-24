<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý danh mục
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <button @click="openCreateModal" class="btn-primary">Thêm danh mục mới</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Categories Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul class="divide-y divide-gray-200">
          <li v-for="category in categories" :key="category.id" class="px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center">
                  <div class="flex-1">
                    <h3 class="text-lg font-medium text-gray-900">
                      {{ category.name }}
                    </h3>
                    <p v-if="category.description" class="text-sm text-gray-500 mt-1">
                      {{ category.description }}
                    </p>
                  </div>
                </div>
              </div>

              <div class="flex items-center space-x-2">
                <button
                  @click="openEditModal(category)"
                  class="text-primary-600 hover:text-primary-500 text-sm font-medium"
                >
                  Sửa
                </button>
                <button
                  @click="confirmDelete(category)"
                  class="text-red-600 hover:text-red-500 text-sm font-medium"
                >
                  Xóa
                </button>
              </div>
            </div>
          </li>
        </ul>

        <!-- Empty State -->
        <div v-if="categories.length === 0" class="text-center py-12">
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
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có danh mục nào</h3>
          <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách tạo danh mục mới.</p>
          <div class="mt-6">
            <button @click="openCreateModal" class="btn-primary">Thêm danh mục mới</button>
          </div>
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
            {{ editingCategory ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới' }}
          </h3>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700">
                Tên danh mục <span class="text-red-500">*</span>
              </label>
              <input
                id="name"
                v-model="form.name"
                type="text"
                required
                class="input-field"
                placeholder="Nhập tên danh mục"
              />
            </div>

            <div>
              <label for="description" class="block text-sm font-medium text-gray-700">
                Mô tả
              </label>
              <textarea
                id="description"
                v-model="form.description"
                rows="3"
                class="input-field"
                placeholder="Nhập mô tả danh mục"
              ></textarea>
            </div>

            <div v-if="error" class="rounded-md bg-red-50 p-4">
              <div class="text-sm text-red-700">
                {{ error }}
              </div>
            </div>

            <div class="flex gap-3 pt-4">
              <button type="button" @click="closeModal" class="flex-1 btn-secondary">Hủy</button>
              <button type="submit" :disabled="submitting" class="flex-1 btn-primary">
                {{ submitting ? 'Đang lưu...' : editingCategory ? 'Cập nhật' : 'Tạo mới' }}
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa danh mục</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa danh mục "{{ categoryToDelete?.name }}"? Hành động này không
              thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteCategory" :disabled="deleting" class="flex-1 btn-danger">
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
import { categoriesAPI } from '../../services/api'

// Data
const categories = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingCategory = ref(null)
const categoryToDelete = ref(null)
const error = ref('')

const form = reactive({
  name: '',
  description: '',
})

// Methods
const loadCategories = async () => {
  loading.value = true
  try {
    const response = await categoriesAPI.getAll()
    categories.value = response.data
  } catch (error) {
    console.error('Error loading categories:', error)
  } finally {
    loading.value = false
  }
}

const openCreateModal = () => {
  editingCategory.value = null
  form.name = ''
  form.description = ''
  error.value = ''
  showModal.value = true
}

const openEditModal = (category) => {
  editingCategory.value = category
  form.name = category.name
  form.description = category.description || ''
  error.value = ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingCategory.value = null
  error.value = ''
}

const handleSubmit = async () => {
  error.value = ''
  submitting.value = true

  try {
    const data = {
      name: form.name,
      description: form.description,
    }

    if (editingCategory.value) {
      const response = await categoriesAPI.update(editingCategory.value.id, data)
      const index = categories.value.findIndex((c) => c.id === editingCategory.value.id)
      if (index !== -1) {
        categories.value[index] = response.data.data
      }
    } else {
      const response = await categoriesAPI.create(data)
      categories.value.push(response.data.data)
    }

    closeModal()
  } catch (err) {
    console.error('Error saving category:', err)
    error.value = err.response?.data?.error || 'Có lỗi xảy ra khi lưu danh mục'
  } finally {
    submitting.value = false
  }
}

const confirmDelete = (category) => {
  categoryToDelete.value = category
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  categoryToDelete.value = null
}

const deleteCategory = async () => {
  if (!categoryToDelete.value) return

  deleting.value = true
  try {
    await categoriesAPI.delete(categoryToDelete.value.id)
    categories.value = categories.value.filter((c) => c.id !== categoryToDelete.value.id)
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting category:', error)
    alert('Có lỗi xảy ra khi xóa danh mục')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadCategories()
})
</script>
