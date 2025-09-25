# k8s-lab




# 아래 커맨드는 local의 kubeadmin으로 실핼했을때 가능했음..developer를 위해서는 추가 권한 설정이 필요해봉ㅁ
oc create configmap message-map --from-literal MESSAGE="Hello from configMap"

oc get configmap message-map -o yaml
