<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <router-link to="/" class="flex items-center space-x-2">
              <span class="text-2xl">🗺️</span>
              <span class="text-xl font-bold text-primary-600">親子遊玩地圖</span>
            </router-link>
          </div>

          <div class="flex items-center space-x-4">
            <router-link
              to="/"
              class="text-gray-600 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              :class="{ 'text-primary-600 bg-primary-50': $route.path === '/' }"
            >
              地圖探索
            </router-link>
            <router-link
              to="/planner"
              class="text-gray-600 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              :class="{ 'text-primary-600 bg-primary-50': $route.path === '/planner' }"
            >
              行程規劃
            </router-link>
            <router-link
              to="/my-trips"
              class="text-gray-600 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              :class="{ 'text-primary-600 bg-primary-50': $route.path === '/my-trips' }"
            >
              我的行程
            </router-link>
            <router-link
              to="/admin"
              class="text-gray-600 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              :class="{ 'text-primary-600 bg-primary-50': $route.path === '/admin' }"
            >
              後台管理
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <main>
      <router-view />
    </main>
  </div>
</template>

<script setup>
</script>
