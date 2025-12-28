<template>
  <div v-if="visible" class="fixed bottom-4 right-4 md:bottom-6 md:right-6 z-50 w-[calc(100%-2rem)] md:w-full md:max-w-md animate-fade-in-up flex justify-end pointer-events-none">
    
    <!-- Chat Window -->
    <!-- Added pointer-events-auto to inner content so interactions work -->
    <div v-if="isOpen" class="pointer-events-auto w-full glass-panel border border-white/20 dark:border-white/10 rounded-3xl shadow-2xl flex flex-col overflow-hidden transition-all duration-300 h-[60vh] md:h-[550px] max-h-[80vh]">
      
      <!-- Header -->
      <div class="p-4 md:p-5 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-gray-100 dark:border-zinc-800 flex justify-between items-center cursor-grab active:cursor-grabbing">
        <div class="flex items-center gap-3">
          <div class="relative w-2.5 h-2.5 md:w-3 md:h-3">
            <div class="absolute inset-0 bg-green-400 rounded-full animate-ping opacity-75"></div>
            <div class="relative w-2.5 h-2.5 md:w-3 md:h-3 bg-green-500 rounded-full"></div>
          </div>
          <div>
             <h3 class="font-serif font-bold text-sm md:text-base text-gray-800 dark:text-gray-100">Lazarus Assistant</h3>
             <p class="text-[9px] md:text-[10px] text-gray-500 uppercase tracking-widest font-sans">Ai Powered Context</p>
          </div>
        </div>
        <button @click="isOpen = false" class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-800 transition-colors text-gray-400">
          <component :is="XIcon" class="w-5 h-5" />
        </button>
      </div>
      
      <!-- Messages -->
      <div class="flex-1 overflow-y-auto p-4 md:p-5 space-y-4 md:space-y-6 bg-gray-50/30 dark:bg-zinc-900/30" ref="messagesContainer">
        <div v-for="(msg, index) in messages" :key="index" :class="['flex', msg.role === 'user' ? 'justify-end' : 'justify-start']">
           <div :class="[
             'max-w-[90%] md:max-w-[85%] rounded-2xl px-4 py-3 md:px-5 md:py-4 shadow-sm',
             msg.role === 'user' 
               ? 'bg-zen-accent-light dark:bg-zen-accent-dark text-white rounded-br-sm' 
               : 'bg-white dark:bg-zinc-800 border border-gray-100 dark:border-zinc-700 rounded-bl-sm ai-message'
           ]">
             <div v-html="renderMarkdown(msg.content)" :class="msg.role === 'user' ? 'user-message' : 'assistant-message'"></div>
           </div>
        </div>
        <div v-if="isLoading" class="flex justify-start">
           <div class="bg-white dark:bg-zinc-800 rounded-2xl rounded-bl-none px-4 py-3 border border-gray-100 dark:border-zinc-700 shadow-sm">
             <div class="flex gap-1.5">
               <span class="w-1.5 h-1.5 bg-gray-300 dark:bg-zinc-600 rounded-full animate-bounce"></span>
               <span class="w-1.5 h-1.5 bg-gray-300 dark:bg-zinc-600 rounded-full animate-bounce delay-100"></span>
               <span class="w-1.5 h-1.5 bg-gray-300 dark:bg-zinc-600 rounded-full animate-bounce delay-200"></span>
             </div>
           </div>
        </div>
      </div>

      <!-- Input -->
      <div class="p-3 md:p-4 bg-white/90 dark:bg-zinc-900/90 backdrop-blur-md border-t border-gray-100 dark:border-zinc-800">
        <!-- Cooldown Notice -->
        <div v-if="cooldownRemaining > 0" class="mb-3 p-2 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg text-center">
          <p class="text-xs text-amber-700 dark:text-amber-400">
            <span class="font-semibold">{{ Math.ceil(cooldownRemaining / 1000) }}s</span> cooldown
            <span v-if="promptCount % 3 === 0 && promptCount > 0"> (Extended: Every 3 prompts)</span>
          </p>
        </div>
        
        <form @submit.prevent="sendMessage" class="relative group">
          <input 
            v-model="input" 
            placeholder="Ask Lazarus..." 
            class="w-full pl-5 pr-12 py-3 rounded-full bg-gray-50 dark:bg-zinc-800 border border-transparent focus:border-zen-accent-light dark:focus:border-zen-accent-dark focus:ring-0 transition-all text-xs md:text-sm shadow-inner"
            :disabled="isLoading || cooldownRemaining > 0"
          />
          <button 
            type="submit" 
            :disabled="!input || isLoading || cooldownRemaining > 0"
            class="absolute right-2 top-1/2 -translate-y-1/2 p-2 bg-black dark:bg-white text-white dark:text-black rounded-full hover:scale-105 disabled:opacity-50 disabled:scale-100 disabled:cursor-not-allowed transition-all shadow-md"
          >
            <component :is="SendIcon" class="w-4 h-4" />
          </button>
        </form>
      </div>

    </div>

    <!-- Toggle Button -->
    <button 
      v-else 
      @click="isOpen = true" 
      class="pointer-events-auto float-right bg-white dark:bg-zinc-800 text-zen-accent-light dark:text-zen-accent-dark p-4 rounded-full shadow-xl border border-gray-100 dark:border-zinc-700 hover:scale-110 active:scale-95 transition-all duration-300 group relative overflow-hidden"
    >
      <div class="absolute inset-0 bg-zen-accent-light/10 dark:bg-zen-accent-dark/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
      <component :is="BotIcon" class="w-6 h-6 relative z-10" />
      <span class="hidden md:block absolute right-full mr-4 top-1/2 -translate-y-1/2 bg-white dark:bg-zinc-800 text-gray-600 dark:text-gray-300 text-xs font-medium px-3 py-1.5 rounded-full shadow-lg opacity-0 group-hover:opacity-100 whitespace-nowrap transition-all pointer-events-none translate-x-2 group-hover:translate-x-0">
        Ask Lazarus
      </span>
    </button>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, onUnmounted } from 'vue'
import { X, Send, Bot } from 'lucide-vue-next'
import { GoogleGenerativeAI } from '@google/generative-ai'
import { marked } from 'marked'

const props = defineProps({
  context: {
    type: String, // The article content
    default: ''
  },
  visible: {
    type: Boolean,
    default: true
  }
})

const XIcon = X
const SendIcon = Send
const BotIcon = Bot

const isOpen = ref(false)
const input = ref('')
const messages = ref([
  { role: 'model', content: "Greetings. I am Lazarus. How may I assist you with this article today?" }
])
const isLoading = ref(false)
const messagesContainer = ref(null)

// Rate limiting
const promptCount = ref(0)
const cooldownRemaining = ref(0)
let cooldownInterval = null

// Init Gemini
const genAI = new GoogleGenerativeAI(import.meta.env.VITE_GEMINI_API_KEY)
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

function renderMarkdown(text) {
  return marked(text)
}

function scrollToBottom() {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

function startCooldown(duration) {
  cooldownRemaining.value = duration
  
  // Clear previous interval if exists
  if (cooldownInterval) {
    clearInterval(cooldownInterval)
  }
  
  // Update countdown every 100ms for smooth display
  cooldownInterval = setInterval(() => {
    cooldownRemaining.value -= 100
    if (cooldownRemaining.value <= 0) {
      cooldownRemaining.value = 0
      clearInterval(cooldownInterval)
      cooldownInterval = null
    }
  }, 100)
}

async function sendMessage() {
  if (!input.value.trim() || cooldownRemaining.value > 0) return
  
  const userMsg = input.value
  messages.value.push({ role: 'user', content: userMsg })
  input.value = ''
  isLoading.value = true
  scrollToBottom()

  try {
    // Construct prompt with context
    const fullPrompt = `
      Context (The Article Content):
      "${props.context.substring(0, 15000)}" 

      User Question: ${userMsg}

      Role: You are "Lazarus Assistant", a wise, calm, and minimalist AI assistant for a Zen-themed blog. 
      Tone: Calm, clear, concise, professional yet warm. 
      Instructions: Answer strictly based on the provided context if possible. Use markdown for simple formatting.
    `

    const result = await model.generateContent(fullPrompt)
    const response = await result.response
    const text = response.text()
    
    messages.value.push({ role: 'model', content: text })
    
    // Increment prompt count
    promptCount.value++
    
    // Apply cooldown
    // Every 3 prompts: 10 seconds
    // Otherwise: 3 seconds
    if (promptCount.value % 3 === 0) {
      startCooldown(10000) // 10 seconds
    } else {
      startCooldown(3000) // 3 seconds
    }
    
  } catch (error) {
    console.error('Gemini API Error:', error)
    messages.value.push({ role: 'model', content: "I apologize, but I am currently unable to connect to the consciousness. Please try again in a moment." })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

// Cleanup interval on component unmount
onUnmounted(() => {
  if (cooldownInterval) {
    clearInterval(cooldownInterval)
  }
})
</script>

<style scoped>
.glass-panel {
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

/* AI Assistant Message Styling */
.assistant-message {
  font-size: 0.875rem;
  line-height: 1.7;
  color: #374151;
}

.dark .assistant-message {
  color: #d1d5db;
}

/* User Message Styling */
.user-message {
  font-size: 0.875rem;
  line-height: 1.6;
  color: white;
}

/* Paragraph spacing */
.assistant-message :deep(p) {
  margin-bottom: 0.75rem;
  line-height: 1.75;
}

.assistant-message :deep(p:last-child) {
  margin-bottom: 0;
}

/* Bold text - less heavy */
.assistant-message :deep(strong) {
  font-weight: 600;
  color: #1f2937;
}

.dark .assistant-message :deep(strong) {
  color: #f3f4f6;
}

/* Lists */
.assistant-message :deep(ul),
.assistant-message :deep(ol) {
  margin: 0.75rem 0;
  padding-left: 1.5rem;
}

.assistant-message :deep(li) {
  margin-bottom: 0.5rem;
  line-height: 1.7;
}

.assistant-message :deep(li:last-child) {
  margin-bottom: 0;
}

/* Code blocks */
.assistant-message :deep(code) {
  background-color: #f3f4f6;
  color: #be123c;
  padding: 0.125rem 0.375rem;
  border-radius: 0.25rem;
  font-size: 0.8125rem;
  font-family: 'Courier New', monospace;
}

.dark .assistant-message :deep(code) {
  background-color: #1f2937;
  color: #fca5a5;
}

.assistant-message :deep(pre) {
  background-color: #f3f4f6;
  padding: 0.75rem;
  border-radius: 0.5rem;
  overflow-x: auto;
  margin: 0.75rem 0;
}

.dark .assistant-message :deep(pre) {
  background-color: #1f2937;
}

.assistant-message :deep(pre code) {
  background: none;
  padding: 0;
  color: inherit;
}

/* Headings in AI response */
.assistant-message :deep(h1),
.assistant-message :deep(h2),
.assistant-message :deep(h3),
.assistant-message :deep(h4) {
  font-weight: 600;
  margin-top: 1rem;
  margin-bottom: 0.5rem;
  line-height: 1.4;
}

.assistant-message :deep(h1) { font-size: 1.125rem; }
.assistant-message :deep(h2) { font-size: 1.0625rem; }
.assistant-message :deep(h3) { font-size: 1rem; }
.assistant-message :deep(h4) { font-size: 0.9375rem; }

/* Blockquotes */
.assistant-message :deep(blockquote) {
  border-left: 3px solid #8CAE9E;
  padding-left: 1rem;
  margin: 0.75rem 0;
  font-style: italic;
  color: #6b7280;
}

.dark .assistant-message :deep(blockquote) {
  border-left-color: #8CAE9E;
  color: #9ca3af;
}

/* Links */
.assistant-message :deep(a) {
  color: #8CAE9E;
  text-decoration: underline;
}

.assistant-message :deep(a:hover) {
  color: #6d9482;
}
</style>
