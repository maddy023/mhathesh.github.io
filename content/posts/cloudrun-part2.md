---
date: 2024-11-06
# description: ""
# image: ""
lastmod: 2024-11-06
showTableOfContents: false
tags: ["GCP","Github Actions", "CI/CD"]
title: "Part 2: Rolling Up Your Sleeves: Building, Pushing, and Deploying like a Pro"
type: "post"
draft: true
---

### Part 2: Rolling Up Your Sleeves: Building, Pushing, and Deploying like a Pro 

Welcome to Part 2 of our series on deploying applications to Google Cloud Run via a CI/CD pipeline. In Part 1, we covered the initial setup, including creating a Google Cloud project, configuring required APIs, and setting up service accounts. Now, in Part 2, we’ll dive into the heart of the deployment pipeline.

This segment will focus on configuring the GitHub Actions workflow for seamless deployment to Cloud Run. You’ll learn how to build and push Docker images, deploy them to Cloud Run, manage traffic routing, and set up automated rollback in case of deployment failures. By the end of Part 2, you’ll have a fully operational pipeline, ensuring reliable and efficient application releases to Cloud Run.


### Below is a breakdown of each section and step in the YAML file used for deploying a containerized application to Google Cloud Run through a CI/CD pipeline using GitHub Actions.


### **Environment Variables**

```yaml
env:
  IMAGE_NAME: "app-api"
  PROJECT_ID: "maddy-proj1"
  ARTIFACT_REGION: "us-central1"
  ARTIFACT_REPOSITORY_NAME: "app-api-ar"
  CLOUD_RUN_SERVICE_NAME: "app-api-ar-cr"` 
```

These are the environment variables required for the deployment:

-   **`IMAGE_NAME`**: Name of the Docker image to be used for deployment
-   **`PROJECT_ID`**: The GCP project ID where the resources are located
-   **`ARTIFACT_REGION`**: The region where Artifact Registry is located
-   **`ARTIFACT_REPOSITORY_NAME`**: The name of the Artifact Registry repository
-   **`CLOUD_RUN_SERVICE_NAME`**: The name of the Cloud Run service to deploy

These environment variables make the pipeline more flexible by allowing easy configuration of project details.



### **Steps in the Job**

#### **Step 1: Checkout Code**

```yaml
- name: Checkout
  uses: actions/checkout@v4` 
```

-   This step checks out the code from the GitHub repository. It is necessary so that the workflow can access the repository's contents (such as Dockerfiles, application code, etc.) to build the Docker image.

#### **Step 2: Authenticate with Google Cloud**

```yaml
- name: Authenticate with Google Cloud
  uses: google-github-actions/auth@v2
  with:
    credentials_json: ${{ secrets.SA_SERVICE_KEY }}` 
```

-   **`google-github-actions/auth@v2`**: This action authenticates the GitHub Actions runner to Google Cloud. It uses the service account key stored in GitHub Secrets (`SA_SERVICE_KEY`).
    
-   **`credentials_json`**: This key is critical for authentication. It is a service account JSON key that grants the GitHub Actions runner access to Google Cloud APIs to interact with resources (such as Cloud Run, Artifact Registry, etc.).
    

**Note**: The `SA_SERVICE_KEY` secret must be stored securely in GitHub secrets. It should contain the JSON credentials for a Google Cloud service account with the appropriate permissions (such as `roles/run.admin` for Cloud Run and `roles/artifactregistry.admin` for Artifact Registry).


#### **Step 3: Extract Branch Name**

```yaml
- name: Extract branch name
  id: extract_branch
  shell: bash
  run: echo "##[set-output name=branch;]$(echo ${GITHUB_REF#refs/heads/})"` 
```

-   **`name`**: This is a descriptive name for the step. It simply indicates that the branch name will be extracted.
-   **`id`**: The `id` is used to refer to the output of this step later in the pipeline. In this case, the branch name will be stored with the identifier `extract_branch`.
-   **`shell: bash`**: Specifies that the step will use the Bash shell to execute the commands.
-   **`run`**: This line extracts the branch name from the GitHub environment variable `GITHUB_REF`, which contains the full reference of the GitHub branch or tag. The expression `${GITHUB_REF#refs/heads/}` strips the `refs/heads/` prefix from the reference, leaving only the branch name (e.g., `dev` or `feature-branch`).
-   **`set-output`**: This command sets an output named `branch`, which will store the extracted branch name. This output can be used in later steps to dynamically adjust configurations (such as naming the Artifact Registry repository per branch).


### **Step 4: Set Up Google Cloud CLI**

```yaml
- name: Set up Google Cloud CLI
  uses: google-github-actions/setup-gcloud@v2
  with:
    version: '449.0.0'
    project_id: ${{ env.PROJECT_ID }}` 
```

This step ensures that the GitHub runner can communicate with Google Cloud services using the `gcloud` CLI and allows it to deploy and manage Cloud Run services, interact with Artifact Registry, and more.


### **Step 5: Create Artifact Repository & Check if Repository Exists**

```yaml
- name: Create Artifact Repository & Check if Artifact Registry Repository Exists
  id: check-repository
  run: |
    ARTIFACT_REGISTRY_REPO_NAME="${{ env.ARTIFACT_REPOSITORY_NAME }}-${{ steps.extract_branch.outputs.branch }}"
    ARTIFACT_REGISTRY_REGION="${{ env.ARTIFACT_REGION }}" 
    REPO_LIST=$(gcloud artifacts repositories list --location="${ARTIFACT_REGISTRY_REGION}" --format="value(name)")

    if [[ $REPO_LIST == *"${ARTIFACT_REGISTRY_REPO_NAME}"* ]]; then
      echo "Artifact Registry repository already exists."
    else
      echo "Artifact Registry repository does not exist."
      echo "Creating Artifact Registry repository..."
      gcloud artifacts repositories create "${ARTIFACT_REGISTRY_REPO_NAME}" --location="${ARTIFACT_REGISTRY_REGION}" --repository-format=DOCKER
    fi` 
```

-   **`name`**: This step is named "Create Artifact Repository & Check if Artifact Registry Repository Exists". It checks if the required Artifact Registry repository exists and creates it if it doesn't.
-   **`id`**: This step is given the identifier `check-repository` to reference it later if necessary.
-   **`run`**: The actual shell commands executed in this step.
    -   **`ARTIFACT_REGISTRY_REPO_NAME`**: This variable is constructed by combining the environment variable `ARTIFACT_REPOSITORY_NAME` (from the pipeline) and the branch name extracted in Step 1. This ensures that each branch (e.g., `dev` or `feature-branch`) has its own repository in Artifact Registry. For example, if the branch name is `dev`, the repository name would be `app-api-ar`.
    -   **`ARTIFACT_REGISTRY_REGION`**: This variable specifies the region of the Artifact Registry repository (e.g., `us-central1`).
    -   **`REPO_LIST`**: This command lists all repositories in the specified Artifact Registry region.
    -   **Check if Repository Exists**: The `if` condition checks if the constructed repository name (`ARTIFACT_REGISTRY_REPO_NAME`) already exists in the list of repositories. If it exists, it prints a message confirming that the repository is already present.
    -   **Create Repository**: If the repository does not exist, it uses the `gcloud` CLI to create a new Artifact Registry repository with the Docker format. The repository is created in the specified region (`ARTIFACT_REGISTRY_REGION`).

This step ensures that an Artifact Registry repository exists for storing Docker images, which will later be deployed to Google Cloud Run.

### **Step 4: Configure Docker Client for Artifact Registry**

```yaml
- name: Configure Docker Client for Artifact Registry
  run: |-
    gcloud auth configure-docker $ARTIFACT_REGION-docker.pkg.dev --quiet` 
```

-   **`name`**: This step is named "Configure Docker Client for Artifact Registry." It ensures that the Docker client used in the pipeline is set up to push and pull images from Google Cloud's Artifact Registry.
-   **`run`**: This command uses `gcloud` to authenticate Docker with Artifact Registry, so that the pipeline can push Docker images to the Artifact Registry repository. The `$ARTIFACT_REGION` variable is used to specify the region (e.g., `us-central1`), and the `--quiet` flag suppresses any unnecessary output.
-   **Purpose**: This step prepares the GitHub Actions runner to interact with Google Cloud Artifact Registry by configuring Docker with the proper credentials.


### **Step 6: Build Docker Image & Push Docker Image to Artifact Registry**

```yaml
- name: Build Docker Image & Push Docker Image to Artifact Registry
  env:
    ARTIFACT_REGISTRY_REPO_NAME: ${{ env.ARTIFACT_REPOSITORY_NAME }}-${{ steps.extract_branch.outputs.branch }}
  run:  |-
    docker build -t $ARTIFACT_REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO_NAME/$IMAGE_NAME:${{ github.sha }} .
    docker push $ARTIFACT_REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO_NAME/$IMAGE_NAME:${{ github.sha }}` 
```

-   **`name`**: The step is named "Build Docker Image & Push Docker Image to Artifact Registry," which describes the process of building the Docker image from the source code and pushing it to the Artifact Registry.
-   **`env`**:
    -   **`ARTIFACT_REGISTRY_REPO_NAME`**: This variable is dynamically created based on the branch name (extracted earlier in the pipeline) to name the Artifact Registry repository uniquely for each branch.
-   **`run`**:
    -   The `docker build` command builds the Docker image with the tag format:
        `$ARTIFACT_REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO_NAME/$IMAGE_NAME:${{ github.sha }}` 
        This includes the region, project ID, repository name, image name, and the unique commit SHA (`${{ github.sha }}`), ensuring that each Docker image is versioned and associated with a specific commit.
    -   The `docker push` command then uploads the built image to Artifact Registry under the specified tag.
-   **Purpose**: This step automates the process of building a Docker image from the codebase and uploading it to Artifact Registry, which is then used for deployment to Cloud Run.


### **Step 7: Deploy to Cloud Run**

```yaml
- name: Deploy to Cloud Run
  id: deploy-to-cloud-run
  env:
    ARTIFACT_REGISTRY_REPO_NAME: ${{ env.ARTIFACT_REPOSITORY_NAME }}-${{ steps.extract_branch.outputs.branch }}
  run: |
    gcloud run deploy $CLOUD_RUN_SERVICE_NAME --image=$ARTIFACT_REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO_NAME/$IMAGE_NAME:${{ github.sha }} --platform=managed --region=$ARTIFACT_REGION --allow-unauthenticated --quiet` 
```

-   **`name`**: The step is named "Deploy to Cloud Run," and it uses the `gcloud` CLI to deploy the newly built Docker image to Cloud Run.
-   **`id`**: This step is given the identifier `deploy-to-cloud-run` for referencing in later steps if needed.
-   **`env`**: Similar to the previous steps, the `ARTIFACT_REGISTRY_REPO_NAME` is dynamically set using the branch name.
-   **`run`**:
    -   The `gcloud run deploy` command is used to deploy the Docker image to Google Cloud Run. It specifies the service name (`$CLOUD_RUN_SERVICE_NAME`), the image (`$ARTIFACT_REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY_REPO_NAME/$IMAGE_NAME:${{ github.sha }}`), the region (`$ARTIFACT_REGION`), and the `--allow-unauthenticated` flag to allow public access to the deployed service.
    -   The `--platform=managed` option specifies that the service is deployed on the managed platform of Cloud Run.
    -   The `--quiet` flag suppresses unnecessary output.
-   **Purpose**: This step handles the actual deployment of the Docker image to Cloud Run, making it available for use.

### **Step 8: Set Traffic to Latest Revision**

```yaml
- name: Set Traffic to Latest
  if: success()
  run: |
    gcloud run services update-traffic $CLOUD_RUN_SERVICE_NAME --region=$ARTIFACT_REGION --to-latest` 
```

-   **`name`**: This step sets the traffic of the Cloud Run service to the latest deployed revision.
-   **`if: success()`**: This condition ensures that the step only runs if the previous deployment step succeeded.
-   **`run`**: The `gcloud run services update-traffic` command is used to direct all incoming traffic to the latest revision of the deployed service. This ensures that users will always be routed to the most recent deployment.
-   **Purpose**: This step ensures that the latest deployment is fully live and receives all traffic.

### **Step 9: List Revisions**

```yaml
- name: List Revisions
  if: success()
  id: list-revision
  run: |
    REVISIONS=$(gcloud run revisions list --service=$CLOUD_RUN_SERVICE_NAME --region=$ARTIFACT_REGION --format="value(name)")
    LATEST_REVISION=$(echo "$REVISIONS" | awk '{print $0; exit}')
    echo "Latest revision: $LATEST_REVISION"
    echo "::set-output name=latest-revision::$LATEST_REVISION"` 
```

-   **`name`**: This step lists all revisions for the Cloud Run service to identify the latest revision.
-   **`if: success()`**: This condition ensures that the step only runs if the previous step was successful.
-   **`id: list-revision`**: The identifier for this step is `list-revision`, which is useful if the revision needs to be referenced in later steps.
-   **`run`**:
    -   The `gcloud run revisions list` command lists all revisions of the Cloud Run service.
    -   The `awk` command is used to extract the name of the latest revision from the list.
    -   The latest revision name is then set as an output (`latest-revision`) for future reference in the pipeline.
-   **Purpose**: This step provides the latest revision name, which can be used for monitoring or rollback purposes.


### **Step 10: Check Deployment Status**

```yaml
- name: Check Deployment Status
  id: check-deployment-status
  if: failure()
  run: |
    if gcloud run services describe $CLOUD_RUN_SERVICE_NAME --region=$ARTIFACT_REGION --format="value(status.url)" > /dev/null; then
      echo "Deployment to Cloud Run was successful."
    else
      echo "Deployment to Cloud Run failed."
      echo "::error::Deployment to Cloud Run failed."` 
```

-   **`name`**: This step checks the status of the deployment to verify whether the Cloud Run service was successfully deployed.
-   **`id`**: The step identifier is `check-deployment-status`, which can be referenced for debugging or failure handling.
-   **`if: failure()`**: This condition ensures that the step runs only if the previous deployment step failed.
-   **`run`**:
    -   The `gcloud run services describe` command checks the status URL of the Cloud Run service to verify its deployment status.
    -   If the service is successfully deployed, it will output a success message; otherwise, it will mark the step as a failure.
-   **Purpose**: This step helps detect issues with the deployment and outputs an error message if the deployment fails.

### Conlusion

we focused on the steps involved in building and deploying your containerized application to Cloud Run using GitHub Actions. We outlined the process of authenticating with Google Cloud, configuring the Docker client, building and pushing the Docker image to Artifact Registry, and deploying it to Cloud Run. Additionally, we explored how traffic is routed to the latest deployment to ensure that users always have access to the newest version of the application.

By automating these tasks within your CI/CD pipeline, you streamline the deployment process and ensure that your application can be quickly and reliably deployed to Cloud Run with every code change, reducing manual intervention and accelerating development cycles.

## Jim Face… if You Skip These Must-Reads 😐

[Part 1: Setting the Stage: Your Cloud Run Setup Adventure]({{< ref "cloudrun-part2" >}})

[Part 3: Oops, Something Went Wrong! Let’s Roll Back to the Rescue]({{< ref "cloudrun-part3" >}})

[Part 1: Preparing Your Environment and Setting Up AKS for Ollama Models]({{< ref "ollama-part1" >}})