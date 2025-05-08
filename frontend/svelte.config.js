import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import prerenderEntries from './prerender-entries.json' assert { type: 'json' };

const config = {
    preprocess: vitePreprocess(),
    kit: {
      adapter: adapter(),
      prerender: {
        entries: ['/', ...prerenderEntries]
      }
    }
  };

export default config;
