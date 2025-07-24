<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Navigation -->
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <!-- Logo -->
            <div class="flex-shrink-0 flex items-center">
              <h1 class="text-xl font-bold text-gray-900">Restaurant Manager</h1>
            </div>

            <!-- Navigation Links -->
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <router-link
                to="/dashboard"
                class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                active-class="border-primary-500 text-gray-900"
              >
                Dashboard
              </router-link>

              <router-link
                to="/dishes"
                class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                active-class="border-primary-500 text-gray-900"
              >
                Món ăn
              </router-link>

              <router-link
                to="/orders"
                class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                active-class="border-primary-500 text-gray-900"
              >
                Đơn hàng
              </router-link>

              <router-link
                to="/reservations"
                class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                active-class="border-primary-500 text-gray-900"
              >
                Đặt bàn
              </router-link>

              <!-- Admin only links -->
              <template v-if="authStore.isAdmin">
                <router-link
                  to="/categories"
                  class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                  active-class="border-primary-500 text-gray-900"
                >
                  Danh mục
                </router-link>

                <router-link
                  to="/inventory"
                  class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                  active-class="border-primary-500 text-gray-900"
                >
                  Kho hàng
                </router-link>

                <router-link
                  to="/users"
                  class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                  active-class="border-primary-500 text-gray-900"
                >
                  Người dùng
                </router-link>
              </template>
            </div>
          </div>

          <!-- User menu -->
          <div class="flex items-center">
            <div class="relative">
              <button
                @click="showUserMenu = !showUserMenu"
                class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                id="user-menu-button"
              >
                <span class="sr-only">Open user menu</span>
                <div class="h-8 w-8 rounded-full bg-primary-500 flex items-center justify-center">
                  <span class="text-sm font-medium text-white">
                    {{ authStore.user?.email?.[0]?.toUpperCase() }}
                  </span>
                </div>
              </button>

              <!-- Dropdown menu -->
              <div
                v-show="showUserMenu"
                class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none z-50"
                @click="showUserMenu = false"
              >
                <div class="px-4 py-2 text-sm text-gray-700 border-b">
                  {{ authStore.user?.email }}
                  <div class="text-xs text-gray-500">{{ authStore.user?.role }}</div>
                </div>
                <button
                  @click="logout"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Đăng xuất
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Mobile menu -->
    <div class="sm:hidden" v-show="showMobileMenu">
      <div class="pt-2 pb-3 space-y-1">
        <!-- Mobile navigation links -->
      </div>
    </div>

    <!-- Page content -->
    <main class="py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <slot />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const showUserMenu = ref(false)
const showMobileMenu = ref(false)

const logout = () => {
  authStore.logout()
  router.push('/login')
}

// Close dropdowns when clicking outside
const handleClickOutside = (event) => {
  if (!event.target.closest('#user-menu-button')) {
    showUserMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
