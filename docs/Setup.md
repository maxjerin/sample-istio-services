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
