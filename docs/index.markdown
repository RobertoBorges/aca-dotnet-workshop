
![Azure Container Workshop](assets/images/00-workshop-intro/azure-container-apps-image.png)

There is no doubt that building containerized applications and following a microservices architecture is one of the most common software architecture patterns observed in the past couple of years.

Microsoft Azure offers different services to package, deploy and manage cloud-native applications, each of which serves a certain purpose and has its own pros and cons. The following table lists the different container options offered by Microsoft Azure:

| Service | Description |
| --- | ---: |
|If you want to Use| this|
|Deploy and scale containers on managed Kubernetes|	[Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/)|
|Deploy and scale containers on managed Red Hat OpenShift	|[Azure Red Hat OpenShift](https://azure.microsoft.com/en-us/services/openshift/)|
|Build and deploy modern apps and microservices using serverless containers	|[Azure Container Apps](https://azure.microsoft.com/en-us/services/container-apps/)|
|Execute event-driven, serverless code with an end-to-end development experience	|[Azure Functions](https://azure.microsoft.com/en-us/services/functions/)|
|Run containerized web apps on Windows and Linux	|[Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/)|
|Launch containers with hypervisor isolation	|[Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/)|
|Deploy and operate always-on, scalable, distributed apps	|[Azure Service Fabric](https://azure.microsoft.com/en-us/services/service-fabric/)|
|Build, store, secure, and replicate container images and artifacts	|[Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/)|

[Reference: Container Services ](https://azure.microsoft.com/en-us/products/category/containers/)

Indeed, the use of containers introduces an array of possibilities, as they allow you to construct and operate your software anywhere you desire. However, selecting the appropriate infrastructure for running your containerized application is a pivotal decision that should be carefully made. This choice should take into consideration the specific demands of your application, the business requirements, and the expertise of your team.

In this workshop, we will explore the most popular options on Azure to deploy Containers. The goal is to provide you with a solid understanding of the different options available, and the ability to make an informed decision on which option to use for your next project.

##### Acknowledgment:
The workshop's material, concepts, and code samples draw inspiration from a collection of blog articles authored by [Taiseer Joudeh](https://github.com/tjoudeh) and published on his [personal blog](https://bitoftech.net). The [Azure Containers Apps](https://azure.github.io/aca-dotnet-workshop/) was the inspiration to build this workshop. Feel free to check out his blog for more information on the topics covered in this workshop.
