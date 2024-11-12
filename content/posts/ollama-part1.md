---
date: 2024-10-27T18:03:38-04:00
# description: ""
# image: ""
showTableOfContents: false
tags: ["k8s","llama3","llm","genAI"]
title: "Part 1: Preparing Your Environment and Setting Up AKS for Ollama Models"
type: "post"
---

# Part 1: Preparing Your Environment and Setting Up AKS for Ollama Models

In this guide, we will explore the step-by-step process of deploying Ollama models in an Azure Kubernetes Service (AKS) cluster. We will cover the necessary prerequisites, including setting up a GPU node pool to optimize performance for machine learning tasks, and using Helm charts to manage the deployment of the GPU operator, which is crucial for handling GPU resources effectively. This guide assumes that your AKS cluster is already deployed and configured, and we will provide detailed commands and configurations to ensure a smooth deployment process.

## Step 1: Creating a GPU Node Pool

To optimize the performance of machine learning models, it's beneficial to leverage GPU resources. Here’s how to add a [GPU node pool to your AKS cluster](https://learn.microsoft.com/en-us/azure/aks/spot-node-pool):

```bash
$ az aks nodepool add \
    --resource-group ssai-k8s \
    --cluster-name ssai-k8s \
    --name gpuspot \
    --node-count 1 \
    --enable-cluster-autoscaler \
    --node-vm-size Standard_NC4as_T4_v3 \
    --node-taints accelerated-app=yes:NoSchedule \
    --priority Spot \
    --eviction-policy Delete \
    --spot-max-price -1 \
    --skip-gpu-driver-install \
    --min-count 1 \
    --max-count 2
```
- **`az aks nodepool add`**: This command is used to add a new node pool to your Azure Kubernetes Service (AKS) cluster.
- **`--resource-group ssai-k8s`**: Specifies the resource group that contains your AKS cluster.
- **`--cluster-name ssai-k8s`**: Indicates the name of your AKS cluster where the node pool will be added.
- **`--name gpuspot`**: Assigns a name to the new node pool, in this case, `gpuspot`.
- **`--node-count 1`**: Sets the initial number of nodes in the pool to 1.
- **`--enable-cluster-autoscaler`**: Enables the cluster autoscaler, which automatically adjusts the number of nodes in the pool based on resource demand.
- **`--node-vm-size Standard_NC4as_T4_v3`**: Specifies the VM size for the nodes, optimized for GPU workloads.
- **`--node-taints accelerated-app=yes:NoSchedule`**: Applies a taint to the nodes, ensuring that only pods with matching tolerations can be scheduled on them.
- **`--priority Spot`**: Indicates that the node pool will use spot instances, which are cost-effective but can be evicted when Azure needs the capacity.
- **`--eviction-policy Delete`**: Sets the eviction policy for the spot instances to delete, meaning that when they are evicted, they will be removed from the cluster.
- **`--spot-max-price -1`**: Allows the spot instances to be provisioned at any price, as long as it is below the on-demand price.
- **`--skip-gpu-driver-install`**: Skips the automatic installation of GPU drivers, which can be handled later via gpu operator.
- **`--min-count 1`**: Sets the minimum number of nodes in the pool to 1.
- **`--max-count 2`**: Sets the maximum number of nodes in the pool to 2, allowing for scaling based on demand.


## Step 2: Deploying the GPU Operator via Helm Chart

The GPU operator is essential for managing GPU resources within your Kubernetes cluster. We will deploy the GPU operator using Helm charts. Follow these steps:

### Installing Node Feature Discovery

First, install the Node Feature Discovery (NFD), which is essential for identifying the hardware features of your nodes. This tool plays a critical role in ensuring that your Kubernetes cluster can effectively utilize the available hardware resources, particularly when working with GPU workloads.

To install the Node Feature Discovery, execute the following Helm command:

```bash
helm upgrade --install --wait --create-namespace -n gpu-operator node-feature-discovery node-feature-discovery \
    --repo https://kubernetes-sigs.github.io/node-feature-discovery/charts \
    --set-json master.config.extraLabelNs='["nvidia.com"]' \
    --set-json worker.tolerations='[{ "effect": "NoSchedule", "key": "sku", "operator": "Equal", "value": "gpu"}, { "effect": "NoSchedule", "key": "kubernetes.azure.com/scalesetpriority", "value":"spot", "operator": "Equal"}, { "effect": "NoSchedule", "key": "mig", "value":"notReady", "operator": "Equal"}]'
```

This command performs the following actions:
- **`upgrade --install`**: Ensures that if NFD is already installed, it will be upgraded to the latest version; otherwise, it will be installed fresh.
- **`--wait`**: The command will wait until all resources are in a ready state before completing, ensuring a smooth installation process.
- **`--create-namespace -n gpu-operator`**: This creates a new namespace called `gpu-operator` if it does not already exist, isolating the resources related to GPU operations.
- **`--repo`**: Specifies the Helm chart repository from which to fetch the Node Feature Discovery chart.
- **`--set-json master.config.extraLabelNs`**: This sets additional label namespaces, allowing for better identification of nodes with NVIDIA GPUs.
- **`--set-json worker.tolerations`**: Configures tolerations for the worker nodes, enabling the NFD pods to run on nodes with specific taints. This is crucial for ensuring that the NFD can operate on nodes designated for GPU workloads, including those that are spot instances or have specific configurations.


### Creating a Custom Rule for NVIDIA GPUs

After enabling [Node Feature Discovery](https://artifacthub.io/packages/helm/node-feature-discovery/node-feature-discovery?modal=install), it's essential to create a custom rule to precisely match NVIDIA GPUs on the nodes. Start by creating a file called `nfd-gpu-rule.yaml` with the following content:	

```yaml
apiVersion: nfd.k8s-sigs.io/v1alpha1
kind: NodeFeatureRule
metadata:
    name: nfd-gpu-rule
spec:
    rules:
    - name: "nfd-gpu-rule"
        labels:
        "feature.node.kubernetes.io/pci-10de.present": "true"
        matchFeatures:
        - feature: pci.device
            matchExpressions:
            vendor: {op: In, value: ["10de"]}
```

Apply the custom rule using the command below:

```bash
kubectl apply -n gpu-operator -f nfd-gpu-rule.yaml
```

### Installing the GPU Operator

After successfully setting up the Node Feature Discovery, the next crucial step is to deploy the [GPU operator](https://github.com/NVIDIA/gpu-operator/tree/main). The GPU operator is a powerful tool that automates the management of GPU resources in your Kubernetes cluster. It simplifies the deployment and management of NVIDIA GPU drivers, the device plugin, and other necessary components, ensuring that your applications can efficiently utilize GPU resources.

To deploy the GPU operator, use the following Helm command:

```bash
helm upgrade --install --wait gpu-operator -n gpu-operator nvidia/gpu-operator \  
    --set-json daemonsets.tolerations='[{ "effect": "NoSchedule", "key": "sku", "operator": "Equal", "value": "gpu"}]'
```

This command does the following:
- **`upgrade --install`**: This option ensures that if the GPU operator is already installed, it will be upgraded to the latest version. If it is not installed, it will be created.
- **`--wait`**: This flag makes the command wait until all resources are in a ready state before completing.
- **`-n gpu-operator`**: This specifies the namespace where the GPU operator will be deployed.
- **`nvidia/gpu-operator`**: This indicates the Helm chart to be used for the installation.
- **`--set-json daemonsets.tolerations`**: This sets the tolerations for the daemonsets, allowing them to run on nodes with specific taints, ensuring that the GPU operator can effectively manage GPU resources.

Once the GPU operator is deployed, it will automatically handle the installation of the necessary NVIDIA drivers and configure the environment to ensure that your applications can leverage the power of GPUs seamlessly. This setup is essential for optimizing performance in machine learning and other GPU-intensive tasks.

## Don’t Be a Toby – Check Out These Fun Reads!

[Part 2: Exposing and Scaling the Ollama Model on AKS]({{< ref "ollama-part2" >}})