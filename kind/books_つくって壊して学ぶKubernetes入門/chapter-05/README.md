### Create a cluster

```sh
kind create cluster --image=kindest/node:v1.29.0
kind get clusters
```

### Debug container

```sh
kubectl debug -ti myapp --image=curlimages/curl:8.4.0 --target=hello-server -n default -- sh
```

### Run a container at once

```sh
$ kubectl run busybox --image=busybox:1.36.1 --rm -ti --restart=Never --command -- nslookup google.com
```

