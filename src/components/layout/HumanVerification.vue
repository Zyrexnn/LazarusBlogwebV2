<template>
  <Transition name="fade-scale">
    <div v-if="showCaptcha" class="fixed inset-0 z-[999] flex items-center justify-center bg-black/80 backdrop-blur-md p-3 sm:p-4 overflow-y-auto">
      <div class="bg-gradient-to-b from-zinc-900 via-zinc-800 to-zinc-900 rounded-2xl sm:rounded-3xl shadow-2xl border-2 border-amber-500/30 max-w-md w-full overflow-hidden animate-fade-in-up relative my-auto">
        
        <!-- Glow Effect -->
        <div class="absolute inset-0 bg-gradient-to-br from-amber-500/5 via-transparent to-orange-500/5 pointer-events-none"></div>
        
        <!-- Header with Character -->
        <div class="relative h-48 sm:h-56 overflow-hidden bg-gradient-to-b from-zinc-800 via-zinc-900 to-black">
          <!-- Animated particles background -->
          <div class="absolute inset-0 opacity-20">
            <div class="absolute top-6 left-6 w-1.5 h-1.5 bg-amber-400 rounded-full animate-pulse"></div>
            <div class="absolute top-12 right-12 w-1 h-1 bg-orange-400 rounded-full animate-pulse delay-100"></div>
            <div class="absolute bottom-12 left-12 w-1 h-1 bg-yellow-400 rounded-full animate-pulse delay-200"></div>
            <div class="absolute bottom-6 right-6 w-1.5 h-1.5 bg-amber-300 rounded-full animate-pulse delay-300"></div>
          </div>
          
          <!-- Character Image - Fully Visible on All Devices -->
          <div class="absolute inset-0 flex items-center justify-center p-3 sm:p-4">
            <img 
              src="/karakter-removebg-preview.png" 
              alt="Guardian" 
              class="w-full h-full object-contain drop-shadow-[0_0_20px_rgba(251,191,36,0.3)] hover:scale-105 transition-all duration-500"
              style="max-height: 100%; max-width: 100%;"
            />
          </div>
          
          <!-- Mysterious glow at bottom -->
          <div class="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-amber-900/20 to-transparent pointer-events-none"></div>
        </div>
        
        <!-- Title Section - Gaming Style -->
        <div class="px-4 sm:px-6 py-4 border-b border-amber-500/20 relative">
          <div class="absolute inset-0 bg-gradient-to-r from-transparent via-amber-500/5 to-transparent"></div>
          <h2 class="text-xl sm:text-2xl font-serif font-bold mb-1.5 text-amber-100 text-center tracking-wide relative">
            🗡️ Guardian's Challenge 🗡️
          </h2>
          <p class="text-xs sm:text-sm text-amber-200/80 text-center italic relative">
            "Prove thy humanity, wanderer, to enter the realm of knowledge..."
          </p>
        </div>
        
        <!-- CAPTCHA Content -->
        <div class="p-4 sm:p-6 relative">
          <!-- Quest instruction -->
          <div class="mb-4">
            <label class="block text-sm sm:text-base font-medium text-amber-100 mb-3 text-center flex items-center justify-center gap-1.5 sm:gap-2">
              <span class="text-amber-400">⚔️</span>
              <span>Decipher the Ancient Code:</span>
              <span class="text-amber-400">⚔️</span>
            </label>
            
            <!-- Number Display Box - Gaming Style -->
            <div class="relative group">
              <div class="absolute inset-0 bg-gradient-to-r from-amber-500/20 via-orange-500/20 to-amber-500/20 rounded-xl sm:rounded-2xl blur-lg group-hover:blur-xl transition-all"></div>
              <div class="relative bg-gradient-to-br from-zinc-800 via-zinc-900 to-zinc-800 border-2 border-amber-500/40 rounded-xl sm:rounded-2xl p-5 sm:p-6 mb-3 text-center shadow-2xl hover:border-amber-500/60 transition-all duration-300">
                <div class="text-4xl sm:text-5xl md:text-6xl font-bold tracking-[0.3em] sm:tracking-[0.4em] select-none text-amber-100 drop-shadow-[0_0_10px_rgba(251,191,36,0.5)]" style="font-family: 'Courier New', monospace; letter-spacing: 0.4em; text-shadow: 0 0 20px rgba(251,191,36,0.3);">
                  {{ captchaCode }}
                </div>
              </div>
            </div>
            
            <!-- Refresh Button - Gaming Style -->
            <button 
              @click="generateCaptcha"
              class="text-xs sm:text-sm text-amber-400 hover:text-amber-300 flex items-center gap-1.5 sm:gap-2 mx-auto transition-all hover:gap-2 sm:hover:gap-3 group"
            >
              <component :is="RefreshIcon" class="w-3.5 h-3.5 sm:w-4 sm:h-4 group-hover:rotate-180 transition-transform duration-500" />
              <span class="border-b border-amber-400/50 hover:border-amber-300">Summon New Code</span>
            </button>
          </div>
          
          <!-- Input Field - Gaming Style -->
          <div class="mb-4">
            <div class="relative group">
              <div class="absolute inset-0 bg-gradient-to-r from-amber-500/10 via-orange-500/10 to-amber-500/10 rounded-lg sm:rounded-xl blur-md group-focus-within:blur-lg transition-all"></div>
              <input 
                v-model="userInput"
                type="text"
                placeholder="Enter thy answer..."
                maxlength="6"
                class="relative w-full px-4 sm:px-5 py-3 sm:py-4 rounded-lg sm:rounded-xl border-2 border-amber-500/30 bg-zinc-800/50 backdrop-blur-sm text-center text-2xl sm:text-3xl font-bold tracking-[0.3em] sm:tracking-[0.4em] focus:border-amber-500 focus:ring-0 transition-all shadow-lg text-amber-100 placeholder-amber-900/50 focus:shadow-[0_0_20px_rgba(251,191,36,0.2)]"
                :class="{ 'border-red-500 animate-shake shadow-[0_0_20px_rgba(239,68,68,0.5)]': showError }"
                @keyup.enter="verify"
                @input="showError = false"
                style="font-family: 'Courier New', monospace;"
              />
            </div>
            
            <!-- Error Message - Gaming Style -->
            <p v-if="showError" class="text-red-400 text-xs sm:text-sm mt-2 sm:mt-3 text-center animate-fade-in font-medium flex items-center justify-center gap-1.5 sm:gap-2 flex-wrap">
              <span>⚠️</span>
              <span>The code was incorrect, brave one. Try again!</span>
              <span>⚠️</span>
            </p>
          </div>
          
          <!-- Verify Button - Epic Style -->
          <button 
            @click="verify"
            :disabled="!userInput"
            class="relative w-full py-3 sm:py-4 rounded-lg sm:rounded-xl font-bold text-base sm:text-lg transition-all duration-300 group overflow-hidden"
            :class="userInput ? 'hover:scale-[1.02] active:scale-95' : 'opacity-50 cursor-not-allowed'"
          >
            <!-- Button glow -->
            <div class="absolute inset-0 bg-gradient-to-r from-amber-500 via-orange-500 to-amber-500 transition-opacity" :class="userInput ? 'opacity-100' : 'opacity-50'"></div>
            <div class="absolute inset-0 bg-gradient-to-r from-amber-400 via-orange-400 to-amber-400 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            
            <!-- Button text -->
            <span class="relative text-zinc-900 font-extrabold tracking-wide flex items-center justify-center gap-1.5 sm:gap-2">
              <span>⚡</span>
              <span>PROCEED TO REALM</span>
              <span>⚡</span>
            </span>
          </button>
          
          <!-- Info - Gaming Style -->
          <p class="text-[10px] sm:text-xs text-amber-500/60 text-center mt-4 sm:mt-5 flex items-center justify-center gap-1.5 sm:gap-2 italic flex-wrap px-2">
            <span>🛡️</span>
            <span>This trial protects the realm from dark automatons</span>
            <span>🛡️</span>
          </p>
        </div>
        
        <!-- Border glow animation -->
        <div class="absolute inset-0 rounded-2xl sm:rounded-3xl border-2 border-amber-500/0 hover:border-amber-500/20 transition-all duration-500 pointer-events-none"></div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RefreshCw } from 'lucide-vue-next'

const RefreshIcon = RefreshCw

const showCaptcha = ref(false)
const captchaCode = ref('')
const userInput = ref('')
const showError = ref(false)

function generateCaptcha() {
  // Generate 6 random digits
  captchaCode.value = Math.floor(100000 + Math.random() * 900000).toString()
  userInput.value = ''
  showError.value = false
}

function verify() {
  if (userInput.value === captchaCode.value) {
    // Verification success
    showCaptcha.value = false
    localStorage.setItem('humanVerified', 'true')
    localStorage.setItem('verificationTimestamp', Date.now().toString())
    
    // Auto-clear verification after 5 minutes so CAPTCHA shows again on next visit
    setTimeout(() => {
      localStorage.removeItem('humanVerified')
      localStorage.removeItem('verificationTimestamp')
    }, 5 * 60 * 1000) // 5 minutes
  } else {
    // Verification failed
    showError.value = true
    generateCaptcha()
    
    // Shake animation
    setTimeout(() => {
      showError.value = false
    }, 2000)
  }
}

onMounted(() => {
  // Check if user has already verified
  const verified = localStorage.getItem('humanVerified')
  const timestamp = localStorage.getItem('verificationTimestamp')
  
  // Verification expires after 5 minutes (instead of 24 hours)
  const fiveMinutesInMs = 5 * 60 * 1000
  const isExpired = timestamp && (Date.now() - parseInt(timestamp)) > fiveMinutesInMs
  
  if (!verified || isExpired) {
    // Show CAPTCHA for first-time or expired users
    showCaptcha.value = true
    generateCaptcha()
    
    // Clean up expired data
    if (isExpired) {
      localStorage.removeItem('humanVerified')
      localStorage.removeItem('verificationTimestamp')
    }
  }
})
</script>

<style scoped>
/* Fade Scale Transition */
.fade-scale-enter-active,
.fade-scale-leave-active {
  transition: all 0.3s ease;
}

.fade-scale-enter-from {
  opacity: 0;
  transform: scale(0.95);
}

.fade-scale-leave-to {
  opacity: 0;
  transform: scale(0.95);
}

/* Fade In Animation */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.animate-fade-in {
  animation: fadeIn 0.3s ease;
}

/* Fade In Up Animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fadeInUp 0.4s ease;
}

/* Shake Animation */
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
  20%, 40%, 60%, 80% { transform: translateX(5px); }
}

.animate-shake {
  animation: shake 0.5s ease;
}
</style>
