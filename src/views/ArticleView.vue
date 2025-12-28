<template>
  <div class="relative min-h-screen">
    <!-- Floating Back Button -->
    <button 
      @click="goBack"
      class="fixed top-20 left-4 md:left-8 z-40 p-3 rounded-full bg-white/70 dark:bg-black/50 backdrop-blur-md border border-gray-200 dark:border-zinc-700 shadow-sm hover:shadow-md hover:bg-white dark:hover:bg-zinc-900 transition-all group"
      aria-label="Go Back"
    >
      <component :is="ArrowLeftIcon" class="w-5 h-5 text-gray-700 dark:text-gray-200 group-hover:-translate-x-1 transition-transform" />
    </button>

    <div v-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="animate-pulse flex flex-col items-center">
        <div class="h-8 w-64 bg-gray-200 dark:bg-zinc-800 rounded mb-4"></div>
        <div class="h-4 w-48 bg-gray-200 dark:bg-zinc-800 rounded"></div>
      </div>
    </div>

    <div v-else-if="!article" class="min-h-screen flex items-center justify-center">
      <p class="text-xl text-gray-500">Article not found.</p>
    </div>

    <div v-else class="min-h-screen pb-20 bg-white dark:bg-zinc-950 transition-colors animate-fade-in">
    <!-- Hero Image -->
    <div v-if="article.image_url" class="relative w-full h-[50vh] md:h-[70vh] overflow-hidden group">
      <!-- Image with slow zoom effect -->
      <img :src="article.image_url" class="absolute inset-0 w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" :alt="article.title" />
      
      <!-- Overlay: Always dark gradient for text legibility -->
      <div class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/40 to-transparent"></div>
      
      <!-- Content -->
      <div class="absolute inset-0 flex flex-col justify-end items-center text-center p-6 md:p-12 pb-10 md:pb-16 px-4">
        <div class="max-w-4xl mx-auto animate-fade-in-up">
            <span class="inline-block px-4 py-1.5 bg-white/10 backdrop-blur-md text-white border border-white/20 text-xs font-bold uppercase tracking-[0.2em] mb-4 md:mb-6 rounded-full">
            {{ article.category }}
            </span>
            <h1 class="text-3xl md:text-5xl lg:text-6xl font-serif font-bold text-white leading-tight mb-6 md:mb-8 drop-shadow-xl">
            {{ article.title }}
            </h1>
            <!-- Meta -->
             <div class="flex items-center justify-center gap-4 md:gap-6 text-xs md:text-sm text-white/90 font-light tracking-wide uppercase">
                <span>{{ new Date(article.created_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' }) }}</span>
                <span class="w-1 h-1 bg-white/50 rounded-full"></span>
                <span>{{ readingTime }} min read</span>
            </div>
        </div>
      </div>
    </div>
    
    <!-- Title-only Hero (if no image) -->
    <div v-else class="pt-32 pb-16 px-4 text-center max-w-4xl mx-auto">
         <span class="inline-block px-4 py-1.5 bg-gray-100 dark:bg-zinc-800 text-zen-text-light dark:text-zen-text-dark text-xs font-bold uppercase tracking-[0.2em] mb-6 rounded-full">
          {{ article.category }}
        </span>
        <h1 class="text-5xl md:text-7xl font-serif font-bold text-zen-text-light dark:text-zen-text-dark leading-tight mb-6">
          {{ article.title }}
        </h1>
        <div class="flex items-center justify-center gap-6 text-sm md:text-base text-gray-500 font-light tracking-wide">
          <span>{{ new Date(article.created_at).toLocaleDateString(undefined, { dateStyle: 'long' }) }}</span>
          <span class="w-1.5 h-1.5 bg-gray-300 rounded-full"></span>
          <span>{{ readingTime }} min read</span>
        </div>
    </div>

    <!-- Content -->
    <main class="container mx-auto px-6 md:px-0 max-w-3xl py-12">
      <article class="prose prose-lg md:prose-xl dark:prose-invert 
        prose-headings:font-serif prose-headings:font-bold prose-headings:tracking-tight 
        prose-p:font-sans prose-p:text-gray-800 dark:prose-p:text-gray-200 prose-p:leading-8 prose-p:mb-8
        prose-a:text-zen-accent-light dark:prose-a:text-zen-accent-dark prose-a:no-underline hover:prose-a:underline
        prose-img:rounded-2xl prose-img:shadow-lg prose-img:my-10 prose-img:w-full
        prose-blockquote:border-l-4 prose-blockquote:border-zen-accent-light dark:prose-blockquote:border-zen-accent-dark prose-blockquote:italic prose-blockquote:pl-6
        mx-auto text-left break-words article-content">
        <!-- Markdown Rendered Content -->
        <div v-html="renderMarkdown(article.content)" class="whitespace-pre-wrap leading-relaxed"></div>
      </article>

      <!-- Actions -->
      <div class="border-y border-gray-100 dark:border-zinc-800 py-8 my-12 flex items-center justify-between">
        <div class="flex items-center gap-4">
          <button 
            @click="handleLike" 
            :disabled="hasLiked"
            class="flex items-center gap-2 px-6 py-3 rounded-full bg-red-50 dark:bg-red-900/20 text-red-500 hover:bg-red-100 dark:hover:bg-red-900/30 transition-all active:scale-95 disabled:opacity-50"
          >
            <component :is="HeartIcon" :class="['w-5 h-5', hasLiked ? 'fill-current' : '']" />
            <span class="font-medium">{{ likeCount }} Likes</span>
          </button>
        </div>
        
        <button 
          @click="shareArticle"
          class="p-3 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-800 transition-colors text-gray-500"
        >
          <component :is="ShareIcon" class="w-5 h-5" />
        </button>
      </div>

      <!-- Recommendations -->
      <section v-if="relatedArticles.length > 0" class="mt-16">
        <h3 class="text-2xl font-serif font-bold mb-8 text-black dark:text-white">You might also like</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div v-for="related in relatedArticles" :key="related.id" class="group cursor-pointer" @click="$router.push({ name: 'article', params: { id: related.id } })">
             <div class="aspect-video bg-gray-100 dark:bg-zinc-800 rounded-lg overflow-hidden mb-3">
               <img v-if="related.image_url" :src="related.image_url" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"/>
             </div>
             <h4 class="font-serif font-bold text-lg group-hover:text-zen-accent-light transition-colors">{{ related.title }}</h4>
          </div>
        </div>
      </section>
    </main>

    <ChatAI :context="article.content" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { marked } from 'marked'
import { Heart, Share2, ArrowLeft } from 'lucide-vue-next'
import ChatAI from '../components/ai/ChatAI.vue'

// Render standard markdown with breaks enabled (respects single Enter)
function renderMarkdown(text) {
  return marked.parse(text || '', { breaks: true, gfm: true })
}

const HeartIcon = Heart
const ShareIcon = Share2
const ArrowLeftIcon = ArrowLeft

const route = useRoute()
const router = useRouter()
const article = ref(null)
const loading = ref(true)
const likeCount = ref(0)
const hasLiked = ref(false)
const relatedArticles = ref([])

const readingTime = computed(() => {
  if (!article.value?.content) return 0
  const words = article.value.content.trim().split(/\s+/).length
  return Math.ceil(words / 200)
})

async function fetchArticle() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('articles')
      .select('*')
      .eq('id', route.params.id)
      .single()
      
    if (error) throw error
    article.value = data
    
    // Fetch likes count
    const { count } = await supabase
      .from('likes')
      .select('*', { count: 'exact', head: true })
      .eq('article_id', route.params.id)
    
    likeCount.value = count || 0
    
    // Fetch related
    fetchRelated(data.category, data.id)
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function fetchRelated(category, currentId) {
  const { data } = await supabase
    .from('articles')
    .select('id, title, image_url, category')
    .eq('category', category)
    .neq('id', currentId)
    .limit(2)
  
  if (data) relatedArticles.value = data
}

async function handleLike() {
  if (hasLiked.value) return
  
  const { error } = await supabase
    .from('likes')
    .insert([{ article_id: article.value.id }])
    
  if (!error) {
    likeCount.value++
    hasLiked.value = true
    // Save to local storage to prevent simple re-liking
    localStorage.setItem(`liked_${article.value.id}`, 'true')
  }
}

async function shareArticle() {
  if (navigator.share) {
    try {
      await navigator.share({
        title: article.value.title,
        text: 'Read this amazing article on LazarusBlog',
        url: window.location.href,
      })
    } catch (err) {
      // Ignored
    }
  } else {
    navigator.clipboard.writeText(window.location.href)
    alert('Link copied to clipboard!')
  }
}

function goBack() {
  router.back()
}

watch(() => route.params.id, () => {
    // Check local storage for like
    hasLiked.value = !!localStorage.getItem(`liked_${route.params.id}`)
    fetchArticle()
})

onMounted(() => {
    hasLiked.value = !!localStorage.getItem(`liked_${route.params.id}`)
    fetchArticle()
})
</script>

<style scoped>
/* No hack needed - using standard markdown rendering */
</style>
