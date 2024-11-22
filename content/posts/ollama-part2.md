---
date: 2024-10-27T18:04:38-04:00
# description: ""
# image: ""
showTableOfContents: false
tags: ["k8s","llama3","llm","genAI"]
title: "Part 2: Exposing and Scaling the Ollama Model on AKS"
categories: ["GenAI"]
series: ["Ollama"]
---

# Part 2: Exposing and Scaling the Ollama Model on AKS

Ollama is a versatile platform designed for deploying and managing language models like Llama. It's particularly suited for environments where large models are run on Kubernetes clusters, utilizing GPU resources efficiently. In this guide, we’ll explore deploying the Ollama model server using Docker and the CLI, and we’ll reference important configurations and best practices to make the deployment seamless.

# Why Ollama?
Ollama offers a streamlined way to serve and scale language models in Kubernetes environments, with built-in support for GPU acceleration. This makes it an ideal choice for deploying large models that demand substantial computational power, such as the Llama models. Ollama’s compatibility with Docker and Kubernetes lets developers and data scientists quickly spin up model-serving instances, ensuring high availability and performance in both development and production setups.

# Ollama in Docker

### Deploying Ollama via Docker

To get started with Docker, you’ll need the official Ollama Docker image. This approach is suitable for local testing and small-scale deployments. 

[Follow these steps to deploy Ollama using Docker:](https://github.com/ollama/ollama/blob/main/docs/docker.md)

1.  **Pull the Docker Image**:
    
```bash
docker pull ollama/ollama:latest
```

2.  **Run Ollama in a Docker Container**:  
    Launch a container using the pulled image and expose the necessary ports.
 
```bash  
docker run -d --name ollama -p 11434:11434 ollama/ollama:latest
```
    
3.  **Verify Deployment**:  
    Confirm that Ollama is running by sending a test request - [API DOCS](https://github.com/ollama/ollama/blob/main/docs/api.md) :
    
```bash
curl http://localhost:11434/api/generate -d '{
 "model": "llama3.2",
 "prompt": "Why is the sky blue?"
}'
```

# Ollama in K8s

To deploy Ollama in a Kubernetes environment, you can use the following Kubernetes manifest files. Make sure to review and configure them as necessary before deployment. Once configured, apply the manifests to your Kubernetes cluster to launch the Ollama model server.


# Environment Variables for Ollama Deployment

When deploying Ollama in a Kubernetes environment, it's essential to configure the appropriate environment variables to ensure optimal performance and resource management. Below are the key environment variables you should consider, along with their descriptions and recommended values.

- **`NVIDIA_VISIBLE_DEVICES`**:  
  This variable controls which GPUs are accessible to the Ollama container. By setting this to `all`, you make all available GPUs on the host system visible to the container, maximizing GPU resource availability for Ollama.  
  **Value**: `all`

- **`OLLAMA_DEBUG`**:  
  Enabling this variable activates debug mode for the Ollama server, which can output additional information to help diagnose issues or understand the model’s behavior in more detail.  
  **Value**: `"1"` (Enabled)

- **`OLLAMA_NUM_PARALLEL`**:  
  This variable specifies the number of parallel processes that Ollama can handle. Optimizing performance by setting the degree of concurrency for model-serving requests is crucial. A value of `8` implies that Ollama will run up to 8 parallel threads, making efficient use of resources for handling multiple requests.  
  **Value**: `"8"`

- **`OLLAMA_MAX_LOADED_MODELS`**:  
  This variable limits the number of models that Ollama can load in memory simultaneously. This helps control memory usage, which is crucial for managing limited GPU memory resources. Setting this to `1` restricts Ollama to a single loaded model, helping to avoid overloading the GPU memory.  
  **Value**: `"1"`

For the latest updates on environment variables, you can refer to the official [Ollama GitHub repository](https://github.com/ollama/ollama/blob/main/envconfig/config.go).
    
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ollama
  labels:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
    app.kubernetes.io/version: "0.1.32"
automountServiceAccountToken: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
    app.kubernetes.io/version: "0.1.32"
  name: ollama
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: "managed-csi-premium"
  resources:
    requests:
      storage: "80Gi"
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
  labels:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
    app.kubernetes.io/version: "0.1.32"
spec:
  type: ClusterIP
  ports:
    - port: 11434
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
  sessionAffinity: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  labels:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
    app.kubernetes.io/version: "0.1.32"
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: ollama
      app.kubernetes.io/instance: ollama
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ollama
        app.kubernetes.io/instance: ollama
        app.kubernetes.io/version: "0.1.32"
    spec:
      serviceAccountName: ollama
      securityContext:
        {}
      containers:
        - name: ollama
          securityContext:
            {}
          image: "ollama/ollama:0.1.38" # Update to the specific Ollama version if needed
          imagePullPolicy: IfNotPresent
          lifecycle:
            postStart:
              exec:
                command:
                - ollama
                - pull
                - llama3:70b # Update to the ollama model which is required
          ports:
            - name: http
              containerPort: 11434
              protocol: TCP
          env:
            - name: PATH
              value: /usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            - name: LD_LIBRARY_PATH
              value: /usr/local/nvidia/lib:/usr/local/nvidia/lib64
            - name: NVIDIA_DRIVER_CAPABILITIES
              value: compute,utility
            - name: NVIDIA_VISIBLE_DEVICES
              value: all
            - name: OLLAMA_DEBUG
              value: "1"
            - name: OLLAMA_NUM_PARALLEL
              value: "8"
            - name: OLLAMA_MAX_LOADED_MODELS
              value: "1"
          resources:
            limits:
              nvidia.com/gpu: 1
            requests: {}
          volumeMounts:
            - name: ollama-data
              mountPath: /root/.ollama
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 30
            periodSeconds: 5
            timeoutSeconds: 3
            successThreshold: 1
            failureThreshold: 6
      volumes:
        - name: ollama-data
          persistentVolumeClaim:
            claimName: ollama
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
        - key: sku
          operator: Equal
          value: 'gpu'
          effect: NoSchedule
        - key: kubernetes.azure.com/scalesetpriority
          operator: Equal
          value: spot
          effect: NoSchedule
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ollama
  labels:
    app.kubernetes.io/name: ollama
    app.kubernetes.io/instance: ollama
    app.kubernetes.io/version: "0.1.32"
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "180"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "180"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "180"
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
spec:
  tls:
    - hosts:
        - "ollama-api.mhathesh.me"
      secretName: oolama-api-ss-ai-cert
  rules:
    - host: "ollama-api.mhathesh.me"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ollama
                port:
                  number: 11434
```

### Additional Resources

For more details on deploying Ollama using Helm charts, check out the [Ollama Helm Repository on GitHub](https://github.com/otwld/ollama-helm). This repository provides Helm chart templates and further configuration options to help streamline the deployment process.


To deploy Ollama using a Helm chart, you’ll need to configure a values.yaml file that specifies key settings and environment variables for your Kubernetes deployment. Below is a sample values.yaml file with sample configurations and context for each setting. Update these values as necessary to match your deployment needs, especially for GPU resources, ingress settings, and environment variables.

```yaml
ollama:
  gpu:
    enabled: true
  
    type: 'nvidia'
    number: 1
  models: 
    - llama3:70b

ingress:
  enabled: true
  annotations: 
    kubernetes.io/ingress.class: "nginx"

  hosts:
    - host: ollama-api.mhathesh.me
      paths:
        - path: /
          pathType: Prefix
  tls: 
   - secretName: oolama-api-ss-ai-cert
     hosts:
       - ollama-api.mhathesh.me

livenessProbe:
  enabled: true
  path: /

readinessProbe:
  enabled: true
  path: /

extraEnv:
 - name: OLLAMA_DEBUG
   value: "1"

persistentVolume:
  enabled: true
  accessModes:
    - ReadWriteOnce
  size: 50Gi
  storageClass: "managed-csi-premium"
```

## Just Like Pretzel Day – You Won’t Want to Miss These!

[Part 1: Preparing Your Environment and Setting Up AKS for Ollama Models]({{< ref "ollama-part1" >}})