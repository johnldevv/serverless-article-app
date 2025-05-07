export async function load({ fetch }) {
    const res = await fetch(`${import.meta.env.VITE_API_URL}/articles`);
    const json = await res.json();
  
    // API returns { message: "...", articles: [...] }
    return {
      articles: json.articles || []
    };
  }
  