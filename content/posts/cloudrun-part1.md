---
date: 2024-11-06
# description: ""
# image: ""
lastmod: 2024-11-06
showTableOfContents: true
tags: ["GCP","Github Actions", "CI/CD"]
title: "Part 1: Setting the Stage: Your Cloud Run Setup Adventure"
type: "post"
draft: true
---
In this blog, we’ll dive into setting up a CI/CD pipeline for deploying applications to Google Cloud Run. Cloud Run provides a fully managed serverless environment for containerized applications, making it ideal for scalable, microservices-based deployments. This guide walks through configuring a GitHub Actions workflow that builds, pushes, and deploys Docker images to Cloud Run, with added steps for rollback in case of failures.

Whether you're looking to streamline deployments or improve reliability with automated rollbacks, this step-by-step tutorial will help you set up a robust pipeline for Cloud Run deployments.

#### Prerequisites

-   A GCP account with permissions to create projects, manage APIs, and configure IAM roles.
-   Terraform configured locally if you’re using it to manage infrastructure as code.

### Step 1: Create a GCP Project and Enable Required APIs

Start by creating a new GCP project if you haven’t done so already. This project will host the Cloud Run service and other required resources. Once the project is created, you’ll need to enable specific APIs to support Cloud Run and related services, or via [terraform](https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/examples/simple_project).

Here’s a list of essential APIs to enable:

```text
activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "domains.googleapis.com",
    "run.googleapis.com",
    "storage.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
]
```

These APIs cover services required for Cloud Run, container storage, and database management

#### Enable APIs

To enable these APIs, use either the `gcloud` CLI or do so via the Google Cloud Console under **APIs & Services > Library**. If you’re using Terraform, you can also [automate API activation](https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/examples/project_services).

### Step 2: Create a Service Account with Required Roles

Next, create a dedicated service account (SA) with the necessary roles. This account will handle permissions for deploying and managing Cloud Run, interacting with storage, and setting up network configurations.

1.  **Define the Service Account**: Choose a name for your service account. In this example, we’re using `yoda-sa`.
    
2.  **Assign Roles**: Assign the following roles to the service account:

```text    
project_sa_roles = [
        "roles/storage.admin",
        "roles/run.admin",
        "roles/artifactregistry.admin",
        "roles/iam.serviceAccountUser",
        "roles/compute.loadBalancerAdmin"
]
```

Each role is essential for managing specific GCP services:

-   `storage.admin`: Grants permissions for Google Cloud Storage interactions.
-   `run.admin`: Provides full access to deploy and manage Cloud Run services.
-   `artifactregistry.admin`: Allows access to Artifact Registry, where container images are stored.
-   `iam.serviceAccountUser`: Permits the service account to be used by other resources and services.
-   `compute.loadBalancerAdmin`: Required for handling load balancer configurations if needed.

### Step 3: Deploy Cloud Run and Configure Container Registry

Ensure that a Cloud Run instance is deployed within your GCP project. This can be done through the Google Cloud Console, the `gcloud` CLI, or, if you’re using infrastructure as code, via Terraform.

1.  **Deploy Cloud Run with Terraform**: If you’re managing deployments with Terraform, configure the Cloud Run service in your `.tf` files and apply the changes to deploy it.
2.  **Container Registry Configuration**: Make sure that your Container Registry or Artifact Registry is set up to store and serve container images.

### Step 4: Configure GitHub Actions with Service Account Keys

For a CI/CD pipeline, integrate your GCP service account into GitHub Actions to automate Cloud Run deployments. Store the service account credentials securely in GitHub secrets:

1.  **Generate JSON Key**: Create a key for the service account in the [JSON format.](https://cloud.google.com/iam/docs/keys-create-delete)

```sh   
gcloud iam service-accounts keys create key.json \
      --iam-account=yoda-sa@[PROJECT_ID].iam.gserviceaccount.com
```

2.  **Add Secrets to GitHub**: In your GitHub repository, go to **Settings > Secrets and Variables > Actions**, and add a new repository secret with the content of the JSON key.

### Conlusion

we walked through the initial setup needed to deploy an application on Cloud Run via a GitHub Actions pipeline. This included creating a Google Cloud Project, enabling essential APIs, and setting up a Service Account with the required roles. These foundational steps are crucial for ensuring that the pipeline has the right permissions and that all necessary services are available for deployment.

### Stanley Only Runs… for Blogs Like These

[Part 2: Rolling Up Your Sleeves: Building, Pushing, and Deploying like a Pro]({{< ref "cloudrun-part2" >}})

[Part 3: Oops, Something Went Wrong! Let’s Roll Back to the Rescue]({{< ref "cloudrun-part3" >}})