<template>
  <div class="min-h-screen container mx-auto px-4 py-12">
    <div v-if="!isAuthenticated" class="max-w-md mx-auto mt-20 p-8 border border-gray-200 dark:border-zinc-800 rounded-2xl">
      <h2 class="text-2xl font-serif font-bold mb-6 text-center">Admin Access</h2>
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Username</label>
          <input v-model="username" type="text" class="w-full px-4 py-2 rounded-lg border dark:bg-zinc-900 dark:border-zinc-700" required />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Password</label>
          <input v-model="password" type="password" class="w-full px-4 py-2 rounded-lg border dark:bg-zinc-900 dark:border-zinc-700" required />
        </div>
        <button type="submit" class="w-full py-2 bg-zen-accent-light dark:bg-zen-accent-dark text-white rounded-lg hover:opacity-90">
          Enter Dashboard
        </button>
      </form>
    </div>

    <div v-else>
      <header class="flex justify-between items-center mb-12">
        <h1 class="text-3xl font-serif font-bold">Dashboard</h1>
        <div class="flex gap-3">
           <span class="px-4 py-2 bg-gray-100 dark:bg-zinc-800 rounded-full text-sm flex items-center gap-2">
             <span class="w-2 h-2 bg-green-500 rounded-full"></span>
             Admin: Lazarus
           </span>
           <button @click="openCreateModal" class="px-6 py-2 bg-black dark:bg-white text-white dark:text-black rounded-full font-medium hover:opacity-90 transition-opacity">
             + New Article
           </button>
           <button @click="handleLogout" class="px-6 py-2 bg-red-500 text-white rounded-full font-medium hover:bg-red-600 transition-colors flex items-center gap-2">
             <component :is="LogOutIcon" class="w-4 h-4" />
             Logout
           </button>
        </div>
      </header>
      
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
         <div class="p-6 bg-white dark:bg-zinc-900 border border-gray-100 dark:border-zinc-800 rounded-2xl shadow-sm">
           <h3 class="text-lg font-medium mb-4">Total Articles</h3>
           <p class="text-4xl font-serif font-bold">{{ articles.length }}</p>
         </div>
         <div class="p-6 bg-white dark:bg-zinc-900 border border-gray-100 dark:border-zinc-800 rounded-2xl shadow-sm">
           <h3 class="text-lg font-medium mb-4">Category Distribution</h3>
           <div class="h-48 relative w-full">
             <canvas ref="chartCanvas"></canvas>
           </div>
         </div>
      </div>

      <!-- Article List -->
      <div class="bg-white dark:bg-zinc-900 border border-gray-100 dark:border-zinc-800 rounded-2xl overflow-hidden mt-8">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse min-w-[600px]">
            <thead class="bg-gray-50 dark:bg-zinc-950 text-xs uppercase text-gray-500">
                <tr>
                <th class="px-6 py-4">Title</th>
                <th class="px-6 py-4">Category</th>
                <th class="px-6 py-4">Date</th>
                <th class="px-6 py-4 text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 dark:divide-zinc-800">
                <tr v-for="article in articles" :key="article.id" class="hover:bg-gray-50 dark:hover:bg-zinc-800/50">
                <td class="px-6 py-4 font-medium">{{ article.title }}</td>
                <td class="px-6 py-4">
                    <span class="text-xs px-2 py-1 bg-gray-100 dark:bg-zinc-800 rounded-full whitespace-nowrap">{{ article.category }}</span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-500 whitespace-nowrap">{{ new Date(article.created_at).toLocaleDateString() }}</td>
                <td class="px-6 py-4 text-right gap-2 whitespace-nowrap">
                    <button @click="openEditModal(article)" class="text-blue-500 hover:underline text-sm mr-4">Edit</button>
                    <button @click="deleteArticle(article.id)" class="text-red-500 hover:underline text-sm ml-4">Delete</button>
                </td>
                </tr>
            </tbody>
            </table>
        </div>
      </div>
    </div>
    
    <!-- Modal for Create/Edit -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
      <div class="bg-white dark:bg-zinc-900 w-full max-w-2xl rounded-2xl shadow-2xl overflow-y-auto max-h-[90vh]">
        <div class="p-6 border-b border-gray-100 dark:border-zinc-800 flex justify-between">
          <h3 class="font-serif font-bold text-xl">{{ isEditing ? 'Edit Article' : 'Write Article' }}</h3>
          <button @click="showModal = false" class="text-gray-400 hover:text-gray-600">Close</button>
        </div>
        <form @submit.prevent="saveArticle" class="p-6 space-y-4">
          <div>
            <label class="label">Title</label>
            <input v-model="form.title" class="input-field" required />
          </div>
          
          <div>
            <label class="label">Cover Image</label>
            <div class="flex gap-2">
                 <input 
                   type="text" 
                   v-model="form.image_url" 
                   class="input-field flex-1" 
                   placeholder="https://..." 
                 />
                 <label class="px-4 py-2 bg-gray-100 dark:bg-zinc-800 rounded-lg cursor-pointer hover:bg-gray-200 flex items-center justify-center relative overflow-hidden">
                     <span v-if="!uploading">Upload</span>
                     <span v-else class="text-xs">Uploading...</span>
                     <input type="file" class="absolute inset-0 opacity-0 cursor-pointer" accept="image/*" @change="(e) => uploadImage(e, 'cover')" :disabled="uploading" />
                 </label>
            </div>
          </div>

          <div>
            <label class="label">Category</label>
            <select v-model="form.category" class="input-field">
              <option>Technology</option>
              <option>Life & Story</option>
              <option>Poetry</option>
              <option>Philosophy</option>
              <option>Design</option>
              <option>Travel</option>
              <option>Ideas</option>
              <option>Tutorial</option>
              <option>Politics</option>
              <option>Language</option>
              <option>Culture</option>
              <option>Science</option>
              <option>Business</option>
              <option>Health</option>
              <option>History</option>
              <option>Art</option>
            </select>
          </div>
          <div>
            <div class="flex justify-between items-center mb-1">
                 <label class="label mb-0">Content (Markdown supported)</label>
                 <label class="text-xs px-2 py-1 bg-gray-100 dark:bg-zinc-800 rounded cursor-pointer hover:bg-gray-200">
                     {{ uploading ? 'Uploading...' : '+ Insert Image' }}
                     <input type="file" class="hidden" accept="image/*" @change="(e) => uploadImage(e, 'content')" :disabled="uploading" />
                 </label>
            </div>
            <textarea v-model="form.content" rows="12" class="input-field font-mono text-sm" required></textarea>
          </div>
          <button type="submit" class="w-full py-3 bg-zen-accent-light dark:bg-zen-accent-dark text-white rounded-xl font-medium" :disabled="uploading">
            {{ isEditing ? 'Update Article' : 'Publish Article' }}
          </button>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { supabase } from '../lib/supabase'
import Chart from 'chart.js/auto'
import { LogOut } from 'lucide-vue-next'

const LogOutIcon = LogOut

const isAuthenticated = ref(false)
const username = ref('')
const password = ref('')
const articles = ref([])
const showModal = ref(false)
const chartCanvas = ref(null)
let chartInstance = null

const isEditing = ref(false)
const uploading = ref(false)
const fileInput = ref(null)
const contentFileInput = ref(null)

const form = ref({
  id: null,
  title: '',
  content: '',
  category: 'Technology',
  image_url: ''
})



async function uploadImage(event, target = 'cover') {
  const file = event.target.files[0]
  if (!file) return

  uploading.value = true
  const fileName = `${Date.now()}_${file.name.replace(/\s+/g, '-')}`
  
  try {
      const { data, error } = await supabase.storage
        .from('article-images')
        .upload(fileName, file)
      
      if (error) throw error

      // Get public URL
      const { data: publicData } = supabase.storage
        .from('article-images')
        .getPublicUrl(fileName)
      
      const publicUrl = publicData.publicUrl

      if (target === 'cover') {
        form.value.image_url = publicUrl
      } else if (target === 'content') {
        const markdownImage = `\n![Image](${publicUrl})\n`
        form.value.content += markdownImage
      }

  } catch (error) {
      alert('Upload failed: ' + error.message)
      console.error(error)
  } finally {
      uploading.value = false
  }
}

function openCreateModal() {
  form.value = { id: null, title: '', content: '', category: 'Technology', image_url: '' }
  isEditing.value = false
  showModal.value = true
}

function openEditModal(article) {
  form.value = { 
    id: article.id, 
    title: article.title, 
    content: article.content, 
    category: article.category, 
    image_url: article.image_url 
  }
  isEditing.value = true
  showModal.value = true
}

async function handleLogout() {
  if (!confirm('Are you sure you want to logout?')) return
  
  try {
    // Sign out from Supabase
    await supabase.auth.signOut()
    
    // Clear local storage
    localStorage.removeItem('admin_session')
    
    // Update state
    isAuthenticated.value = false
    articles.value = []
    
    // Optional: Show success message
    alert('Successfully logged out!')
  } catch (error) {
    console.error('Logout error:', error)
    alert('Error logging out. Please try again.')
  }
}

async function handleLogin() {
  if (username.value === 'Lazarus' && password.value === '0721') {
      const email = 'admin@lazarus.blog'
      const securePassword = 'lazarus_secret_0721' 
      
      // 1. Coba Login
      let { data, error } = await supabase.auth.signInWithPassword({
        email: email,
        password: securePassword
      })

      // 2. Jika Login gagal (user belum ada), coba Daftarkan (SignUp) otomatis
      if (error) {
          console.log("Login gagal, mencoba mendaftar otomatis...", error.message)
          const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
            email: email,
            password: securePassword,
          })
          
          if (!signUpError && signUpData.user) {
              if (!signUpData.session) {
                  alert('Akun Admin berhasil dibuat! TAPI: Kamu harus mematikan "Confirm Email" di Dashboard Supabase agar bisa langsung login. Silakan matikan setting itu, lalu coba login lagi.')
                  return
              }
              alert('Akun Admin berhasil dibuat dan login!')
              isAuthenticated.value = true
              localStorage.setItem('admin_session', 'true')
              fetchArticles()
              return
          } else if (signUpError) {
             console.error("Gagal mendaftar:", signUpError)
             if (signUpError.message.includes("already registered")) {
                 alert("Akun sudah ada tapi password salah di database Supabase. Hapus user di Supabase User Auth dan coba lagi.")
                 return
             }
          }
           
          alert(`Login Gagal: ${error.message}`)
      } else {
          // Login berhasil
          isAuthenticated.value = true
          localStorage.setItem('admin_session', 'true')
          fetchArticles()
      }
  } else {
      alert('Username atau Password Salah (Cek Frontend)')
  }
}

async function fetchArticles() {
  const { data } = await supabase
    .from('articles')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (data) {
    articles.value = data
    renderChart()
  }
}

async function saveArticle() {
  const articleData = {
    title: form.value.title,
    content: form.value.content,
    category: form.value.category,
    image_url: form.value.image_url
  }

  let error = null

  if (isEditing.value && form.value.id) {
    // Update
    const res = await supabase
      .from('articles')
      .update(articleData)
      .eq('id', form.value.id)
    error = res.error
  } else {
    // Create
    const res = await supabase
      .from('articles')
      .insert([articleData])
    error = res.error
  }

  if (error) {
    alert(error.message)
  } else {
    showModal.value = false
    fetchArticles()
  }
}

async function deleteArticle(id) {
  if (!confirm('Are you sure?')) return
  
  const { error } = await supabase.from('articles').delete().eq('id', id)
  if (!error) fetchArticles()
  else alert(error.message)
}

function renderChart() {
  if (!chartCanvas.value) return
  
  if (chartInstance) chartInstance.destroy()
  
  const counts = {}
  articles.value.forEach(a => {
    counts[a.category] = (counts[a.category] || 0) + 1
  })
  
  chartInstance = new Chart(chartCanvas.value, {
    type: 'doughnut',
    data: {
      labels: Object.keys(counts),
      datasets: [{
        data: Object.values(counts),
        backgroundColor: ['#8CAE9E', '#64748B', '#E2E8F0', '#F1F5F9', '#CBD5E1'],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right' }
      }
    }
  })
}

// Auto-check session
onMounted(async () => {
    // Cek apakah ada session Supabase yang aktif (Real)
    const { data } = await supabase.auth.getSession()
    if (data.session) {
        isAuthenticated.value = true
        fetchArticles()
    } else {
        // Jika tidak ada session, pastikan user harus login ulang
        isAuthenticated.value = false
    }

    // Listener jika auth state berubah (misal token expired)
    supabase.auth.onAuthStateChange((event, session) => {
        if (session) {
            isAuthenticated.value = true
        } else {
            isAuthenticated.value = false
        }
    })
})

watch([isAuthenticated, showModal], async () => {
    if (isAuthenticated.value && !showModal.value) {
        await nextTick()
        renderChart()
    }
})
</script>

<style scoped>
.label {
    @apply block text-sm font-medium mb-1 text-gray-700 dark:text-gray-300;
}
.input-field {
    @apply w-full px-4 py-2 rounded-lg bg-gray-50 dark:bg-zinc-800 border-none focus:ring-2 focus:ring-zen-accent-light dark:focus:ring-zen-accent-dark transition-all;
}
</style>
