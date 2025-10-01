
# Helm lab 6-1

Setup Kubernates Dashboard

https://kubernetes.io/ko/docs/tasks/access-application-cluster/web-ui-dashboard/



** Control plane에서 실행해야한다.
#### 대시보드 UI 배포
```shell
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
  
  ## 위명령은 namespace/kubernetes-dashboard 라는 Namespace가 만들어지고 필요한 모든 리소스들이 생성된다.
  kubectl get all -n kubernetes-dashboard 
  
```

**메뉴얼에서는 "UI는 오직 커맨드가 실행된 머신에서만 접근 가능하다."라고 되어있다.**
본적으로 이  Service는 ClusterIP형태로 써비스 된다. 이것을 외부에서 접근 가능하도록 하기위해서는 NodePort로 변경한다. 
```shell

    # 아래명령으로  ClusterIP를 NodePort로 변경한다.
    kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
    
    # 위에서 변경한 내용확인
    kubectl get svc -n kubernetes-dashboard
```


```shell
    # Kubernates Control Plane서버의 IP확인
    $> hostname -i
          172.31.15.206
       
    kubectl proxy --address=172.31.15.206 --accept-hosts='^*$'
```



```yaml
# serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
name: admin-user
namespace: kubernetes-dashboard
```
kubectl apply -f serviceaccount.yaml 

```yaml
# clusterroleBinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard
```
kubectl apply -f clusterroleBinding.yaml 

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token 
```
kubectl apply -f secret.yaml


Secret에 생성된 토큰을 base64로 인코딩된 값을 얻을수 있다. 즉 admin-user가 Dashboard의 접근에 필요한 토큰값을 얻을수 있다.
```shell
    kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d
```

```shell
  
  kubectl get svc -n kubernetes-dashboard kubernetes-dashboard
      kubernetes-dashboard   NodePort   10.107.102.252   <none>        443:31610/TCP   41m 
  
  # 의의 서비스는 31610 접속이 가능하지만, 인증서가 필요한 접근이다(443). 그래서 이 서버에 브라우저로 접속해서 이것의 인증서를 이 서버(172.31.15.206)에 넣어줘야한다.
```

kubectl proxy --address=172.31.15.206 --accept-hosts='^*$' 명령어로 실행한상태에서, K8s Control Plan노드의 Public IP를 통해서 브라우저에서 열어본다.
--> 예: https://13.211.162.208:31610/

화면이 열리면 토큰을 물어보는데, 토큰을 선택하고, 위의 토큰 정보를 입력한다.







