import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss(), react()],
  server: {
    proxy: {
      // When the client makes a request to /api, forward it to the backend at localhost:3001
<<<<<<< HEAD
      '/api': {
        target: 'http://localhost:3000',
=======
      "/api": {
        target: "http://localhost:3001",
>>>>>>> 1d246d46dae47e5f4d274289d6d8d2f4dac1a49c
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path, // you can adjust if needed
      },
    },
  },
});
