import fs from 'fs';
import https from 'https';

const API_URL = process.env.API_URL || 'https://ggpajgqe08.execute-api.ap-southeast-1.amazonaws.com/staging/articles';

function fetchArticles() {
  return new Promise((resolve, reject) => {
    https.get(API_URL, (res) => {
      let data = '';
      res.on('data', chunk => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          const slugs = json.articles.map(article => `/article/${article.slug}`);
          resolve(slugs);
        } catch (err) {
          reject(err);
        }
      });
    }).on('error', reject);
  });
}

(async () => {
  try {
    const entries = await fetchArticles();
    fs.writeFileSync('frontend/prerender-entries.json', JSON.stringify(entries, null, 2));
    console.log('✅ Generated prerender-entries.json');
  } catch (err) {
    console.error('❌ Failed to generate entries:', err);
    process.exit(1);
  }
})();
