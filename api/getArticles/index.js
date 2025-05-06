const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "ap-southeast-1" });
const TABLE_NAME = "articles-staging";

exports.handler = async () => {
  const command = new ScanCommand({ TableName: TABLE_NAME });
  const result = await client.send(command);

  const articles = result.Items.map(item => ({
    id: item.id.S,
    title: item.title.S,
    content: item.content.S
  }));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Articles fetched from DynamoDB",
      articles
    })
  };
};
