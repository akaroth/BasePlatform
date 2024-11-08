Here’s the README in markdown format:

Monitoring Solution POC with Thanos on Kind Cluster

This POC demonstrates setting up a monitoring solution with Prometheus and Thanos on a local Kubernetes cluster using kind. Thanos extends Prometheus by providing long-term storage, horizontal scalability, and global querying capabilities. For object storage, we are using MinIO, a self-hosted, S3-compatible storage solution.

Prerequisites

	•	Kind: Install kind for running Kubernetes in Docker (Kind Installation Guide)
	•	Kubectl: Install Kubernetes CLI for managing the cluster
	•	Helm: Install Helm to deploy Prometheus and Thanos

Steps

1. Set Up Kind Cluster

Create a kind cluster to run our setup.

kind create cluster --name monitoring-poc
kubectl cluster-info --context kind-monitoring-poc

2. Install Prometheus with Thanos Sidecar

We’ll use the kube-prometheus-stack Helm chart, which includes Prometheus and other monitoring tools. We’ll configure Prometheus to use a Thanos sidecar for data export.

	1.	Add Helm Repository:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


	2.	Create Monitoring Namespace:

kubectl create namespace monitoring


	3.	Prepare Custom Values for Prometheus:
Create a prometheus-values.yaml file to include Thanos configuration:

prometheus:
  prometheusSpec:
    thanos:
      create: true
      objectStorageConfig:
        secretName: thanos-objectstore-secret
        key: config.yaml


	4.	Install Prometheus:

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml



3. Set Up MinIO for Object Storage

We’ll use MinIO to simulate an S3-compatible storage solution.

	1.	Install MinIO:

kubectl create namespace minio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install minio bitnami/minio --namespace minio \
  --set accessKey.password=minioadmin --set secretKey.password=minioadmin123


	2.	Create Object Store Secret:
Define a Kubernetes Secret for Thanos to connect to MinIO.

apiVersion: v1
kind: Secret
metadata:
  name: thanos-objectstore-secret
  namespace: monitoring
stringData:
  config.yaml: |
    type: s3
    config:
      bucket: thanos
      endpoint: minio.minio.svc.cluster.local:9000
      access_key: minioadmin
      secret_key: minioadmin123
      insecure: true

Apply the secret:

kubectl apply -f thanos-objectstore-secret.yaml



4. Deploy Thanos Query and Thanos Store

Set up Thanos Query for querying metrics and Thanos Store to connect with MinIO for long-term storage.

	1.	Thanos Query Deployment:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-query
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: thanos-query
  template:
    metadata:
      labels:
        app: thanos-query
    spec:
      containers:
        - name: thanos-query
          image: quay.io/thanos/thanos:v0.22.0
          args:
            - query
            - --http-address=0.0.0.0:9090
            - --store=dnssrv+_grpc._tcp.monitoring.svc.cluster.local
          ports:
            - containerPort: 9090


	2.	Thanos Query Service:

apiVersion: v1
kind: Service
metadata:
  name: thanos-query
  namespace: monitoring
spec:
  selector:
    app: thanos-query
  ports:
    - name: http
      protocol: TCP
      port: 9090
      targetPort: 9090


	3.	Thanos Store Deployment:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-store
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: thanos-store
  template:
    metadata:
      labels:
        app: thanos-store
    spec:
      containers:
        - name: thanos-store
          image: quay.io/thanos/thanos:v0.22.0
          args:
            - store
            - --data-dir=/data
            - --objstore.config-file=/etc/thanos/config.yaml
          ports:
            - containerPort: 10901
          volumeMounts:
            - name: objectstore-config
              mountPath: /etc/thanos/config.yaml
              subPath: config.yaml
      volumes:
        - name: objectstore-config
          secret:
            secretName: thanos-objectstore-secret


	4.	Apply Thanos Resources:
Save the configurations to YAML files (e.g., thanos-query.yaml, thanos-store.yaml) and apply:

kubectl apply -f thanos-query.yaml
kubectl apply -f thanos-store.yaml



5. Access and Test Thanos Query

	1.	Port-Forward Thanos Query:

kubectl port-forward -n monitoring svc/thanos-query 9090


	2.	Access Thanos Query UI:
Open http://localhost:9090 in your browser to access the Thanos Query interface. You can use it to query and view Prometheus metrics stored in MinIO.

Troubleshooting

	•	Access Denied Errors: Check the MinIO credentials in thanos-objectstore-secret.
	•	Connection Issues: Ensure that all services (Prometheus, Thanos, MinIO) are running, and verify pod logs with kubectl logs.

Summary

This POC demonstrates a full setup of a scalable monitoring solution using Prometheus and Thanos on a local kind cluster. MinIO acts as the object storage, allowing for long-term metric storage and querying.

This README covers the setup instructions and basic configurations to run Thanos with Prometheus on a kind cluster. Let me know if you’d like further customization!