exports.handler = async () => {
    // Placeholder response
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Articles fetched (static)',
        articles: [
          { id: 1, title: 'Example Article', content: 'Hello world' }
        ]
      })
    };
  };
  