<template>
  <div class="min-h-screen bg-surface">
    <!-- 導航欄 -->
    <nav class="sticky top-0 z-50 bg-white/95 backdrop-blur-sm border-b border-neutral-200/60">
      <div class="max-w-7xl mx-auto px-4 sm:px-6">
        <div class="flex justify-between h-14">
          <!-- Logo -->
          <div class="flex items-center">
            <router-link to="/" class="flex items-center gap-2.5 group">
              <div class="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center">
                <Map class="w-4.5 h-4.5 text-white" />
              </div>
              <span class="text-base font-semibold text-neutral-800 group-hover:text-primary-600 transition-colors">
                親子地圖
              </span>
            </router-link>
          </div>

          <!-- 導航連結 -->
          <div class="flex items-center gap-1">
            <router-link
              to="/"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/' }"
            >
              <Compass class="w-4 h-4" />
              <span>探索</span>
            </router-link>
            <router-link
              to="/planner"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/planner' }"
            >
              <Calendar class="w-4 h-4" />
              <span>規劃</span>
            </router-link>
            <router-link
              to="/my-trips"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/my-trips' }"
            >
              <Heart class="w-4 h-4" />
              <span>收藏</span>
            </router-link>
            <router-link
              to="/admin"
              class="nav-link"
              :class="{ 'nav-link-active': $route.path === '/admin' }"
            >
              <Settings class="w-4 h-4" />
              <span>管理</span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <!-- 主要內容區 -->
    <main>
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<script setup>
import { Map, Compass, Calendar, Heart, Settings } from 'lucide-vue-next'
</script>

<style scoped>
.nav-link {
  @apply flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium text-neutral-500
         hover:text-neutral-700 hover:bg-neutral-100 transition-all duration-200;
}

.nav-link-active {
  @apply text-primary-600 bg-primary-50;
}
</style>
