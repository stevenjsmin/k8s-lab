
# Helm test


-----
### Check install and commands
```angular2html
    helm version
    helm --help
    helm repo list

    helm repo add bitnami https://charts.bitnami.com/bitnami

    helm repo remove bitnami


    helm search repo jenkins
        NAME           	CHART VERSION	APP VERSION	DESCRIPTION
        bitnami/jenkins	13.6.17      	2.516.2    	Jenkins is an open source Continuous Integratio...

```

#### 어떤기준으로 디플로이되는지,Replica 갯수, Service, Persistance Volumn..체크
```shell
    helm inspect values bitnami/jenkins
    helm inspect values bitnami/jenkins > jenkins_values.yaml
```


```shell
    helm install jenkins bitnami/jenkins
    helm install jenkins --set service.type=NodePort bitnami/jenkins
```

kubectl create namespace stevenlab
kubectl config set-context --current --namespace=stevenlab
kubectl config view

#### Troubleshooting
문제: 서비스가 되지 않아서 "ckubectl get all -n stevenlab"를 확인해보니까 Pod의 상태가 계속해서 Pending상태로 되어있음.

1. 왜 Pending인지 이벤트로 원인 확인
```shell
   kubectl get pods
   kubectl describe pod jenkins-67ff8dd8d6-rcbzl   ---> pod의 상세한 상태를 보여줌. 
   kubectl get events --sort-by=.lastTimestamp
```

2. PVC(스토리지) 이슈가 가장 흔함
Describe에서 "pod has unbound immediate PersistentVolumeClaims."가 보여짐.
Bitnami Jenkins는 기본적으로 PersistentVolumeClaim을 만듭니다.
이것은 스토리지와 관련있는 이슈임.

```shell
  kubectl get pvc ->  스토리지 이름이 나옴
  kubectl describe pvc [스토리지이름]
     --> kubectl describe pvc jenkins
          --> 기본 StorageClass가 없음 → 기본 SC를 지정하거나, Helm에 SC를 명시

```

3. 기본 StorageClass가 없음 → 기본 SC를 지정하거나, Helm에 SC를 명시
하지만, SC가 없기때문에 먼저 아래를 실행 해줘야함.
```shell
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    helm repo update
    helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver -n kube-system
```

```shell
    # 기본 StorageClass 지정(예: gp3를 기본으로)
    kubectl patch storageclass gp3 -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    
```

4. SC를 차트에 직접 지정
```shell
    helm upgrade --install jenkins bitnami/jenkins  \
    --set persistence.enabled=true \
    --set persistence.storageClass=gp3 \
    --set persistence.size=8Gi

```
위와 같이하면 다시 Helm이 수정되어 적용된다.

"kubectl get pvc"로 확인해보면 STORAGECLASS가 "gp3"로 바운드된것을 확인할수 있다.

그래도 Pod는 Pending

아래로 스토리지를 바꿔서 적용해본다.
```shell
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
    # 기본 StorageClass로 지정
    kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class="true" --overwrite
    kubectl get sc
    
    helm upgrade --install jenkins bitnami/jenkins \
      --set persistence.enabled=true \
      --set persistence.size=8Gi \
      --set persistence.storageClass=local-path
    
```

그래도 계속 Pod 가 Pending상태로 서비스가 되지 않는다.

"kubectl get pvc"를 확인해보니까 두번째로 시도한 스토리지 마운트가 실해하면서 여전히 gp3로 남아있다.

#### 당장 빨리 띄워봐야 한다면 (영속성 끄기)
아래방법은 PVC 없이 emptyDir로 떠서 Pending은 사라지지만, 데이터가 Pod 재시작 시 사라집니다.
```shell
  helm upgrade --install jenkins bitnami/jenkins --set persistence.enabled=false
```

export SERVICE_IP=$(kubectl get svc --namespace stevenlab jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Jenkins URL: http://$SERVICE_IP/"

echo Username: user
echo Password: $(kubectl get secret --namespace stevenlab jenkins -o jsonpath="{.data.jenkins-password}" | base64 -d)

아래는 LoadBalancer대신에 NodePort로 다시 적용한 명령이다.
```shell
    helm upgrade --install jenkins bitnami/jenkins -n stevenlab \
      --set service.type=NodePort \
      --set service.nodePorts.http=32080 \
      --set service.nodePorts.https=32443
      
      
1. Get the Jenkins URL by running:

  export NODE_PORT=$(kubectl get --namespace stevenlab -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
  export NODE_IP=$(kubectl get nodes --namespace stevenlab -o jsonpath="{.items[0].status.addresses[0].address}")
  echo "Jenkins URL: http://$NODE_IP:$NODE_PORT/"

2. Login with the following credentials

  echo Username: user
  echo Password: $(kubectl get secret --namespace stevenlab jenkins -o jsonpath="{.data.jenkins-password}" | base64 -d)
        
```

#### Delete
```shell
    helm uninstall jenkins
```

### Helm Chart package structure
```shell
    helm pull bitnami/jenkins
    tar zxvf jenkins-13.6.17.tgz
```













