AWS LoadBalancer Controller
===

- kube-systemに作成して、クラスター単位で共通で使用する想定

### セットアップ手順

https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/lbc-helm.html

最初にcrdsに関するエラーが出るが、再度applyすればOK(crdsはhelmでインストールするため順番の問題)

```sh
$ kustomize build . --enable-helm | kubectl apply -f -
```

