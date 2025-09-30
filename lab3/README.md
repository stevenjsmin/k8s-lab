
# Lab3 -Creating two different apps on OpenShift.


-----
# lab3 - Create simple Java Springboot application on OpenShift
https://github.com/stevenjsmin/stevenlab-springboot-helloworld

#### Make sure developer
- oc whoami
- oc whoami --show-server
- oc login --token=xxxxxxxxxx --server=https://api.crc.testing:6443

- oc project stevenlab-project

#### Deploy application
You'll have to manually specify the service/port if the image's Dockerfile doesn't have EXPOSE 8080. This is handled in the steps below.
> Source Scanning: Git, Docker
> Create Resources : BuildConfig, ImageStream
> Build/Deploy

- oc new-app --name=springboot-helloworld --docker-image=trialqdcy13.jfrog.io/stevenlab-docker-local/springboot-helloworld:1.0.0
```angular2html
  --> Creating resources ...
  deployment.apps "springboot-helloworld" created
  service "springboot-helloworld" created
  --> Success
  Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
  'oc expose service/springboot-helloworld'
  Run 'oc status' to view your app.

```

#### Expose to Route
- oc expose svc/springboot-helloworld
Check Route DNS name
- oc get route springboot-helloworld -o jsonpath='{.spec.host}{"\n"}'


### Troubleshooting
Problem while create PODs
Failed to pull image "trialqdcy13.jfrog.io/stevenlab-docker-local/springboot-helloworld:1.0.0": initializing source docker://trialqdcy13.jfrog.io/stevenlab-docker-local/springboot-helloworld:1.0.0: unable to retrieve auth token: invalid username/password: unknown: Bad Credentials

어디서 실패했는지 확인
oc get pod
oc describe pod springboot-helloworld-5bf565d679-4pjjn | sed -n '/Events/,$p'


oc create secret docker-registry jfrog-registry-secret \
--docker-server=trialqdcy13.jfrog.io \
--docker-username=[YOUR USERNAME-NORMALY EMAIL] \
--docker-password=xxxx \
--docker-email=[YOUR EMAIL] \
-n stevenlab-project


해당 시크릿을 default 서비스 어카운트에 붙여야 Pod가 프라이빗 이미지를 Pull 할 수 있다:
oc secrets link default jfrog-registry-secret --for=pull -n stevenlab-project



----

# lab3 - Create boxes application on OpenShift

### Local test
docker run -d --name boxes -p 8080:80 docker.io/stevenmin/boxes
docker run -d --name boxes -p 8080:80 trialqdcy13.jfrog.io/stevenlab-docker-local/boxes:1.0

### Create new OpenShift app
- oc new-app --name=boxes --docker-image=trialqdcy13.jfrog.io/stevenlab-docker-local/boxes:1.0
- oc expose svc/boxes
- oc get route boxes -o jsonpath='{.spec.host}{"\n"}'
