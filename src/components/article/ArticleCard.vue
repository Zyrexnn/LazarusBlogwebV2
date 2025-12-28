<template>
  <div class="group relative flex flex-col gap-4 p-0 transition-all duration-300">
    <div v-if="article.image_url" class="aspect-[3/2] w-full overflow-hidden rounded-2xl bg-gray-100 dark:bg-zinc-800">
      <img :src="article.image_url" :alt="article.title" class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-105" loading="lazy" />
      <div class="absolute inset-0 bg-black/5 dark:bg-black/20 group-hover:bg-transparent transition-colors"></div>
    </div>
    
    <div class="flex flex-col gap-3 mt-2 pr-4">
      <div class="flex items-center gap-3">
         <span class="text-[10px] font-bold text-zen-accent-light dark:text-zen-accent-dark uppercase tracking-widest">{{ article.category }}</span>
         <span class="w-1 h-1 rounded-full bg-gray-300 dark:bg-zinc-700"></span>
         <span class="text-[10px] text-gray-400 uppercase tracking-widest">{{ new Date(article.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) }}</span>
      </div>

      <h3 class="text-2xl font-serif font-bold text-zen-text-light dark:text-zen-text-dark leading-tight group-hover:text-zen-accent-light dark:group-hover:text-zen-accent-dark transition-colors">
        <router-link :to="{ name: 'article', params: { id: article.id } }">
          <span class="absolute inset-0"></span>
          {{ article.title }}
        </router-link>
      </h3>

      <p class="text-base text-gray-500 dark:text-gray-400 line-clamp-3 font-light leading-relaxed">
        {{ article.content.substring(0, 160) }}...
      </p>

      <div class="flex items-center text-sm font-medium text-zen-text-light dark:text-zen-text-dark opacity-0 group-hover:opacity-100 transition-opacity -translate-x-2 group-hover:translate-x-0 duration-300 pointer-events-none">
         Read Article <span class="ml-2">→</span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  article: {
    type: Object,
    required: true
  }
})
</script>
