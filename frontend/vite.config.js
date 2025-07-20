// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: [ '03fec5e7a353.ngrok-free.app'],
    host: true,
  },
});