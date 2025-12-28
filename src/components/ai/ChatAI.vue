<template>
  <div v-if="visible" class="fixed bottom-6 right-6 z-50 w-full max-w-sm md:max-w-md animate-fade-in-up">
    <!-- Chat Window -->
    <div v-if="isOpen" class="glass-panel border border-white/20 dark:border-white/10 rounded-3xl shadow-2xl flex flex-col overflow-hidden transition-all duration-300 h-[550px]">
      
      <!-- Header -->
      <div class="p-5 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-gray-100 dark:border-zinc-800 flex justify-between items-center">
        <div class="flex items-center gap-3">
          <div class="relative w-3 h-3">
            <div class="absolute inset-0 bg-green-400 rounded-full animate-ping opacity-75"></div>
            <div class="relative w-3 h-3 bg-green-500 rounded-full"></div>
          </div>
          <div>
             <h3 class="font-serif font-bold text-base text-gray-800 dark:text-gray-100">Lazarus Assistant</h3>
             <p class="text-[10px] text-gray-500 uppercase tracking-widest font-sans">Ai Powered Context</p>
          </div>
        </div>
        <button @click="isOpen = false" class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-800 transition-colors text-gray-400">
          <component :is="XIcon" class="w-5 h-5" />
        </button>
      </div>
      
      <!-- Messages -->
      <div class="flex-1 overflow-y-auto p-5 space-y-6 bg-gray-50/30 dark:bg-zinc-900/30" ref="messagesContainer">
        <div v-for="(msg, index) in messages" :key="index" :class="['flex', msg.role === 'user' ? 'justify-end' : 'justify-start']">
           <div :class="[
             'max-w-[85%] rounded-2xl px-5 py-3 text-sm leading-relaxed shadow-sm',
             msg.role === 'user' 
               ? 'bg-zen-accent-light dark:bg-zen-accent-dark text-white rounded-br-sm' 
               : 'bg-white dark:bg-zinc-800 border border-gray-100 dark:border-zinc-700 text-gray-700 dark:text-gray-300 rounded-bl-sm'
           ]">
             <p v-html="renderMarkdown(msg.content)"></p>
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
      <div class="p-4 bg-white/90 dark:bg-zinc-900/90 backdrop-blur-md border-t border-gray-100 dark:border-zinc-800">
        <form @submit.prevent="sendMessage" class="relative group">
          <input 
            v-model="input" 
            placeholder="Ask Lazarus..." 
            class="w-full pl-5 pr-12 py-3.5 rounded-full bg-gray-50 dark:bg-zinc-800 border border-transparent focus:border-zen-accent-light dark:focus:border-zen-accent-dark focus:ring-0 transition-all text-sm shadow-inner"
            :disabled="isLoading"
          />
          <button 
            type="submit" 
            :disabled="!input.trim() || isLoading"
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
      class="float-right bg-white dark:bg-zinc-800 text-zen-accent-light dark:text-zen-accent-dark p-4 rounded-full shadow-xl border border-gray-100 dark:border-zinc-700 hover:scale-110 active:scale-95 transition-all duration-300 group relative overflow-hidden"
    >
      <div class="absolute inset-0 bg-zen-accent-light/10 dark:bg-zen-accent-dark/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
      <component :is="BotIcon" class="w-6 h-6 relative z-10" />
      <span class="absolute right-full mr-4 top-1/2 -translate-y-1/2 bg-white dark:bg-zinc-800 text-gray-600 dark:text-gray-300 text-xs font-medium px-3 py-1.5 rounded-full shadow-lg opacity-0 group-hover:opacity-100 whitespace-nowrap transition-all pointer-events-none translate-x-2 group-hover:translate-x-0">
        Ask Lazarus
      </span>
    </button>
  </div>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
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

async function sendMessage() {
  if (!input.value.trim()) return
  
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
  } catch (error) {
    console.error('Gemini API Error:', error)
    messages.value.push({ role: 'model', content: "I apologize, but I am currently unable to connect to the consciousness. Please try again in a moment." })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}
</script>

<style scoped>
.glass-panel {
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}
</style>
