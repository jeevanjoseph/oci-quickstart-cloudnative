![MuShop Logo](./images/logo.png)

---

This is a Terraform configuration that deploys the MuShop basic sample application on [Oracle Cloud Infrastructure (OCI)][oci]. 

MuShop basic is a 3-tier web application that implements an e-commerce site. It is built to showcase the features of [Oracle Cloud Infrastructure (OCI)][oci]. This application is designed to run using only the Always Free tier resources. 
The repository contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack, 
that creates all the required resources and configures the application on the created resources.

| ![home](./images/screenshot/mushop.home.png) | ![browse](./images/screenshot/mushop.browse.png) | ![cart](./images/screenshot/mushop.cart.png) | ![about](./images/screenshot/mushop.about.png) |
|---|---|---|---|

## Getting Started

The steps below guide you through deploying the application on your tenancy using the OCI Resource Manager.

1. Download the latest [`mushop-v1.0.0-basic-stack.zip`](../../releases/download/v1.0.0/mushop-v1.0.0-basic-stack.zip) file.
2. [Login](https://console.us-phoenix-1.oraclecloud.com/resourcemanager/stacks/create) to Oracle Cloud Infrastructure to import the stack
    > `Home > Solutions & Platform > Resource Manager > Stacks > Create Stack`
3. Upload the `mushop-v1.0.0-basic-stack.zip` file that was downloaded earlier, and provide a name and description for the stack
4. Configure the stack
   1. **Database Name** - You can choose to provide a database name (optional)
   2. **Node Count** - Select if you want to deploy one or two application instances.
   3. **Availability Domain**  - Select the availability domain where you have Always Free compute resources. If you run in to service limits, you could try another availability domain.
   > In regions with multiple availability domains, Always Free compute resources are available only in one of the availability domains. To find where your Always Free compute resources are, navigate to `Home > Governance > Limits, Quotas and Usage`. Select Compute as the service and cycle through the availability domains in the scope drop-down. The service limit column shows the limits for each reosurce type. Always Free compute resources are VMs of shape `VM.Standard.E2.1.Micro`. Check for this shape, and you will see one AD where you were allocated capacity. Note that paid services are always available in all availability domains where applicable.
5. Review the information and click Create buton. 
   > The upload can take a few seconds, after which you will be taken to the newly created stack
6. On Stack details page, click on `Terraform Actions > Apply`

All the resources will be created, and the URL to the load balancer will be displayed as `lb_public_url` as in the example below.
> The same information is displayed on the Application Information tab

```text
Outputs:

autonomous_database_password = <generated>

comments = The application URL will be unavailable for a few minutes after provisioning, while the application is configured

dev = Made with ❤ by Oracle A-Team

lb_public_url = http://xxx.xxx.xxx.xxx 
```

> The application is being deployed to the compute instances asynchronously, and it may take a couple of minutes for the URL to serve the application.

## Deployment Topology

The following diagram shows the topology created by this stack.

![MuShop Basic Infra](./images/basic/00-Topology.png)

To learn more about how you can use this application to build your own applications, click [here](./deploy/basic/README.md).

## License

Copyright © 2019, Oracle and/or its affiliates. All rights reserved.

The Universal Permissive License (UPL), Version 1.0

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[tf]: https://www.terraform.io
