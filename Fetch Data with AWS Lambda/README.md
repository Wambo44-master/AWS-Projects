<img src="https://cdn.prod.website-files.com/677c400686e724409a5a7409/6790ad949cf622dc8dcd9fe4_nextwork-logo-leather.svg" alt="NextWork" width="300" />

# Fetch Data with AWS Lambda

**Project Link:** [View Project](http://nextwork.ai/projects/aws-compute-lambda)

**Author:** Nicole Wainaina  

---

## Fetch Data with AWS Lambda

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_p9thryj2)

---

## Introducing Today's Project!

In this project, I will demonstrate how to use AWS Lambda, API gateway and AWS DynamoDB. I'm doing this project to learn how to fetch data using Lambda and this is the data tier of the project.

### Tools and concepts

Services I used were AWS Lambda and DynamoDB. Key concepts I learnt include Lambda functions, creation of a dynamodb table ,writing  code to interact with DynamoDB using the AWS SDK.
I also learned how to test a Lambda function. and how totighten permission settings for your Lambda function.

### Project reflection

This project took me approximately 1 hour. It was most rewarding to review and select permission policies that gave the lambda function access to the dynamodb table.

I chose to do this project today because I wanted to expand my knowledge in the building of a 3 tier architechture and use of AWS lambda.

---

## Project Setup

To set up my project, I created a database using the AWS Management Console and I created a partition key called 'userId'. The partition key is part of the table's primary key which means that each partition key in a table is unique. It is a hash value that is used to retieve data from a table and also allocates data across hosts. This means that the partition key distrubutes data across different servers for availability and scalability.

In my DynamoDB table, I added JSON code as my 
table item.

{
  "userId": "1",
  "name": "Test User",
  "email": "test@example.com"
}

This JSON code defines a new item for our UserData table.

This item represents a user with :
- a userId of 1
- A name of Test User
-An email of test@example.com



DynamoDB is schemaless, which means attributes can be added as you need, and every item in your database can have a different set of attributes. This flexibility is one of the key benefits of using a NoSQL database like DynamoDB.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_a112c3d5)

### AWS Lambda

AWS Lambda is a service that offers serverless computing meaning you don't have to manage underlying services but instead just run code.  Lambda only runs your code when you need i and it is automatically salable .I'm using Lambda in this project to create a function that will be used to retrieve information from a dynamodb table.

---

## AWS Lambda Function

My Lambda function has an execution role, which is an IAM role that defines what your Lambda function is allowed to do. By default, the role grants Lambda basic permissions for writing logs to Cloudwatch.

The first half of the code uses the AWS SDK for JavaScript to interact with DynamoDB.

It takes a userId as input, grabs the corresponding data from the UserData table, and returns it to you.

The second half of the code (i.e. beginning with try {) handles potential errors during the database operation, so you get a tailored error message that tells you what went wrong.

The code uses AWS SDK, which is a is a set of tools that let developers build apps that interact with AWS. My code uses SDK to code uses the AWS SDK to use pre-written functions for communicating with DynamoDB and getting data from a table. Without the SDK, I'd have to manually write the code to interact with AWS, which would be much more complex and error-prone.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_a1b2c3d5)

---

## Function Testing

To test whether my Lambda function works, I n this test, I am asking the Lambda function to search for an item in the previously created DynamDB table. The item needs to have a userID of 1 .The test is written in  JSON to input test data to ensure it's in a format that’s easy for Lambda to understand and work with.

The test displayed a 'success' because the function itself could run but it doesn't mean the function achieved what it was supposed to do. I got an error because even though I created an execution role for the Lambda function, I haven't given it explicit permission to access the DynamoDB table. This means DynamoDB is currently blocking off the Lambda function from reading the table's items.

Because Lambda can't read any items, it has no choice but to tell us that its access was denied.



![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_u1v2w3x4)

---

## Function Permissions

To resolve the AccessDenied error, I review the error message first to identify the specific permission that Lambda lacks. Then I will add a permission policy that will give the necessary permissions.

There were four DynamoDB permission policies I could choose from, but I  didn't select AWSLambdaDynamoDBExecutionRole because  it gives the Lambda function the permissions to see a DynamoDB stream (like new, updated, or deleted items) in the last 24 hours and AWSLambdaInvocation-DynamoDB is used to automatically trigger your Lambda functions in response to events captured in DynamoDB stream.


I also didn't pick  AmazonDynamoDBFullAccess because lets you do everything with DynamoDB, like creating, deleting, and managing tables. It also lets you read and write data. This is not a best security practice.

I picked AmazonDynamoDBReadOnlyAccess because it has a GetItem policy that resolves the error message earlier while maintaining best security practices.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_3ethryj2)

---

## Final Testing and Reflection

To validate my new permission settings, I rerun the test on the lambda function. The results were a success message that read that data was successfully retrieved.

Web apps are a popular use case of using Lambda and DynamoDB. For example, Lambda can help customers find products, get product information or see their order history by fetching data from DynamoDB.
Lambda can help social media apps fetch user profiles or automatically retrieve all content (e.g. videos or images) linked with a profile.
Lambda can help news sites or blogs fetch articles based on user queries.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_p9thryj2)

---

## Enahancing Security

For my project extension, I challenged myself to create an inline policy and removed the ReadOnly permission. The inline policy will grant granular permissions for increased security.

To create the permission policy, I used JSON code  because with JSON writing the policy directly.

When updating a Lambda funciton's permission policies, you could risk getting an error message. I validated that my Lambda function still works by rerunning the test and getting a success message.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-lambda_1qthryj2)

---

---
