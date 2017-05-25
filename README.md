# GlueCon Service Catalog Demo

Before proceeding to Demo Instructions, make sure you perform the Setup Instructions below.

## Demo Instructions

### Show the pre-installed Broker

```console
cat broker.yaml
kubectl --context service-catalog get broker -o yaml
kubectl --context service-catalog get serviceclass
```

### Install a Demo Instance

```console
cat demo/instance.yaml
kubectl --context service-catalog create -f demo/instance.yaml
kubectl --context service-catalog get instance demo-redis -o yaml
```

### Show the Instance

```console
kubectl --context service-catalog get instance
kubectl --context service-catalog get instance redis -o yaml
```

### Install the Binding

```console
cat binding.yaml
kubectl --context service-catalog create -f binding.yaml
kubectl --context service-catalog get binding redis -o yaml
```

### Show the Injected Credentials

```console
kubectl get secret redis-creds -o yaml
```

### Install GoDo Application

```console
cat deployment.yaml
kubectl create -f deployment.yaml
```

## Setup Instructions

## Prerequisites

 * Kubernetes 1.6 Client (1.5.x server seems to work)
 * Helm/Tiller installed
 * Azure account with a working `az` tool

### Install the Service Catalog

```console
helm install $GOPATH/src/github.com/kubernetes-incubator/service-catalog/charts/catalog --name catalog --namespace catalog --set apiserver.service.type=LoadBalancer
kubectl get svc -n catalog -w
# wait for an IP to be assigned to the APIServer
```

### Add a Service Catalog Context

```console
SVC_CAT_API_SERVER_IP=13.84.186.33
kubectl config set-cluster service-catalog --server=http://$SVC_CAT_API_SERVER_IP:80
kubectl config set-context service-catalog --cluster=service-catalog
```

### Enable Azure Redis

```console
az provider register -n Microsoft.Cache
```

### Create an Azure Service Principal

```console
export SUB_ID=<subscriptionId>
az account set --subscription $SUB_ID
az ad sp create-for-rbac \
    --role="Contributor" --scopes="/subscriptions/$SUB_ID"

# export values
export SUB_ID=<redacted>
export TENANT_ID=<redacted>
export CLIENT_ID=<redacted>
export CLIENT_SECRET=<redacted>
```

### Install the MASB Service

```console
helm install meta-azure-service-broker --name masb --namespace masb \
    --set azure.subscriptionId=$SUB_ID,azure.tenantId=$TENANT_ID,azure.clientId=$CLIENT_ID,azure.clientSecret=$CLIENT_SECRET,sql-server.acceptLicense=true
kubectl get po -n masb -w
# wait for the broker service to go healthy
```

### Install the Broker

```console
cat broker.yaml
kubectl --context service-catalog create -f broker.yaml
kubectl --context service-catalog get broker -o yaml
kubectl --context service-catalog get serviceclass
```

### Install a Redis Instance

```
cat instance.yaml
kubectl --context service-catalog create -f instance.yaml
ksc get instance redis -o yaml
```

## Cleanup

### Soft Reset

```console
kubectl delete deploy example-todo
kubectl --context service-catalog delete instance demo-redis
kubectl --context service-catalog delete binding redis
```

### Hard Reset

```console
kubectl --context service-catalog delete instance redis
kubectl --context service-catalog delete broker masb
helm delete --purge masb
kubectl delete ns masb
helm delete --purge catalog
kubectl delete ns catalog
kubectl config delete-context service-catalog
kubectl config delete-cluster service-catalog
```