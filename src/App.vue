<template>
  <div class="min-h-screen flex flex-col font-sans transition-colors duration-300">
    <!-- Human Verification CAPTCHA -->
    <HumanVerification />
    
    <Navbar />
    <router-view v-slot="{ Component }">
      <transition name="fade" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
    <Footer />
  </div>
</template>

<script setup>
import Navbar from './components/layout/Navbar.vue'
import Footer from './components/layout/Footer.vue'
import HumanVerification from './components/layout/HumanVerification.vue'
</script>
