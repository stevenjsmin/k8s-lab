
docker tag <IMAGE_ID> trialqdcy13.jfrog.io/stevenlab-docker-local/<DOCKER_IMAGE>:<DOCKER_TAG>
docker push trialqdcy13.jfrog.io/stevenlab-docker-local/<DOCKER_IMAGE>:<DOCKER_TAG>


docker build -t trialqdcy13.jfrog.io/stevenlab-docker-local/hello-world:1.0 .
docker push trialqdcy13.jfrog.io/stevenlab-docker-local/hello-world:1.0


oc create secret docker-registry jfrog-registry-secret \
--docker-server=trialqdcy13.jfrog.io \
--docker-username=[YOUR UESERNAME-NORMALLY EMAIL] \
--docker-password=xxxxxxxxx \
--docker-email=[YOUR EMAIL] \
-n stevenlab-project


해당 시크릿을 default 서비스 어카운트에 붙여야 Pod가 프라이빗 이미지를 Pull 할 수 있다:
oc secrets link default jfrog-registry-secret --for=pull -n stevenlab-project

## 생성된 시크릿이 기본 서비스계정과 연결되었는지 확인할수있다.
oc describe serviceaccount/default