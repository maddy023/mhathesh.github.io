---
date: 2024-12-01
lastmod: 2024-12-01
showTableOfContents: false
tags: ["CKA","LinuxFoundation","Certification","Security","DevSecOps","Container","CNCF"]
title: "What CKA Certification Taught Me!"
draft: false
series: ["What it taught me"]
categories: ["Learning"]
cover:
    image: "/k8s/cka-cover.png"
    alt: "Cover"
    caption: ""
    relative: false
---
**What CKA Certification Taught Me!**

Preparing for the Certified Kubernetes Administrator (CKA) exam is a journey filled with valuable lessons and hands-on experience. As I worked through the certification, I encountered several new concepts and tools that expanded my understanding of Kubernetes. In this blog, I’ll walk you through these new insights to make it easier.

### **1. Network Policies**

[Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) define how pods in a Kubernetes cluster communicate with each other and external services. These policies act as firewalls at the pod level. To understand real-world scenarios, explore  [this comprehensive GitHub repository](https://github.com/ahmetb/kubernetes-network-policy-recipes/tree/master), which provides practical examples.

### **2. Pod Topology Spread Constraints**

[Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) help control how pods are distributed across failure domains, such as regions, zones, nodes, or custom-defined topology domains. This ensures high availability and efficient resource utilization.

#### **Motivation**

-   If you have a cluster with multiple nodes and only two pods, you wouldn't want both pods running on the same node. A single-node failure could take the workload offline.
-   For larger workloads with multiple replicas across datacenters or zones, these constraints can reduce latency and save on network costs by minimizing cross-zone traffic.

#### **Practical Applications**

You can configure topology spread constraints at the cluster level as defaults or for individual workloads to balance availability and performance. Learn more about these constraints in the  [official Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/).

### **3. EndpointSlices**

[EndpointSlices](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/) improve the scalability of Kubernetes networking by splitting the endpoints of a service into smaller, manageable chunks. This is a crucial optimization feature for large-scale clusters.

### **4. Controlling Access to the Kubernetes API**

Access control is a fundamental part of Kubernetes security. You can learn how to fine-tune access and improve scheduler performance by exploring  [this guide](https://kubernetes.io/docs/concepts/security/controlling-access/).

### **5. Static Pods**

Static pods are managed directly by the Kubelet without involving the API server. They are useful for bootstrapping and critical system components. To configure static pods:

-   Define them in  `/etc/kubernetes/manifests/`.
-   Ensure the  `staticPodPath`  is set correctly in the Kubelet configuration. For a detailed guide, refer to  [this documentation](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/).


### **6. Cluster Certificates Management**

[Managing and renewing](https://kubernetes.io/docs/tasks/administer-cluster/certificates/) Kubernetes certificates is essential for maintaining a secure cluster. Some key commands include:

```bash
kubeadm certs renew apiserver
kubeadm certs renew scheduler.conf
kubeadm certs check-expiration
```
These commands ensure your cluster components stay secure with up-to-date certificates.

### **7. RBAC: ClusterRole vs. Role**

Kubernetes uses [Role-Based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to manage permissions. Here’s a quick matrix of valid RBAC combinations:

1.  **Role + RoleBinding**: Namespace-scoped permissions.
2.  **ClusterRole + ClusterRoleBinding**: Cluster-wide permissions.
3.  **ClusterRole + RoleBinding**: Cluster-wide permissions applied to a single namespace.

### **8. Generating Certificates Manually**

For client certificate authentication, tools like  `easyrsa`,  `openssl`, and  `cfssl`  can be used to [generate certificates](https://kubernetes.io/docs/tasks/administer-cluster/certificates/). These tools ensure secure communication between cluster components and external clients.

### **9. Tracing Kubernetes System Components**

Introduced in Kubernetes v1.27, tracing records the latency and relationships between operations. Kubernetes components use the OpenTelemetry Protocol (OTLP) with gRPC exporters to emit traces. Traces can be collected using the OpenTelemetry Collector. Learn more about setting up tracing [here](https://kubernetes.io/docs/concepts/cluster-administration/system-traces/).

### **10. Autoscaling DNS Services**

Kubernetes clusters rely heavily on DNS for internal communication. Enabling [DNS autoscaling](https://kubernetes.io/docs/tasks/administer-cluster/dns-horizontal-autoscaling/) ensures optimal performance as the cluster grows. Debugging DNS issues can also help identify bottlenecks in cluster communication.

### **11. Accessing the Kubernetes API from Pods**

Accessing the Kubernetes API from within a pod is a critical skill for integrating custom applications with Kubernetes. This [guide](https://kubernetes.io/docs/tasks/run-application/access-api-from-pod) demonstrates how to achieve this securely and efficiently.

### **12. Finalizers**

[Finalizers](https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/) are mechanisms that ensure cleanup actions are performed before Kubernetes fully deletes a resource. They act as "cleanup hooks" for dependent resources or custom actions.

#### **How They Work**

When a resource with a finalizer is marked for deletion:

1.  The Kubernetes API sets the  `.metadata.deletionTimestamp`  field and places the resource in a  _terminating_  state.
2.  The API server returns a 202 HTTP status code, indicating the deletion request has been accepted but not yet completed.
3.  Controllers or other components perform the cleanup actions specified by the finalizers.
4.  Once the actions are complete, the controllers remove the finalizers, and Kubernetes completes the deletion.



### **13. Windows Containers in Kubernetes**

[Windows containers](https://kubernetes.io/docs/concepts/windows/intro/) enable organizations to bring Windows-based applications into the Kubernetes ecosystem, aligning with cloud-native patterns and DevOps practices. This is especially valuable for organizations with a mix of Windows and Linux workloads, as Kubernetes can orchestrate both seamlessly.

#### **Why Use Windows Containers in Kubernetes?**

-   **Encapsulation of Dependencies:**  Windows containers encapsulate processes and their dependencies, simplifying deployment and scaling.
-   **Operational Efficiency:**  A single orchestrator (Kubernetes) can manage both Linux and Windows workloads, eliminating the need for separate orchestrators.
-   **Cloud-Native Transformation:**  Modernize Windows applications by adopting containerization and Kubernetes orchestration without rewriting them.
-   **Consistency Across Platforms:**  Use the same tools and practices for Windows and Linux workloads, reducing operational complexity.


### **14.  Node-Pressure Eviction**

[Node-pressure eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/) is the process by which the kubelet proactively terminates pods to reclaim resources on nodes that are under pressure.

### Node Conditions and Eviction Signals

| **Node Condition** | **Eviction Signal** | **Description** |
|--------------------|---------------------|-----------------|
| **MemoryPressure** | `memory.available` | Available memory on the node has satisfied an eviction threshold. |
| **DiskPressure** | `nodefs.available`, `nodefs.inodesFree`, `imagefs.available`, `imagefs.inodesFree`, `containerfs.available`, `containerfs.inodesFree` | Available disk space and inodes on the node's root filesystem, image filesystem, or container filesystem has satisfied an eviction threshold. |
| **PIDPressure** | `pid.available` | Available process identifiers on the (Linux) node have fallen below an eviction threshold. |


### **Closing Thoughts**

Each of these concepts contributed to my growth as a Kubernetes administrator. Whether you are new to Kubernetes or preparing for the CKA exam, understanding these topics will set you on the right path. Stay tuned for more blog posts as I document further insights and share the joy of learning Kubernetes!

### Did I Stutter? Start Reading Now!

[What Vault Certification Taught Me!]({{< ref "vault-cert" >}})