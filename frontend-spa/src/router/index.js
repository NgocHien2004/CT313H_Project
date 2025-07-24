import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

// Import components
import Login from '../views/auth/Login.vue'
import Register from '../views/auth/Register.vue'
import Dashboard from '../views/Dashboard.vue'
import DishList from '../views/dishes/DishList.vue'
import DishForm from '../views/dishes/DishForm.vue'
import CategoryList from '../views/categories/CategoryList.vue'
import OrderList from '../views/orders/OrderList.vue'
import OrderForm from '../views/orders/OrderForm.vue'
import UserList from '../views/users/UserList.vue'
import InventoryList from '../views/inventory/InventoryList.vue'
import ReservationList from '../views/reservations/ReservationList.vue'
import DishIngredientList from '../views/dish-ingredients/DishIngredientList.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresGuest: true },
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    meta: { requiresGuest: true },
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true },
  },
  {
    path: '/dishes',
    name: 'DishList',
    component: DishList,
    meta: { requiresAuth: true },
  },
  {
    path: '/dishes/create',
    name: 'DishCreate',
    component: DishForm,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/dishes/:id/edit',
    name: 'DishEdit',
    component: DishForm,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/categories',
    name: 'CategoryList',
    component: CategoryList,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/orders',
    name: 'OrderList',
    component: OrderList,
    meta: { requiresAuth: true },
  },
  {
    path: '/orders/create',
    name: 'OrderCreate',
    component: OrderForm,
    meta: { requiresAuth: true },
  },
  {
    path: '/users',
    name: 'UserList',
    component: UserList,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/inventory',
    name: 'InventoryList',
    component: InventoryList,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
  {
    path: '/reservations',
    name: 'ReservationList',
    component: ReservationList,
    meta: { requiresAuth: true },
  },
  {
    path: '/dish-ingredients',
    name: 'DishIngredientList',
    component: DishIngredientList,
    meta: { requiresAuth: true, requiresAdmin: true },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation guards
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.requiresGuest && authStore.isAuthenticated) {
    next('/dashboard')
  } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
