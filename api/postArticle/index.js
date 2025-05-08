const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const crypto = require("crypto");

const client = new DynamoDBClient({ region: "ap-southeast-1" });
const TABLE_NAME = "articles-staging";

// Slugify utility
function slugify(text) {
    return text.toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')   // replace non-alphanumeric with -
        .replace(/(^-|-$)/g, '');      // trim dashes
}

exports.handler = async (event) => {
  const body = JSON.parse(event.body || "{}");

  const id = crypto.randomUUID();
  const title = body.title || "Untitled";
  const content = body.content || "";
  const slug = slugify(title);

  const params = new PutItemCommand({
    TableName: TABLE_NAME,
    Item: {
      id: { S: id },
      title: { S: title },
      slug: { S: slug },
      content: { S: content }
    }
  });

  await client.send(params);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Article saved to DynamoDB",
      article: { id, title, slug, content }
    })
  };
};
