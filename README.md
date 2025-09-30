# K8s-lab

This lab introduces an environment for personal testing in K8s, OpenShift, CodeFresh, and Jenkins environments.

## Intro SandBox playground
- Local build(and Delivery) tool (Jenkins) (implemented on AWS)
- Local K8s Cluster (implemented on AWS)
- OpenShift on RedHat DevSandbox (14 days trial)
- OpenShift on local (Heavy load, Limited intigration with CodeFreh)
- CodeFresh (Resource limitations/Constrations)
- Artifact registry (30 trial version) serviced by JFrom as SaaS
  - Docker (vs. docker.io)
  - Maven (for Java dependancy)
  - Python module
  - Helm 
  - ....
- VCS - github.com
  - https://github.com/stevenjsmin/k8s-lab (this)
  - https://github.com/stevenjsmin/boxes (web service)
  - https://github.com/stevenjsmin/stevenlab-springboot-helloworld (java)
  - https://github.com/stevenjsmin/openshift-hello-world-go (go)
  - https://github.com/stevenjsmin/stevenlab-pipeline (jenkins pipeline)
  - https://github.com/stevenjsmin/stevenlab-jenkins-libs (jenkins pipeline - shared lib)
  - https://github.com/stevenjsmin/stevenlab-powershell (PowerShell code to test in Linux) 


------
## K8S vs. OpenShift
- Compare Controller typs and Workloads and Architecture
  - Typs Controller
  - Architrcture
  - Delivery Flow

<img width="600" alt="1 k8s-architecture" src="https://github.com/user-attachments/assets/3f01b607-9f38-4c48-8207-5a87f63af8b9" />

*OpenShift Architecture*

<img width="600" alt="2 openshift-architecture" src="https://github.com/user-attachments/assets/bbe1b24f-ada5-4452-8f76-79bb4d0c6c89" />

*K8s Container flow*

<img width="600" alt="3 k8s_container-flow" src="https://github.com/user-attachments/assets/022d624d-77ca-40e3-add8-aa2145a1bbad" />

*K8s Controllers*

<img width="600" alt="4 k8s-controllers" src="https://github.com/user-attachments/assets/3b6bdb25-5191-43ee-8a99-18aaef75b568" />



------



## Lab2
#### Create Boxes and Nginx on K8S cluster
- Using SasS jfrog.io Repository(Docker img, Maven(Java), Flate file...)
- Create secrete

- Create simple Boxes app (--> Could be skipped, to show compare K8s and OpenShift)
   - https://github.com/stevenjsmin/boxes
  
- Create simple Nginx app
------

## Lab3
#### Create simple Java Springboot application on (my local) OpenShift
- Intro project
  - https://github.com/stevenjsmin/stevenlab-springboot-helloworld.git

- Intro Jenkins pipeline to build 

- Create Java Springboot application on Openshift 
