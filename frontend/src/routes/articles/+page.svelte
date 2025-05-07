<script>
    export let data;
  </script>
  
  <h1>Articles</h1>
  
  {#if data.articles?.length}
    <ul>
      {#each data.articles as article}
        <li>
          <strong>{article.title}</strong><br />
          <p>{article.content}</p>
        </li>
      {/each}
    </ul>
  {:else}
    <p>No articles found.</p>
  {/if}
  