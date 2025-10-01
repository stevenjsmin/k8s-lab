
# Helm lab 5-3 - Create my HELM package


```
  # 현재 내 로그인상태 보기
  kubectl config view

  # 현재 stevenlab 네임스페이스의 모든 리소스 지우기
  # 방법1
  kubectl delete all --all -n stevenlab
  # 방법2
  kubectl delete -f ./manifests

```

mywebserver 디렉토리를 생성하고 그 하위에 아래와 같은 디렉토리구조와 템플릿파일들을 생성한다.

```shell
    mywebserver
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   └── service.yaml
    └── values.yaml
```


```shell
helm install webserver ./mywebserver/
    NAME: webserver
    LAST DEPLOYED: Wed Oct  1 12:32:07 2025
    NAMESPACE: stevenlab
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
```


-----
# Upgrade 와 Rollback

위에서 돌고있는 리소스들을 운영중에 변경이 가능하다.


### Upgrade
```shell
    # 아래명령은 mywebserver디렉토리 상위에서 실행해야한다.
    # 즉 아래명령의 마지막 mywebserver은 실행될 디렉토리 위치를 의미한다.
    helm upgrade --set image.repository=httpd --set image.tag=2.2.34-alpine webserver mywebserver
    
    # mywebserver/values.yaml 파일의 replicaCount갯수를 조절하고, 이 조절된 값을 반영하고싶으면 아래 명령을 실행한다.
    helm upgrade webserver mywebserver
```


### Rollback

위에서 반영할때마다 Revision번호가 나오는데, 이 Revision번호로 과거로 롤백 시킬수있다.
```shell
  helm rollback webserver 2
  helm rollback webserver 1
  helm rollback webserver 3
```


-----
# Packaging
```shell
    helm package mywebserver
        Successfully packaged chart and saved it to: /root/mywebserver-0.1.0.tgz
    
```

----
# Publish Packges

```shell
    helm repo list
```

Chart만드는 과정
- 차트생성 : helm create mywebserver
- Template-* yaml 파일 저정
- 문법검사 : helm lint mywebserver
- 패키지 생성: helm package mywebserver


#### JFRO Artifactory에 생성된 Helm Repository를 등록해줘야한다.

```shell
  helm repo add stevenlab-helm https://trialqdcy13.jfrog.io/artifactory/api/helm/stevenlab-helm --username [USERNAME-NORMALLY YOUR EMAIL ADDR] --password [JFROG TOKEN]
  
  helm repo list
        NAME              	URL
        bitnami           	https://charts.bitnami.com/bitnami
        aws-ebs-csi-driver	https://kubernetes-sigs.github.io/aws-ebs-csi-driver
        stevenlab-helm    	https://trialqdcy13.jfrog.io/artifactory/api/helm/stevenlab-helm  
```


curl -u[USERNAME-NORMALLY YOUR EMAIL ADDR]:[JFROG TOKEN] -T mywebserver-0.1.0.tgz "https://trialqdcy13.jfrog.io/artifactory/stevenlab-helm/mywebserver-0.1.0.tgz