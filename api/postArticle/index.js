const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const crypto = require("crypto");

const client = new DynamoDBClient({ region: "ap-southeast-1" });
const TABLE_NAME = "articles-staging";

exports.handler = async (event) => {
  const body = JSON.parse(event.body || "{}");

  const id = crypto.randomUUID();
  const title = body.title || "Untitled";
  const content = body.content || "";

  const params = new PutItemCommand({
    TableName: TABLE_NAME,
    Item: {
      id: { S: id },
      title: { S: title },
      content: { S: content }
    }
  });

  await client.send(params);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Article saved to DynamoDB",
      article: { id, title, content }
    })
  };
};
