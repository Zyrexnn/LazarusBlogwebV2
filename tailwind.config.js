/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{vue,js,ts,jsx,tsx}",
    ],
    darkMode: 'class',
    theme: {
        extend: {
            colors: {
                // Light Mode
                'zen-bg-light': '#F9F9F9',
                'zen-text-light': '#2D2D2D',
                'zen-accent-light': '#8CAE9E', // Sage Green

                // Dark Mode
                'zen-bg-dark': '#121212',
                'zen-text-dark': '#E0E0E0',
                'zen-accent-dark': '#64748B', // Slate
            },
            fontFamily: {
                serif: ['Playfair Display', 'serif'],
                sans: ['Inter', 'sans-serif'],
            },
            keyframes: {
                'fade-in': {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                'fade-in-up': {
                    '0%': { opacity: '0', transform: 'translateY(20px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                'fade-in-down': {
                    '0%': { opacity: '0', transform: 'translateY(-20px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                'breathe': {
                    '0%, 100%': { transform: 'scale(1)' },
                    '50%': { transform: 'scale(1.02)' },
                }
            },
            animation: {
                'fade-in': 'fade-in 0.8s ease-out forwards',
                'fade-in-up': 'fade-in-up 0.8s ease-out forwards',
                'fade-in-down': 'fade-in-down 0.8s ease-out forwards',
                'fade-in-delayed': 'fade-in 0.8s ease-out 0.4s forwards',
                'fade-in-up-delayed': 'fade-in-up 0.8s ease-out 0.2s forwards',
                'breathe': 'breathe 8s ease-in-out infinite',
            }
        },
    },
    plugins: [],
}
