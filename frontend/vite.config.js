import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: ["461b89676796.ngrok-free.app", '127.0.0.1'],
  }
})