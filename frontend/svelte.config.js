import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import prerenderEntries from './prerender-entries.json' with { type: 'json' };

const config = {
    preprocess: vitePreprocess(),
    kit: {
      adapter: adapter(),
      prerender: {
        entries: ['/', '/articles', ...prerenderEntries]
      }
    }
  };

export default config;
