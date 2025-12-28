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
        
        <!-- Share Button with Dropdown -->
        <div class="relative">
          <button 
            @click="toggleShareMenu"
            class="flex items-center gap-2 px-6 py-3 rounded-full bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/30 transition-all active:scale-95"
          >
            <component :is="ShareIcon" class="w-5 h-5" />
            <span class="font-medium hidden sm:inline">Share</span>
          </button>
          
          <!-- Share Menu Dropdown -->
          <Transition name="slide-fade">
            <div 
              v-if="showShareMenu"
              class="absolute right-0 mt-2 w-64 bg-white dark:bg-zinc-900 rounded-2xl shadow-2xl border border-gray-200 dark:border-zinc-700 overflow-hidden z-50"
            >
              <div class="p-3 border-b border-gray-100 dark:border-zinc-800">
                <p class="text-sm font-semibold text-gray-700 dark:text-gray-300">Share this article</p>
              </div>
              
              <div class="p-2">
                <!-- Copy Link -->
                <button
                  @click="copyLink"
                  class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-gray-100 dark:hover:bg-zinc-800 transition-colors text-left group"
                >
                  <div class="w-10 h-10 rounded-full bg-gray-100 dark:bg-zinc-800 flex items-center justify-center group-hover:bg-gray-200 dark:group-hover:bg-zinc-700 transition-colors">
                    <component :is="LinkIcon" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
                  </div>
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200">Copy Link</p>
                    <p class="text-xs text-gray-500 dark:text-gray-500">Share anywhere</p>
                  </div>
                </button>
                
                <!-- WhatsApp -->
                <button
                  @click="shareToWhatsApp"
                  class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-green-50 dark:hover:bg-green-900/20 transition-colors text-left group"
                >
                  <div class="w-10 h-10 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center group-hover:bg-green-200 dark:group-hover:bg-green-900/40 transition-colors">
                    <svg class="w-5 h-5 text-green-600 dark:text-green-400" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                    </svg>
                  </div>
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200">WhatsApp</p>
                    <p class="text-xs text-gray-500 dark:text-gray-500">Share with friends</p>
                  </div>
                </button>
                
                <!-- Twitter / X -->
                <button
                  @click="shareToTwitter"
                  class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-sky-50 dark:hover:bg-sky-900/20 transition-colors text-left group"
                >
                  <div class="w-10 h-10 rounded-full bg-sky-100 dark:bg-sky-900/30 flex items-center justify-center group-hover:bg-sky-200 dark:group-hover:bg-sky-900/40 transition-colors">
                    <svg class="w-5 h-5 text-sky-600 dark:text-sky-400" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                    </svg>
                  </div>
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200">Twitter / X</p>
                    <p class="text-xs text-gray-500 dark:text-gray-500">Post on X</p>
                  </div>
                </button>
                
                <!-- Facebook -->
                <button
                  @click="shareToFacebook"
                  class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors text-left group"
                >
                  <div class="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center group-hover:bg-blue-200 dark:group-hover:bg-blue-900/40 transition-colors">
                    <svg class="w-5 h-5 text-blue-600 dark:text-blue-400" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                    </svg>
                  </div>
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200">Facebook</p>
                    <p class="text-xs text-gray-500 dark:text-gray-500">Share on Facebook</p>
                  </div>
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </div>
      
      <!-- Toast Notification -->
      <Transition name="toast">
        <div 
          v-if="showToast"
          class="fixed bottom-8 left-1/2 -translate-x-1/2 z-50 px-6 py-4 bg-gray-900 dark:bg-white text-white dark:text-gray-900 rounded-2xl shadow-2xl flex items-center gap-3 border border-gray-700 dark:border-gray-200"
        >
          <div class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <p class="font-medium">{{ toastMessage }}</p>
        </div>
      </Transition>

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
import { ref, onMounted, computed, watch, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { marked } from 'marked'
import { Heart, Share2, ArrowLeft, Link } from 'lucide-vue-next'
import ChatAI from '../components/ai/ChatAI.vue'

// Render standard markdown with breaks enabled (respects single Enter)
function renderMarkdown(text) {
  return marked.parse(text || '', { breaks: true, gfm: true })
}

const HeartIcon = Heart
const ShareIcon = Share2
const ArrowLeftIcon = ArrowLeft
const LinkIcon = Link

const route = useRoute()
const router = useRouter()
const article = ref(null)
const loading = ref(true)
const likeCount = ref(0)
const hasLiked = ref(false)
const relatedArticles = ref([])
const showShareMenu = ref(false)
const showToast = ref(false)
const toastMessage = ref('')

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

function toggleShareMenu() {
  showShareMenu.value = !showShareMenu.value
}

function displayToast(message) {
  toastMessage.value = message
  showToast.value = true
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

async function copyLink() {
  try {
    await navigator.clipboard.writeText(window.location.href)
    displayToast('Link copied to clipboard!')
    showShareMenu.value = false
  } catch (err) {
    console.error('Failed to copy:', err)
    displayToast('Failed to copy link')
  }
}

function shareToWhatsApp() {
  const text = encodeURIComponent(`Check out this article: ${article.value.title}\n${window.location.href}`)
  window.open(`https://wa.me/?text=${text}`, '_blank')
  showShareMenu.value = false
  displayToast('Opening WhatsApp...')
}

function shareToTwitter() {
  const text = encodeURIComponent(article.value.title)
  const url = encodeURIComponent(window.location.href)
  window.open(`https://twitter.com/intent/tweet?text=${text}&url=${url}`, '_blank')
  showShareMenu.value = false
  displayToast('Opening Twitter...')
}

function shareToFacebook() {
  const url = encodeURIComponent(window.location.href)
  window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, '_blank')
  showShareMenu.value = false
  displayToast('Opening Facebook...')
}

function goBack() {
  router.back()
}

// Close share menu when clicking outside
function handleClickOutside(event) {
  const shareMenu = event.target.closest('.relative')
  if (!shareMenu && showShareMenu.value) {
    showShareMenu.value = false
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
    document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* No hack needed - using standard markdown rendering */

/* Slide Fade Transition for Dropdown */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.2s ease;
}

.slide-fade-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.slide-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Toast Transition */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translate(-50%, 20px);
}

.toast-leave-to {
  opacity: 0;
  transform: translate(-50%, 20px);
}
</style>
