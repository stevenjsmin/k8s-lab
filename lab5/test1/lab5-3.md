
# Helm lab 5-3 - Create my HELM package


### Download existing package to customize
```sh
  # 패키지 다운로드 받기
  helm pull bitnami/nginx
```

```
  # 현재 내 로그인상태 보기
  kubectl config view

  # 현재 stevenlab 네임스페이스의 모든 리소스 지우기
  kubectl delete all --all -n stevenlab

  kubectl create deployment webserver --image nginx:1.25.2 --port 80 -o yaml

  # 아래 명령은 deployment로 생성하고 그 결과를 deployment.yaml로 생성한다.
  kubectl create deployment webserver --image nginx:1.25.2 --port 80 -o yaml > ~/manifests/deployment.yaml

  kubectl expose deployment webserver --port 80 --target-port 80 --type NodePort -o yaml > ~/manifests/service.yaml

  # 위에서 2개의 파일을 생성하면서 리소스도 생성되었을것이다.
  #   이것을 삭제하는 방법은 두가지다.
  # 방법1
  kubectl delete all --all -n stevenlab
  # 방법2
  kubectl delete -f ./manifests

```

아래 두개의 파일 deployment.yaml, service.yaml을 좀 간단하게 만들어놓는다. (이것은 삭제하지 않아도 되지만)
```yaml
# deployment.yaml
kind: Deployment
metadata:
  labels:
    app: webserver
  name: webserver
  namespace: stevenlab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      labels:
        app: webserver
    spec:
      containers:
      - image: nginx:1.25.2
        imagePullPolicy: IfNotPresent
        name: nginx
        ports:

```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: webserver
  name: webserver
  namespace: stevenlab
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: webserver
  type: NodePort
```

```sh
helm create mynginx
# 일단 불필요한 파일은 지워서 단순하게 만들어놓는다.
rm -rf mynginx/templates/*.yaml mynginx/templates/{_helpers.tpl,NOTES.txt}
rm -rf mynginx/templates/tests
 ⚡ root [k8s-client]  ~  tree mynginx 
mynginx
├── Chart.yaml
├── charts
├── templates
└── values.yaml

3 directories, 3 files

cp manifests/* mynginx/templates/

```


```sh
 # mynginx/Chart.yaml 
apiVersion: v2
name: mynginx
description: A Helm chart for my Nginx

type: application

version: 0.1.0

appVersion: "1.16.0"
```

만들어진 Chart가 문법적으로 문제없는 확인한다.
```sh
helm lint mynginx/

# 실행
helm install webserver ./mynginx
    NAME: webserver
    LAST DEPLOYED: Wed Oct  1 05:57:46 2025
    NAMESPACE: stevenlab
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
```

이렇게 하면 브라우저에서
  -  http://[Control Plane노드의 IP]:31768-이포트는 달라질수있음]
또는, K8s노드들중 하나에 접속해서
  - curl [localhost:31768-이포트는 달라질수있음]
테스트해보면 작동하는것을 확인할수 있다.

생성된 helm 삭게
```sh
helm list
helm uninstall webserver
```

