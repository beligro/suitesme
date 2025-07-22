/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
    theme: {
        extend: {
            fontFamily: {
                unbounded: ['Unbounded', 'sans-serif'],
                montserrat: ['Montserrat', 'sans-serif'],
                headingnowtrial: ['Headingnowtrial', 'sans-serif'],
            },
        },
    },
    plugins: [],
}