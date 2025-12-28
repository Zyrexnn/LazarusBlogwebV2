
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
    const user = ref(null)
    const isAdmin = ref(false)

    function setUser(newUser) {
        user.value = newUser
        isAdmin.value = newUser?.email === 'admin@lazarus.blog' // Placeholder check
    }

    return { user, isAdmin, setUser }
})
