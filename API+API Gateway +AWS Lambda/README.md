<img src="https://cdn.prod.website-files.com/677c400686e724409a5a7409/6790ad949cf622dc8dcd9fe4_nextwork-logo-leather.svg" alt="NextWork" width="300" />

# APIs with Lambda + API Gateway

**Project Link:** [View Project](http://nextwork.ai/projects/aws-compute-api)

**Author:** Nicole Wainaina  


---

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_c9d0e1f2)

---

## Introducing Today's Project!

In this project, I will demonstrate building the backend of a web app. Here, I will write and run code that translates user actions to app functionality. I will be using APIs, AWS Lambda and an API gateway. 

Application Programming Interface(APIs) are a set of rules that allow for 2 apps to talk to each other and include GET, POST, PUT etc.

An API gateway is an API traffic controller. It is responsible for routing requests and responses and authorizes requests.

AWS Lambda is a Function as a Service provided by AWS.  It  offers serverless computing whereby developers can run code and are not responsible for managing servers and underlying Operation Systems. AWS Lambda is event driven and it is a pay-as-you-go service.


### Tools and concepts

Services I used were APIS, API gateway and AWS Lambda. Key concepts I learnt include Lambda functionsm, creation of an API, API methods, resources and how to create an API gateway. I also learned about API documentation which is used to clearly explain the function of the API and how users can interact with it. I also learned how to publish documentation using Swagger and in JSON format with an AWS API extension.

### Project reflection

This project took me approximately about one hour. The most challenging part was in creation of API since I had not previously done it. It was most rewarding to review my publised documentation and understand the methods, parameters and functionality of the API I created.

I chose to do this project today because it is the backend of an application and I wanted to understand how Lambda functions and an API gateway work together.

---

## Lambda functions

AWS Lambda is.a serverless compute service that allows developers to run code without worrying about management of underlying servers and infrastructure. I'm using Lambda in this project to create a function that will retrieve data from a database and return it to the user.

The code I added to my function will create a function retrieve data from a DynamoDB table. It looks for specific user data based on 'userId' and return the data. If an error occurs, it will return an error message.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_a1b2c3d5)

---

## API Gateway

APIs are Application Programming Interfaces that are a set of rules for different software systems to communicate.There are different types of APIs, like RESTful APIs and Non-RESTful APIs. My API is RESTful which means it used to transfer data using HTTP. It involves GET, PUT, POST & DELETE requests.

Amazon API Gateway is a front door to the backend of an application. It receives requests and forwards tem to the lamda function for processing. The lambda function's result is returned to the user through an API gateway .I'm using API Gateway in this project as a traffic controller for the API. It is not a best practice to directly expose APIs and an API gateway increases security by applying authorization and authentication of APIs, routing, WAF, traffic management and monitoring capabilities for increased application functionality.

When a user makes a request, the API gateway receives the request and forwards it to the Lambda function(backend) for processing. Once it is processed, the result is sent back to the user through the gateway.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_m3n4o5p6)

---

## API Resources and Methods

An API is made up of resources, which are indivudual endpoints of an API that handle different parts of its functionality.

Each resource consists of methods, which are used to define what you can do with a resource.

I created a GET method which retrieves data.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_c9d0e1f2)

---

## API Deployment

When you deploy an API, you deploy it to a specific stage. A stage is a snapshot of an API at a sepcific point in time. I deployed to the prod stage

To visit my API, I clicked on the invoke URL which is the URL where my API can be used. The API displayed an error because the API is meant to invoke a Lambda function that retrieves data froma  dynamodb table which has not yet been set up hence the error.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_3ethryj2)

---

## API Documentation

For my project's extension, I am writing API documentation because API documentation is a detailed description of an API's functionality including its endpoints, methods, parameters and responses. You can do this in JSON and it is crucial in understanding how to use APIs effectively.

Once I prepared my documentation, I can publish it to the prod stage to ensure the documentation is consistent with the API version deployed to that stage.  Publishing my documentation lets me  export my work in a special file type (either Swagger or OpenAPI). Then, I can use external tools like Swagger UI or ReDoc can then use my OpenAPI documentation to generate beautiful, interactive web pages about my API.

This lets other developers explore your API directly through their browsers.

My published and downloaded documentation showed me my customised API documentation and API gateway automatically generated documentation whcih included metadata like my API's version and title, resources (/users), and methods (like GET) I can perform on these endpoints.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-api_z9a0b1c2)

---

---
