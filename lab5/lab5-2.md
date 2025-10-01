
# Helm lab 5-2


-----

### Install Tomcat
```shell
  helm install tomcat bitnami/tomcat -n stevenlab
  
        NAME: tomcat
        LAST DEPLOYED: Tue Sep 30 08:31:26 2025
        NAMESPACE: stevenlab
        STATUS: deployed
        REVISION: 1
        TEST SUITE: None
        NOTES:
        CHART NAME: tomcat
        CHART VERSION: 12.0.8
        APP VERSION: 11.0.10
        
        ⚠ WARNING: Since August 28th, 2025, only a limited subset of images/charts are available for free.
            Subscribe to Bitnami Secure Images to receive continued support and security updates.
            More info at https://bitnami.com and https://github.com/bitnami/containers/issues/83267
        
        ** Please be patient while the chart is being deployed **
        
        1. Get the Tomcat URL by running:
        
          NOTE: It may take a few minutes for the LoadBalancer IP to be available.
                Watch the status with: 'kubectl get svc --namespace stevenlab -w tomcat'
        
          export SERVICE_IP=$(kubectl get svc --namespace stevenlab tomcat --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
          echo "Tomcat URL:            http://$SERVICE_IP/"
          echo "Tomcat Management URL: http://$SERVICE_IP/manager"
        
        2. Login with the following credentials
        
          echo Username: user
          echo Password: $(kubectl get secret --namespace stevenlab tomcat -o jsonpath="{.data.tomcat-password}" | base64 -d)
        
        WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
          - resources
        +info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
          
```

### 서비스 타입 변경 (외부 접근용)
기본은 ClusterIP라서 클러스터 내부에서만 접근된다. 외부에서 접근하려면 NodePort 또는 LoadBalancer를 써한다.
```shell
    # 다시 새로운 옵션으로 설치하고자 한다면
    helm uninstall tomcat
    helm install tomcat bitnami/tomcat -n stevenlab --set service.type=NodePort --set service.nodePorts.http=30080
```

-----
#### Troubleshooting
POD의 상태: ImagePullBackOff
POD의 주요 Described message: docker.io/bitnami/tomcat:11.0.10-debian-12-r4": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/bitnami/tomcat:11.0.10-debian-12-r4": failed to resolve reference "docker.io/bitnami/tomcat:11.0.10-debian-12-r4": docker.io/bitnami/tomcat:11.0.10-debian-12-r4: not found


"docker.io/bitnami/tomcat:11.0.10-debian-12-r4"는 실제로 도커이미지가 없어서 나는 오류로 보임.
조금 일반적인 태그(예: 11.0.10 또는 11.0.11 / latest)로 지정해서 다시 테스트
```shell
helm upgrade tomcat oci://registry-1.docker.io/bitnami/tomcat \
  -n stevenlab \
  --set image.repository=docker.io/bitnami/tomcat \
  --set image.tag=11.0.11 \        # 또는 11.0.10 / latest 등 존재하는 태그
  --set image.pullPolicy=IfNotPresent


    helm upgrade --install oci://registry-1.docker.io/bitnami/tomcat  \
    --set persistence.enabled=true \
    --set persistence.storageClass=gp3 \
    --set persistence.size=8Gi


helm install tomcat ci://registry-1.docker.io/bitnamicharts/tomcat -n stevenlab --set image.tag=latest --set persistence.enabled=true --set persistence.storageClass=gp3 --set persistence.size=8Gi --set service.type=NodePort --set service.nodePorts.http=30080

```



1. 현재 파드가 어떤 이미지/태그를 쓰는지 확인
```shell
kubectl -n stevenlab get pod tomcat-7fbfcbd4b9-ntl92 -o jsonpath='{.spec.containers[*].image}{"\n"}'
  --> docker.io/bitnami/tomcat:11.0.10-debian-12-r4
```



9.0.109-jre25


helm install tomcat bitnami/tomcat -n stevenlab --set image.tag=9.0.62 --set persistence.enabled=true --set persistence.storageClass=gp3 --set persistence.size=8Gi --set service.type=NodePort --set service.nodePorts.http=30080




---
helm install my-tomcat bitnamtomcat --namespace stevenlab --set service.type=NodePort
kubectl get pods,service -n stevenlab

helm upgrade my-tomcat bitnami/tomcat \
--namespace stevenlab \
--reuse-values

helm upgrade my-tomcat bitnami/tomcat --namespace stevenlab --reuse-values --set image.tag=9.0.62


test
