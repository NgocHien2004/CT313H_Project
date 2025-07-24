<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Header -->
      <div class="md:flex md:items-center md:justify-between">
        <div class="flex-1 min-w-0">
          <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
            Quản lý người dùng
          </h2>
        </div>
        <div class="mt-4 flex md:mt-0 md:ml-4">
          <button @click="openCreateModal" class="btn-primary">Thêm người dùng mới</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-500"
        ></div>
        <p class="mt-2 text-sm text-gray-500">Đang tải...</p>
      </div>

      <!-- Users Table -->
      <div v-else class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Tên
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Email
                </th>
                <th
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Vai trò
                </th>
                <th
                  class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  Hành động
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ user.name }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ user.email }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    :class="[
                      'px-2 inline-flex text-xs leading-5 font-semibold rounded-full',
                      user.role === 'admin'
                        ? 'bg-purple-100 text-purple-800'
                        : 'bg-green-100 text-green-800',
                    ]"
                  >
                    {{ user.role === 'admin' ? 'Quản trị viên' : 'Nhân viên' }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex justify-end space-x-2">
                    <button
                      @click="openEditModal(user)"
                      class="text-primary-600 hover:text-primary-500"
                    >
                      Sửa
                    </button>
                    <button @click="confirmDelete(user)" class="text-red-600 hover:text-red-500">
                      Xóa
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty State -->
        <div v-if="users.length === 0" class="text-center py-12">
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
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có người dùng nào</h3>
          <p class="mt-1 text-sm text-gray-500">Bắt đầu bằng cách tạo người dùng mới.</p>
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
            {{ editingUser ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới' }}
          </h3>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700">
                Tên <span class="text-red-500">*</span>
              </label>
              <input
                id="name"
                v-model="form.name"
                type="text"
                required
                class="input-field"
                placeholder="Nhập tên"
              />
            </div>

            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">
                Email <span class="text-red-500">*</span>
              </label>
              <input
                id="email"
                v-model="form.email"
                type="email"
                required
                class="input-field"
                placeholder="Nhập email"
              />
            </div>

            <div v-if="!editingUser">
              <label for="password" class="block text-sm font-medium text-gray-700">
                Mật khẩu <span class="text-red-500">*</span>
              </label>
              <input
                id="password"
                v-model="form.password"
                type="password"
                :required="!editingUser"
                minlength="6"
                class="input-field"
                placeholder="Nhập mật khẩu"
              />
            </div>

            <div>
              <label for="role" class="block text-sm font-medium text-gray-700">
                Vai trò <span class="text-red-500">*</span>
              </label>
              <select id="role" v-model="form.role" required class="input-field">
                <option value="">Chọn vai trò</option>
                <option value="user">Nhân viên</option>
                <option value="admin">Quản trị viên</option>
              </select>
            </div>

            <div v-if="error" class="rounded-md bg-red-50 p-4">
              <div class="text-sm text-red-700">
                {{ error }}
              </div>
            </div>

            <div class="flex gap-3 pt-4">
              <button type="button" @click="closeModal" class="flex-1 btn-secondary">Hủy</button>
              <button type="submit" :disabled="submitting" class="flex-1 btn-primary">
                {{ submitting ? 'Đang lưu...' : editingUser ? 'Cập nhật' : 'Tạo mới' }}
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
          <h3 class="text-lg font-medium text-gray-900 mt-2">Xóa người dùng</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500">
              Bạn có chắc chắn muốn xóa người dùng "{{ userToDelete?.name }}"? Hành động này không
              thể hoàn tác.
            </p>
          </div>
          <div class="flex gap-4 mt-4">
            <button @click="closeDeleteModal" class="flex-1 btn-secondary">Hủy</button>
            <button @click="deleteUser" :disabled="deleting" class="flex-1 btn-danger">
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
import { usersAPI } from '../../services/api'

// Data
const users = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingUser = ref(null)
const userToDelete = ref(null)
const error = ref('')

const form = reactive({
  name: '',
  email: '',
  password: '',
  role: '',
})

// Methods
const loadUsers = async () => {
  loading.value = true
  try {
    const response = await usersAPI.getAll({ limit: 100 })
    users.value = response.data.data || []
  } catch (error) {
    console.error('Error loading users:', error)
  } finally {
    loading.value = false
  }
}

const openCreateModal = () => {
  editingUser.value = null
  Object.assign(form, {
    name: '',
    email: '',
    password: '',
    role: '',
  })
  error.value = ''
  showModal.value = true
}

const openEditModal = (user) => {
  editingUser.value = user
  Object.assign(form, {
    name: user.name,
    email: user.email,
    password: '',
    role: user.role,
  })
  error.value = ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingUser.value = null
  error.value = ''
}

const handleSubmit = async () => {
  error.value = ''
  submitting.value = true

  try {
    const data = {
      name: form.name,
      email: form.email,
      role: form.role,
    }

    if (!editingUser.value) {
      data.password = form.password
    }

    if (editingUser.value) {
      const response = await usersAPI.update(editingUser.value.id, data)
      const index = users.value.findIndex((u) => u.id === editingUser.value.id)
      if (index !== -1) {
        users.value[index] = response.data.data
      }
    } else {
      const response = await usersAPI.create(data)
      users.value.push(response.data.data)
    }

    closeModal()
  } catch (err) {
    console.error('Error saving user:', err)
    error.value = err.response?.data?.error || 'Có lỗi xảy ra khi lưu người dùng'
  } finally {
    submitting.value = false
  }
}

const confirmDelete = (user) => {
  userToDelete.value = user
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  userToDelete.value = null
}

const deleteUser = async () => {
  if (!userToDelete.value) return

  deleting.value = true
  try {
    await usersAPI.delete(userToDelete.value.id)
    users.value = users.value.filter((u) => u.id !== userToDelete.value.id)
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting user:', error)
    alert('Có lỗi xảy ra khi xóa người dùng')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadUsers()
})
</script>
