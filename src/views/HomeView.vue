<template>
  <div class="min-h-screen pb-20">
    <!-- Hero Section -->
    <header class="py-16 md:py-32 text-center px-4 animate-fade-in-down">
      <h1 class="text-5xl md:text-8xl font-serif font-bold mb-4 md:mb-6 text-zen-text-light dark:text-zen-text-dark tracking-tight leading-tight">
        Lazarus<span class="italic font-light text-zen-accent-light dark:text-zen-accent-dark">Blog</span>
      </h1>
      <p class="text-base md:text-xl text-gray-500 dark:text-gray-400 max-w-xl mx-auto font-light leading-relaxed px-4 animate-fade-in-delayed">
        Curated thoughts on technology, design, and the art of clarity.
      </p>
    </header>

    <!-- Filters & Search -->
    <div class="container mx-auto px-4 mb-12 md:mb-20 animate-fade-in-up-delayed">
      <div class="flex flex-col items-center gap-6 md:gap-8">
        
        <!-- Search -->
        <div class="relative w-full max-w-lg group px-2 md:px-0">
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Search for clarity..." 
            class="w-full pl-6 pr-12 py-3 md:py-4 rounded-full bg-white dark:bg-zinc-900 border border-gray-100 dark:border-zinc-800 shadow-sm focus:shadow-lg focus:border-zen-accent-light dark:focus:border-zen-accent-dark focus:ring-0 transition-all text-sm md:text-base text-center placeholder-gray-400"
          />
          <div class="absolute right-6 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-zen-accent-light dark:group-focus-within:text-zen-accent-dark transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>

        <!-- Categories (Responsive Scroll) -->
        <div class="relative w-full max-w-4xl group">
          <!-- Gradient Masks -->
          <div class="absolute left-0 top-0 bottom-0 w-8 md:w-16 bg-gradient-to-r from-zen-bg-light dark:from-zen-bg-dark to-transparent z-10 pointer-events-none"></div>
          <div class="absolute right-0 top-0 bottom-0 w-8 md:w-16 bg-gradient-to-l from-zen-bg-light dark:from-zen-bg-dark to-transparent z-10 pointer-events-none"></div>

          <div class="flex gap-2 md:gap-3 overflow-x-auto pb-4 pt-1 w-full scrollbar-hide px-8 md:px-16 snap-x">
            <button 
              v-for="cat in categories" 
              :key="cat"
              @click="selectedCategory = cat"
              :class="[
                'snap-center px-4 md:px-6 py-2 md:py-2.5 rounded-full text-xs md:text-sm font-medium transition-all duration-300 whitespace-nowrap border flex-shrink-0',
                selectedCategory === cat 
                  ? 'bg-black dark:bg-white text-white dark:text-black border-transparent shadow-lg scale-105' 
                  : 'bg-transparent border-gray-200 dark:border-zinc-800 text-gray-500 dark:text-gray-400 hover:border-zen-accent-light dark:hover:border-zen-accent-dark hover:text-zen-accent-light dark:hover:text-zen-accent-dark'
              ]"
            >
              {{ cat }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Article Grid -->
    <div class="container mx-auto px-4">
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div v-for="n in 6" :key="n" class="animate-pulse">
           <div class="h-48 bg-gray-200 dark:bg-gray-800 rounded-xl mb-4"></div>
           <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded w-1/3 mb-2"></div>
           <div class="h-6 bg-gray-200 dark:bg-gray-800 rounded w-3/4 mb-4"></div>
           <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded w-full"></div>
        </div>
      </div>

      <div v-else-if="filteredArticles.length === 0" class="text-center py-20 text-gray-500 animate-fade-in">
        <p>No articles found matching your criteria.</p>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <ArticleCard 
          v-for="(article, index) in filteredArticles" 
          :key="article.id" 
          :article="article"
          class="animate-fade-in-up opacity-0"
          :style="{ animationDelay: `${index * 100}ms` }"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import ArticleCard from '../components/article/ArticleCard.vue'

const articles = ref([])
const loading = ref(true)
const searchQuery = ref('')
const selectedCategory = ref('All')

// Mock categories for now, ideally fetch distinct categories or a fixed list
const categories = [
  'All', 
  'Technology', 'Life & Story', 'Poetry', 'Philosophy', 
  'Design', 'Travel', 'Ideas', 'Tutorial',
  'Politics', 'Language', 'Culture', 'Science', 
  'Business', 'Health', 'History', 'Art'
]

async function fetchArticles() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('articles')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) console.error(error)
    else articles.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const filteredArticles = computed(() => {
  return articles.value.filter(article => {
    const matchesSearch = article.title.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
                          article.content.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesCategory = selectedCategory.value === 'All' || article.category === selectedCategory.value
    return matchesSearch && matchesCategory
  })
})

onMounted(() => {
  fetchArticles()
})
</script>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
    display: none;
}
</style>
