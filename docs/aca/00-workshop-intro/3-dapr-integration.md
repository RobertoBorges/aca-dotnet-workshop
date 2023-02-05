---
title: Dapr Integration in ACA  
parent: Workshop Introduction
has_children: false
nav_order: 3
---

## Dapr Overview
As developers, we are often tasked to create scalable resilient and distributed applications as microservices, but face the same challenges such as recovering state after failures, services discovery and calling other microservices, integration with external resources, asynchronous communications between different services, distributed tracing and measuring message calls and performance across components and networked services.

Dapr (Distributed Application Runtime) offers a solution for the common problems that needed in any distributed microservice application. Dapr can be used with any language (Go, .NET python, Node, Java, C++) and can run anywhere (On-premise, Kubernetes, Azure Cloud, GCP, AWS, IBM, etc...)

Dapr core component is the [Building Block](https://docs.dapr.io/concepts/building-blocks-concept/), Dapr supports so far 9 Building Blocks. Building Block in a simple words is a modular component which encapsulates best practices and can be accessed over standard HTTP or gRPC APIs.

Building Blocks address common challenges in building resilient, microservices applications and implement best practices and patterns. Building Blocks provide a consistent APIs and abstracting away the implementation details to keep your code simple and portable.

The diagram below shows the 9 Building Blocks which exposes public API that can be called from your code, and can be configured using [components](https://docs.dapr.io/concepts/components-concept/) to implement the building blocks’ capability. Remember that you can pick whatever building block suites your distributed microservice application and you can incorporate other building blocks as needed.

![Dapr Building Blocks](/assets/images/00-workshop-intro/DaprBuildingBlocks.jpg)

## Dapr & Microservices

Dapr exposes its Building Blocks and components through a **sidecar architecture**. A sidecar enables Dapr to run in a separate memory process or separate container alongside your service. Sidecars provide isolation and encapsulation as they aren't part of the service, but connected to it. This separation enables each to have its own runtime environment and be built upon different programming platforms.

![Dapr SideCar](/assets/images/00-workshop-intro/ACA-Tutorial-DaprSidecar-s.jpg)

This pattern is named Sidecar because it resembles a sidecar attached to a motorcycle. In the previous figure, note how the Dapr sidecar is attached to your service to provide distributed application capabilities.

## Dapr usage in the workshop

We are going to enable Dapr for all Azure Container Apps in the solution, the Dapr APIs/Building Blocks used in this workshop are:

* **Service to Service invocation**: "ACA Web App-Frontend" microservice invokes the "ACA WebAPI-Backend" microservice using Dapr sidecar.
* **State Management**: "ACA WebAPI-Backend" stores data on Azure Cosmos DB and store email logs on Azure Table Storage using Dapr State Management building blocks.
*** Pub/Sub**: "ACA WebAPI-Backend" publishes messages to Azure Service Bus when a task is saved and the "ACA Processor-Backend" microservices consumes those messages and sends emails using SendGrid.
* **Bindings**: "ACA Processor-Backend" is triggered based on an incoming event such as a Cron job.