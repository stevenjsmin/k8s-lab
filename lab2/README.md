# lab2
Creat two application on native K8s cluster using Kubectl
- trialqdcy13.jfrog.io/stevenlab-docker-local/boxes:1.0
- docker.io/library/nginx:stable-alpine 

               
```angular2html
kubectl create ns stevenlab

export JFROG_SERVER="trialqdcy13.jfrog.io"
export JFROG_USER="[USERNAME-NORMALLY EMAIL]"
export JFROG_PASS="xxxx"
export JFROG_EMAIL="[EMAIL]"

```

```angular2html

kubectl create secret docker-registry jfrog-pull \
  --docker-server=${JFROG_SERVER} \
  --docker-username=${JFROG_USER} \
  --docker-password=${JFROG_PASS} \
  --docker-email=${JFROG_EMAIL} \
  -n stevenlab

```

```angular2html
kubectl apply -f app-boxes.yaml

```

#### Check running status
kubectl -n stevenlab get deploy,rs,pod,svc -l app=boxes
kubectl -n stevenlab rollout status deploy/boxes

#### Re-start
kubectl -n stevenlab describe pod -l app=boxes | sed -n '1,200p'
kubectl -n stevenlab rollout restart deploy/boxes


## DELETE ALL
```angular2html
# 1) 지울 내용 확인
kubectl get all -n stevenlab
kubectl get secret -n stevenlab

# 2) 네임스페이스 통째로 제거 (안의 리소스 전부 함께 삭제)
kubectl delete namespace stevenlab
```




## NGINX

```angular2html

kubectl create ns stevenlab 2>/dev/null || true
kubectl apply -f app-nginx.yaml

kubectl -n stevenlab get deploy,rs,pod,svc -l app=nginx
kubectl -n stevenlab rollout status deploy/nginx

# 로컬에서 http://127.0.0.1:8080 열람
kubectl -n stevenlab port-forward deploy/nginx 8080:80

```

#### 외부에서 접근, 즉 Control Plane의 IP로 접근하게 하려면.
kubectl apply -f nginx-nodeport.yaml

http://<노드(호스트)IP>:30080





