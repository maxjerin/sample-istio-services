# Istio Setup

```
$ brew intall minikube

# Get IP of local machine
$ hostname

# Start minikube
$ minikube start --nodes=3

# Install istioctl
$ brew install istioctl
$ istioctl install

# Istio Addons. Kiali, Prometheus, and Grafana
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/prometheus.yaml
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/grafana.yaml
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/kiali.yaml
```

## Check status of registered microservices

```
istioctl proxy-status
```

## Enable Debugging

```
$ kubectl exec -n default caller-service-6bbcc4788b-dcllf -- curl -X POST "http://localhost:15000/logging?level=debug"
```
