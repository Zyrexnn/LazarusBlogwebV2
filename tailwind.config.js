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
        },
    },
    plugins: [],
}
