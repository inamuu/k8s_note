### kustomize example
https://kubectl.docs.kubernetes.io/guides/example/multi_base/

### apply

```sh
kustomize build | kubectl diff -f -
```

```sh
kustomize build | kubectl apply -f -
```

```sh
kubectl get pods -A
```

### delete

```sh
kustomize build | kubectl delete -f -
```

