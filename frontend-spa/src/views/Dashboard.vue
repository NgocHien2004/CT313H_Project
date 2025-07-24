<template>
  <AppLayout>
    <div class="space-y-6">
      <!-- Welcome Section -->
      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">
            Chào mừng, {{ authStore.user?.email }}!
          </h3>
          <div class="mt-2 max-w-xl text-sm text-gray-500">
            <p>
              Hệ thống quản lý nhà hàng - Vai trò:
              {{ authStore.user?.role === 'admin' ? 'Quản trị viên' : 'Nhân viên' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Total Dishes -->
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-primary-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"
                    ></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Tổng món ăn</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    {{ stats.totalDishes }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Total Orders -->
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M10 2L3 7v11a1 1 0 001 1h12a1 1 0 001-1V7l-7-5z"
                      clip-rule="evenodd"
                    ></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Tổng đơn hàng</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    {{ stats.totalOrders }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Total Reservations -->
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                      clip-rule="evenodd"
                    ></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Đặt bàn hôm nay</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    {{ stats.todayReservations }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Total Users (Admin only) -->
        <div v-if="authStore.isAdmin" class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"
                    ></path>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Tổng người dùng</dt>
                  <dd class="text-lg font-medium text-gray-900">
                    {{ stats.totalUsers }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Hành động nhanh</h3>

          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <router-link
              to="/orders/create"
              class="relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-primary-500 rounded-lg border border-gray-200 hover:border-primary-300 transition-colors"
            >
              <div>
                <span
                  class="rounded-lg inline-flex p-3 bg-primary-50 text-primary-600 group-hover:bg-primary-100"
                >
                  <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                    ></path>
                  </svg>
                </span>
              </div>
              <div class="mt-8">
                <h3 class="text-lg font-medium">
                  <span class="absolute inset-0" aria-hidden="true"></span>
                  Tạo đơn hàng mới
                </h3>
                <p class="mt-2 text-sm text-gray-500">Tạo đơn hàng cho khách hàng</p>
              </div>
            </router-link>

            <router-link
              to="/reservations"
              class="relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-primary-500 rounded-lg border border-gray-200 hover:border-primary-300 transition-colors"
            >
              <div>
                <span
                  class="rounded-lg inline-flex p-3 bg-green-50 text-green-600 group-hover:bg-green-100"
                >
                  <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                    ></path>
                  </svg>
                </span>
              </div>
              <div class="mt-8">
                <h3 class="text-lg font-medium">
                  <span class="absolute inset-0" aria-hidden="true"></span>
                  Quản lý đặt bàn
                </h3>
                <p class="mt-2 text-sm text-gray-500">Xem và quản lý đặt bàn</p>
              </div>
            </router-link>

            <router-link
              v-if="authStore.isAdmin"
              to="/dishes/create"
              class="relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-primary-500 rounded-lg border border-gray-200 hover:border-primary-300 transition-colors"
            >
              <div>
                <span
                  class="rounded-lg inline-flex p-3 bg-yellow-50 text-yellow-600 group-hover:bg-yellow-100"
                >
                  <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                    ></path>
                  </svg>
                </span>
              </div>
              <div class="mt-8">
                <h3 class="text-lg font-medium">
                  <span class="absolute inset-0" aria-hidden="true"></span>
                  Thêm món ăn mới
                </h3>
                <p class="mt-2 text-sm text-gray-500">Tạo món ăn mới cho thực đơn</p>
              </div>
            </router-link>

            <router-link
              v-if="authStore.isAdmin"
              to="/inventory"
              class="relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-primary-500 rounded-lg border border-gray-200 hover:border-primary-300 transition-colors"
            >
              <div>
                <span
                  class="rounded-lg inline-flex p-3 bg-purple-50 text-purple-600 group-hover:bg-purple-100"
                >
                  <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                    ></path>
                  </svg>
                </span>
              </div>
              <div class="mt-8">
                <h3 class="text-lg font-medium">
                  <span class="absolute inset-0" aria-hidden="true"></span>
                  Quản lý kho hàng
                </h3>
                <p class="mt-2 text-sm text-gray-500">Kiểm tra và cập nhật kho</p>
              </div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import AppLayout from '../components/layout/AppLayout.vue'
import { dishesAPI, ordersAPI, reservationsAPI, usersAPI } from '../services/api'

const authStore = useAuthStore()

const stats = ref({
  totalDishes: 0,
  totalOrders: 0,
  todayReservations: 0,
  totalUsers: 0,
})

const loadStats = async () => {
  try {
    // Load dishes count
    const dishesResponse = await dishesAPI.getAll({ limit: 1 })
    stats.value.totalDishes = dishesResponse.data.total || 0

    // Load orders count
    const ordersResponse = await ordersAPI.getAll({ limit: 1 })
    stats.value.totalOrders = ordersResponse.data.data?.length || 0

    // Load reservations count
    const reservationsResponse = await reservationsAPI.getAll({ limit: 1 })
    stats.value.todayReservations = reservationsResponse.data.data?.length || 0

    // Load users count (admin only)
    if (authStore.isAdmin) {
      const usersResponse = await usersAPI.getAll({ limit: 1 })
      stats.value.totalUsers = usersResponse.data.data?.length || 0
    }
  } catch (error) {
    console.error('Error loading stats:', error)
  }
}

onMounted(() => {
  loadStats()
})
</script>
