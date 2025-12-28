<template>
  <nav class="sticky top-0 z-50 bg-zen-bg-light/80 dark:bg-zen-bg-dark/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-800 transition-colors duration-300">
    <div class="container mx-auto px-4 h-16 flex items-center justify-between">
      <router-link to="/" class="text-2xl font-serif font-bold text-zen-text-light dark:text-zen-text-dark tracking-wide">
        Lazarus<span class="text-zen-accent-light dark:text-zen-accent-dark">Blog</span>
      </router-link>

      <div class="flex items-center gap-6">
        <router-link to="/" class="hidden md:block text-sm font-medium hover:text-zen-accent-light dark:hover:text-zen-accent-dark transition-colors">Home</router-link>
        
        <!-- Login / Dashboard Toggle -->
        <router-link v-if="!isAdmin" to="/admin" class="hidden md:block text-sm font-medium hover:text-zen-accent-light dark:hover:text-zen-accent-dark transition-colors">Login</router-link>
        <router-link v-if="isAdmin" to="/admin" class="hidden md:block text-sm font-medium hover:text-zen-accent-light dark:hover:text-zen-accent-dark transition-colors">Dashboard</router-link>
        
        <button @click="toggleTheme" class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors" aria-label="Toggle Theme">
          <component :is="isDark ? SunIcon : MoonIcon" class="w-5 h-5" />
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Sun, Moon } from 'lucide-vue-next'

const SunIcon = Sun
const MoonIcon = Moon
const isDark = ref(false)
const isAdmin = ref(false)

function toggleTheme() {
  isDark.value = !isDark.value
  if (isDark.value) {
    document.documentElement.classList.add('dark')
    localStorage.setItem('theme', 'dark')
  } else {
    document.documentElement.classList.remove('dark')
    localStorage.setItem('theme', 'light')
  }
}

onMounted(() => {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    isDark.value = true
    document.documentElement.classList.add('dark')
  }

  // Check Admin
  if (localStorage.getItem('admin_session')) {
    isAdmin.value = true
  }
})
</script>
