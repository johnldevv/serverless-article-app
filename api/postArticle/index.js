// api/postArticle/index.js
exports.handler = async (event) => {
    const body = JSON.parse(event.body || '{}');
  
    const response = {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Article received',
        article: {
          title: body.title || 'Untitled',
          content: body.content || ''
        }
      })
    };
  
    return response;
  };
  