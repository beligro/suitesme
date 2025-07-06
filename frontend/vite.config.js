import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'


// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],

  server: {
    allowedHosts: ["e7c1-91-184-242-195.ngrok-free.app", '127.0.0.1'],
  }
})
