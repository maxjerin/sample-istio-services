# Multi-Cluster Setup

Multi-cluster does not work on MacOs or Windows. It only works on linux.

> On macOS and Windows, docker does not expose the docker network to the host. Because of this limitation, containers (including kind nodes) are only reachable from the host via port-forwards, however other containers/pods can reach other things running in docker including loadbalancers.

## Global Variables for the two clusters
```
$ export CTX_CLUSTER1=cluster1
$ export CTX_CLUSTER2=cluster2
```

## Create two clusters

```
# Start cluster1
$ minikube start -p $CTX_CLUSTER1

# Start cluster2
$ minikube start -p $CTX_CLUSTER2
```

## Generate Certs
[Reference](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster)
```
# Clone Istio Repo
$ git clone git@github.com:istio/istio.git

# Create root ca
$ cd istio
$ mkdir -p certs
$ cd certs
$ make -f ../tools/certs/Makefile.selfsigned.mk root-ca

# Create certs for cluster1 and cluster2 (run these from the certs folder)
$ make -f ../../istio/tools/certs/Makefile.selfsigned.mk "${CTX_CLUSTER1}-cacerts"
$ make -f ../../istio/tools/certs/Makefile.selfsigned.mk "${CTX_CLUSTER2}-cacerts"
```

## Apply Certs to Clusters (from istio repo)
```
$ kubectl --context="${CTX_CLUSTER1}" create namespace istio-system
$ kubectl --context="${CTX_CLUSTER1}" \
    create secret generic cacerts -n istio-system \
    --from-file="${CTX_CLUSTER1}/ca-cert.pem" \
    --from-file="${CTX_CLUSTER1}/ca-key.pem" \
    --from-file="${CTX_CLUSTER1}/root-cert.pem" \
    --from-file="${CTX_CLUSTER1}/cert-chain.pem"


$ kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
$ kubectl --context="${CTX_CLUSTER2}" \
    create secret generic cacerts -n istio-system \
    --from-file="${CTX_CLUSTER2}/ca-cert.pem" \
    --from-file="${CTX_CLUSTER2}/ca-key.pem" \
    --from-file="${CTX_CLUSTER2}/root-cert.pem" \
    --from-file="${CTX_CLUSTER2}/cert-chain.pem"
```

# Multi-Primary Same Network

## Configure Clusters as Primary (back in sample-istio-service repo)
```
$ istioctl install --context="${CTX_CLUSTER1}" -f ./multi-cluster/same-network/cluster1.yaml --set profile=demo

$ istioctl install --context="${CTX_CLUSTER2}" -f ./multi-cluster/same-network/cluster2.yaml --set profile=demo
```

## Enable Endpoint Discovery
[Reference](https://istio.io/latest/docs/setup/install/multicluster/multi-primary/#enable-endpoint-discovery)

```
$ kubectl config use-context "$CTX_CLUSTER1"
$ istioctl --context="${CTX_CLUSTER1}" \
    create-remote-secret \
    --context="${CTX_CLUSTER1}" \
    --server="https://$(minikube ip -p "${CTX_CLUSTER1}"):8443" \
    --name=cluster1 | \
    kubectl apply -f - --context="${CTX_CLUSTER2}"
$ istioctl --context="${CTX_CLUSTER1}" \
    create-remote-secret \
    --context="${CTX_CLUSTER1}" \
    --server="https://cluster1:57361" \
    --name=cluster1 | \
    kubectl apply -f - --context="${CTX_CLUSTER2}"

$ kubectl config use-context "$CTX_CLUSTER2"
$ istioctl --context="${CTX_CLUSTER2}" \
    create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --server="https://$(minikube ip -p "${CTX_CLUSTER2}"):8443" \
    --name=cluster2 | \
    kubectl apply -f - --context="${CTX_CLUSTER1}"
$ istioctl --context="${CTX_CLUSTER2}" \
    create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --server="https://cluster2:57100" \
    --name=cluster2 | \
    kubectl apply -f - --context="${CTX_CLUSTER1}"
```

## Install Services

### Caller-Service in Cluster1 (in the default namespace)

```
$ kubectl --context="${CTX_CLUSTER1}" \
    label namespace default istio-injection=enabled
$ kubectl --context="${CTX_CLUSTER1}" apply \
    -f caller-service/k8s/deployment-versions-multi-cluster.yaml \
    -f caller-service/k8s/istio-rules-multi-cluster.yaml
```

### Callme-Service in Cluster2 (in the default namespace)

```
$ kubectl --context="${CTX_CLUSTER2}" \
    label namespace default istio-injection=enabled
$ kubectl --context="${CTX_CLUSTER2}" apply \
    -f callme-service/k8s/deployment-versions.yaml \
    -f callme-service/k8s/istio-rules.yaml
```

## Test Cross Cluster Access

```
# Start Ingressgateway on Cluster1
$ minikube tunnel -p "$CTX_CLUSTER1"

```

# Multi-Primary on Different Network

```
$ kubectl --context="${CTX_CLUSTER1}" label namespace istio-system topology.istio.io/network=network1
$ istioctl install --context="${CTX_CLUSTER1}" -f ./multi-cluster/different-network/cluster1.yaml

# From the istio repo
$ samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster1 --network network1 | \
    istioctl --context="${CTX_CLUSTER1}" install -y -f -

$ kubectl --context="${CTX_CLUSTER1}" apply -n istio-system -f \
    ./multi-cluster/expose-services.yaml

$ istioctl create-remote-secret \
  --context="${CTX_CLUSTER1}" \
  --name=cluster1 | \
  kubectl apply -f - --context="${CTX_CLUSTER1}"



$ kubectl --context="${CTX_CLUSTER2}" label namespace istio-system topology.istio.io/network=network2
$ istioctl install --context="${CTX_CLUSTER2}" -f ./multi-cluster/different-network/cluster2.yaml

# From the istio repo
$ samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster2 --network network2 | \
    istioctl --context="${CTX_CLUSTER2}" install -y -f -

$ kubectl --context="${CTX_CLUSTER2}" apply -n istio-system -f \
    ./multi-cluster/expose-services.yaml
$ istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --name=cluster2 | \
  kubectl apply -f - --context="${CTX_CLUSTER1}"
```
