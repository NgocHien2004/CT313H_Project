<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
    <!-- Navigation -->
    <nav
      class="bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 shadow-xl border-b border-indigo-200/20"
    >
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center space-x-8">
            <!-- Logo với icon -->
            <div class="flex-shrink-0 flex items-center space-x-3">
              <div
                class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center backdrop-blur-sm"
              >
                <svg
                  class="w-5 h-5 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
                  />
                </svg>
              </div>
              <div>
                <h1 class="text-lg font-bold text-white drop-shadow-sm">Restaurant Manager</h1>
                <p class="text-xs text-white text-opacity-80 font-medium">
                  Quản lý nhà hàng thông minh
                </p>
              </div>
            </div>

            <!-- Navigation Links -->
            <div class="hidden lg:flex lg:space-x-1">
              <router-link
                to="/dashboard"
                class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                :class="{
                  'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/dashboard',
                }"
              >
                <span class="flex items-center space-x-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"
                    />
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="m8 7l4-4l4 4"
                    />
                  </svg>
                  <span>Dashboard</span>
                </span>
              </router-link>

              <router-link
                to="/dishes"
                class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                :class="{
                  'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/dishes',
                }"
              >
                <span class="flex items-center space-x-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"
                    />
                  </svg>
                  <span>Món ăn</span>
                </span>
              </router-link>

              <router-link
                to="/orders"
                class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                :class="{
                  'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/orders',
                }"
              >
                <span class="flex items-center space-x-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                    />
                  </svg>
                  <span>Đơn hàng</span>
                </span>
              </router-link>

              <router-link
                to="/reservations"
                class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                :class="{
                  'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/reservations',
                }"
              >
                <span class="flex items-center space-x-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                    />
                  </svg>
                  <span>Đặt bàn</span>
                </span>
              </router-link>

              <!-- Admin only links -->
              <template v-if="authStore && authStore.isAdmin">
                <router-link
                  to="/categories"
                  class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                  :class="{
                    'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/categories',
                  }"
                >
                  <span class="flex items-center space-x-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                      />
                    </svg>
                    <span>Danh mục</span>
                  </span>
                </router-link>

                <router-link
                  to="/inventory"
                  class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                  :class="{
                    'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/inventory',
                  }"
                >
                  <span class="flex items-center space-x-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                      />
                    </svg>
                    <span>Kho hàng</span>
                  </span>
                </router-link>

                <router-link
                  to="/users"
                  class="group relative px-3 py-2 text-sm font-medium text-white text-opacity-90 hover:text-white transition-all duration-200 rounded-lg hover:bg-white hover:bg-opacity-10 backdrop-blur-sm whitespace-nowrap"
                  :class="{
                    'bg-white bg-opacity-20 text-white shadow-lg': $route.path === '/users',
                  }"
                >
                  <span class="flex items-center space-x-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"
                      />
                    </svg>
                    <span>Người dùng</span>
                  </span>
                </router-link>
              </template>
            </div>
          </div>

          <!-- Right side -->
          <div class="flex items-center space-x-4">
            <!-- User dropdown -->
            <div class="relative">
              <button
                @click.stop="showUserMenu = !showUserMenu"
                class="flex items-center space-x-2 bg-white bg-opacity-10 hover:bg-white hover:bg-opacity-20 backdrop-blur-sm rounded-lg px-3 py-2 transition-all duration-200 border border-white border-opacity-20"
              >
                <div
                  class="w-6 h-6 bg-white bg-opacity-20 rounded-full flex items-center justify-center"
                >
                  <svg
                    class="w-3 h-3 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                    />
                  </svg>
                </div>
                <div class="text-left hidden md:block">
                  <p class="text-sm font-medium text-white">
                    {{ (authStore && authStore.user && authStore.user.name) || 'User' }}
                  </p>
                </div>
                <svg
                  class="w-3 h-3 text-white text-opacity-70"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>

              <!-- User dropdown menu -->
              <transition
                enter-active-class="transition ease-out duration-100"
                enter-from-class="transform opacity-0 scale-95"
                enter-to-class="transform opacity-100 scale-100"
                leave-active-class="transition ease-in duration-75"
                leave-from-class="transform opacity-100 scale-100"
                leave-to-class="transform opacity-0 scale-95"
              >
                <div
                  v-if="showUserMenu"
                  class="absolute right-0 mt-2 w-48 bg-white bg-opacity-95 backdrop-blur-md rounded-xl shadow-xl border border-white border-opacity-20 z-50"
                >
                  <button
                    @click="logout"
                    class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
                  >
                    Đăng xuất
                  </button>
                </div>
              </transition>
            </div>

            <!-- Mobile menu button -->
            <button
              @click.stop="toggleMobileMenu"
              class="lg:hidden p-2 text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors"
              aria-label="Toggle menu"
            >
              <svg
                v-if="!showMobileMenu"
                class="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
              <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>

        <!-- Mobile Navigation -->
        <transition
          enter-active-class="transition ease-out duration-200"
          enter-from-class="opacity-0 -translate-y-2"
          enter-to-class="opacity-100 translate-y-0"
          leave-active-class="transition ease-in duration-150"
          leave-from-class="opacity-100 translate-y-0"
          leave-to-class="opacity-0 -translate-y-2"
        >
          <div
            v-if="showMobileMenu"
            class="lg:hidden pb-4 border-t border-white border-opacity-20 mt-4"
            @click.stop
          >
            <div class="space-y-1 pt-4">
              <router-link
                to="/dashboard"
                class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/dashboard' }"
                @click="showMobileMenu = false"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="m8 7l4-4l4 4"
                  />
                </svg>
                <span>Dashboard</span>
              </router-link>
              <router-link
                to="/dishes"
                class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/dishes' }"
                @click="showMobileMenu = false"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"
                  />
                </svg>
                <span>Món ăn</span>
              </router-link>
              <router-link
                to="/orders"
                class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/orders' }"
                @click="showMobileMenu = false"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <span>Đơn hàng</span>
              </router-link>
              <router-link
                to="/reservations"
                class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/reservations' }"
                @click="showMobileMenu = false"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
                <span>Đặt bàn</span>
              </router-link>

              <template v-if="authStore && authStore.isAdmin">
                <router-link
                  to="/categories"
                  class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                  :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/categories' }"
                  @click="showMobileMenu = false"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                    />
                  </svg>
                  <span>Danh mục</span>
                </router-link>
                <router-link
                  to="/inventory"
                  class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                  :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/inventory' }"
                  @click="showMobileMenu = false"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                    />
                  </svg>
                  <span>Kho hàng</span>
                </router-link>
                <router-link
                  to="/users"
                  class="block px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                  :class="{ 'bg-white bg-opacity-20 text-white': $route.path === '/users' }"
                  @click="showMobileMenu = false"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"
                    />
                  </svg>
                  <span>Người dùng</span>
                </router-link>
              </template>

              <!-- Mobile User Actions -->
              <div class="border-t border-white border-opacity-20 pt-4 mt-4">
                <div class="px-4 py-2 text-white text-opacity-80 text-sm">
                  {{ (authStore && authStore.user && authStore.user.name) || 'User' }}
                </div>
                <button
                  @click="logout"
                  class="block w-full text-left px-4 py-3 text-white text-opacity-90 hover:text-white hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors font-medium flex items-center space-x-2"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                    />
                  </svg>
                  <span>Đăng xuất</span>
                </button>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-1">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <slot />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter, useRoute } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()
const $route = useRoute()

const showUserMenu = ref(false)
const showMobileMenu = ref(false)

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
}

const logout = async () => {
  try {
    if (authStore && typeof authStore.logout === 'function') {
      await authStore.logout()
    }
    showUserMenu.value = false
    showMobileMenu.value = false
    router.push('/login')
  } catch (error) {
    console.error('Logout error:', error)
    router.push('/login')
  }
}

// Close dropdowns when clicking outside
const handleClickOutside = (event) => {
  // Handle user dropdown
  const userDropdownContainer = event.target.closest('.relative')
  if (!userDropdownContainer) {
    showUserMenu.value = false
  }

  // Handle mobile menu - only close if clicking outside of nav entirely
  const navContainer = event.target.closest('nav')
  if (!navContainer) {
    showMobileMenu.value = false
  }
}

// Close mobile menu on route change
const closeMobileMenuOnRoute = () => {
  showMobileMenu.value = false
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  // Listen for route changes to close mobile menu
  router.afterEach(closeMobileMenuOnRoute)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

// Expose reactive properties for debugging
if (import.meta.env.DEV) {
  window.appLayoutDebug = {
    showUserMenu,
    showMobileMenu,
    authStore,
    route: $route,
  }
}
</script>

<style scoped>
/* Ensure compatibility with older browsers */
.backdrop-blur-sm {
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

.backdrop-blur-md {
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

/* Fallback for browsers that don't support backdrop-filter */
@supports not (backdrop-filter: blur(4px)) {
  .backdrop-blur-sm {
    background-color: rgba(255, 255, 255, 0.8);
  }

  .backdrop-blur-md {
    background-color: rgba(255, 255, 255, 0.9);
  }
}

/* Custom scrollbar for better compatibility */
.overflow-y-auto::-webkit-scrollbar {
  width: 4px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 2px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}

/* Ensure navigation is always visible */
nav {
  position: relative;
  z-index: 1000;
}

/* Force hardware acceleration for smooth animations */
.transition-all,
.transition-colors {
  transform: translateZ(0);
  -webkit-transform: translateZ(0);
}

/* Ensure text is always visible */
.text-white {
  color: white !important;
}

.text-white.text-opacity-90 {
  color: rgba(255, 255, 255, 0.9) !important;
}

.text-white.text-opacity-80 {
  color: rgba(255, 255, 255, 0.8) !important;
}

/* Debug styles for development */
.debug-nav-links {
  border: 2px solid red !important;
}

/* Ensure navigation links are always clickable */
.lg\\:flex {
  display: flex !important;
}

@media (max-width: 1023px) {
  .lg\\:hidden {
    display: block !important;
  }

  .lg\\:flex {
    display: none !important;
  }
}

@media (min-width: 1024px) {
  .lg\\:flex {
    display: flex !important;
  }

  .lg\\:hidden {
    display: none !important;
  }
}
</style>
