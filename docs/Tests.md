# Istio Tests

## Ingress Gateway

Access `caller-service` via `ingressgateway`. `caller-service` then calls `callme-service` which is running in another namespace. Typically you would access service running in another gateway using FQDN of the service in your application code, but we want to keep the `caller-service` code decoupled from the `callme-service` and only reference it as `callme-service:8080`.

This requires setting up a `callme-service` of type `Service` and a `callme-route` of type `VirtualService` in the `default` namespace. The `VirtualService` is what points to `callme-service.<namespace>.svc.cluster.local` and allows us to move the service to any namespace without changing any code in `caller-service`.

### Tests

```
# Enable minikube tunnel in another terminal window
$ minikube tunnel

# Check status of tunnel
$ minikube get svc ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   10.98.104.116   127.0.0.1     15021:30702/TCP,80:32186/TCP,443:31724/TCP   23h

# Deploy caller-service
$ kubectl apply -f caller-service/k8s/deployment-versions.yaml -f caller-service/k8s/istio-rules.yaml

# Create new primary namespace
$ kubectl create ns primary

# Deploy callme-service
$ kubectl apply -f callme-service/k8s/deployment-versions.yaml -f callme-service/k8s/istio-rules.yaml -n primary

# Access caller service from ingressgateway
# Since we don't have DNS for caller.example.com setup locally, we need to use the EXTERNAL-IP exposed by ingressgateway and set header to caller.example.com
$ curl -I -HHost:caller.example.com "http://127.0.0.1/caller/ping"
HTTP/1.1 200 OK
content-type: text/plain;charset=UTF-8
content-length: 55
date: Fri, 27 Oct 2023 15:40:13 GMT
x-envoy-upstream-service-time: 147
server: istio-envoy
```
