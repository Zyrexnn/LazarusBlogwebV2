<template>
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
    <div v-if="article.image_url" class="h-[50vh] w-full overflow-hidden relative">
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-white dark:to-zinc-950 opacity-90"></div>
      <img :src="article.image_url" class="w-full h-full object-cover" :alt="article.title" />
      
      <div class="absolute bottom-0 left-0 w-full p-6 md:p-12 max-w-4xl mx-auto">
        <span class="inline-block px-3 py-1 bg-zen-accent-light dark:bg-zen-accent-dark text-white text-xs font-bold uppercase tracking-widest mb-4 rounded-full">
          {{ article.category }}
        </span>
        <h1 class="text-4xl md:text-6xl font-serif font-bold text-zen-text-light dark:text-zen-text-dark leading-tight mb-4">
          {{ article.title }}
        </h1>
        <div class="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
          <span>{{ new Date(article.created_at).toLocaleDateString(undefined, { dateStyle: 'long' }) }}</span>
          <span class="w-1 h-1 bg-gray-400 rounded-full"></span>
          <span>{{ readingTime }} min read</span>
        </div>
      </div>
    </div>

    <!-- Content -->
    <main class="container mx-auto px-4 max-w-3xl py-12">
      <article class="prose prose-lg dark:prose-invert prose-headings:font-serif prose-p:font-sans prose-p:leading-relaxed prose-img:rounded-xl mx-auto">
        <!-- Render content as simple text with line breaks if plain text, or HTML if simple HTML -->
        <!-- For MVP, assuming plain text or simple markdown-like structure handled by css whitespace -->
        <div class="whitespace-pre-wrap font-light text-lg text-gray-800 dark:text-gray-200">
            {{ article.content }}
        </div>
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
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import { Heart, Share2 } from 'lucide-vue-next'
import ChatAI from '../components/ai/ChatAI.vue'

const HeartIcon = Heart
const ShareIcon = Share2

const route = useRoute()
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
