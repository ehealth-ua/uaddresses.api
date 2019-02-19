pipeline {
  agent {
    kubernetes {
      label 'delete-instance-uaddresses'
      defaultContainer 'jnlp'
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    stage: delete-instance
spec:
  tolerations:
  - key: "node"
    operator: "Equal"
    value: "ci"
    effect: "NoSchedule"
  containers:
  - name: gcloud
    image: google/cloud-sdk:234.0.0-alpine
    command:
    - cat
    tty: true
  nodeSelector:
    node: ci
'''
    }
  }
  stages {
    stage('Prepare instance') {
      agent {
        kubernetes {
          label 'prepare-instance-uaddresses'
          defaultContainer 'jnlp'
          yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    stage: prepare-instance
spec:
  tolerations:
  - key: "node"
    operator: "Equal"
    value: "ci"
    effect: "NoSchedule"
  containers:
  - name: gcloud
    image: google/cloud-sdk:234.0.0-alpine
    command:
    - cat
    tty: true
  nodeSelector:
    node: ci
'''
        }
      }
      steps {
        container(name: 'gcloud', shell: '/bin/sh') {
          withCredentials([file(credentialsId: 'e7e3e6df-8ef5-4738-a4d5-f56bb02a8bb2', variable: 'KEYFILE')]) {
            sh 'gcloud auth activate-service-account jenkins-pool@ehealth-162117.iam.gserviceaccount.com --key-file=${KEYFILE} --project=ehealth-162117'
            sh 'gcloud container node-pools create uaddresses-build-${BUILD_NUMBER} --cluster=dev --machine-type=n1-highcpu-16 --node-taints=ci=${BUILD_TAG}:NoSchedule --node-labels=node=${BUILD_TAG} --num-nodes=1 --zone=europe-west1-d --preemptible'
          }
          slackSend (color: '#8E24AA', message: "Instance for ${env.BUILD_TAG} created")
        }
      }
    }
    stage('Test and build') {
      environment {
        MIX_ENV = 'test'
        DOCKER_NAMESPACE = 'edenlabllc'
        APPS = '[{"app":"uaddresses_api","chart":"uaddresses","namespace":"uaddresses","deployment":"api","label":"api"}]'
        POSTGRES_VERSION = '9.6'
        POSTGRES_USER = 'postgres'
        POSTGRES_PASSWORD = 'postgres'
        POSTGRES_DB = 'uaddresses_test'
      }
      parallel {
        stage('Test') {
          agent {
            kubernetes {
              label 'uaddresses-test'
              defaultContainer 'jnlp'
              yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    stage: test
spec:
  tolerations:
  - key: "ci"
    operator: "Equal"
    value: "${BUILD_TAG}"
    effect: "NoSchedule"
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "travis"
  containers:
  - name: elixir
    image: elixir:1.8.1
    command:
    - cat
    tty: true
  - name: postgres
    image: postgres:9.6
    ports:
    - containerPort: 5432
    tty: true
  nodeSelector:
    node: ${BUILD_TAG}
"""
            }
          }
          steps {
            container(name: 'elixir', shell: '/bin/sh') {
              sh '''
                mix local.hex --force
                mix local.rebar --force
                mix deps.get
                curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/tests.sh -o tests.sh; bash ./tests.sh
              '''
            }
          }
        }
        stage('Build') {
          environment {
            APPS = '[{"app":"uaddresses_api","label":"api","namespace":"uaddresses","chart":"uaddresses", "deployment":"api"}]'
            DOCKER_CREDENTIALS = 'credentials("20c2924a-6114-46dc-8e39-bfadd1cf8acf")'
            POSTGRES_USER = 'postgres'
            POSTGRES_PASSWORD = 'postgres'
            POSTGRES_DB = 'uaddresses_dev'
          }
          agent {
            kubernetes {
              label 'uaddresses-build'
              defaultContainer 'jnlp'
              yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    stage: build
spec:
  tolerations:
  - key: "ci"
    operator: "Equal"
    value: "${BUILD_TAG}"
    effect: "NoSchedule"
  containers:
  - name: docker
    image: liubenokvlad/docker:18.09-alpine-elixir-1.8.1
    env:
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: DOCKER_HOST 
      value: tcp://localhost:2375 
    command:
    - cat
    tty: true
  - name: postgres
    image: lakone/postgres:9.6.11-alpine
    ports:
    - containerPort: 5432
    tty: true
  - name: dind
    image: docker:18.09.2-dind
    securityContext: 
        privileged: true 
    ports:
    - containerPort: 2375
    tty: true
    volumeMounts: 
    - name: docker-graph-storage 
      mountPath: /var/lib/docker
  volumes: 
    - name: docker-graph-storage 
      emptyDir: {}
  nodeSelector:
    node: ${BUILD_TAG}
"""
            }
          }
          steps {
            container(name: 'docker', shell: '/bin/sh') {
              sh 'apk update && apk add --no-cache jq curl bash elixir git ncurses-libs zlib ca-certificates openssl erlang-crypto erlang-runtime-tools;'
              sh 'echo " ---- step: Build docker image ---- ";'
              sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/build-container.sh -o build-container.sh; bash ./build-container.sh'
              sh 'echo " ---- step: Start docker container ---- ";'
              sh 'mix local.rebar --force'
              sh 'mix local.hex --force'
              sh 'mix deps.get'
              sh 'sed -i "s/DB_HOST=travis/DB_HOST=${POD_IP}/g" .env'
              sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/start-container.sh -o start-container.sh; bash ./start-container.sh'
              withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh 'echo " ---- step: Push docker image ---- ";'
                sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/push-changes.sh -o push-changes.sh; bash ./push-changes.sh'
              }
            }
          }
          // post {
          //     always {
          //   container(name: 'docker', shell: '/bin/sh') {
          //     sh 'echo " ---- step: Remove docker image from host ---- ";'
          //     sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/remove-containers.sh -o remove-containers.sh; bash ./remove-containers.sh'
          //   }
          //     }
          // }
        }
      }
    }
    stage ('Deploy') {
      environment {
        APPS = '[{"app":"uaddresses_api","label":"api","namespace":"uaddresses","chart":"uaddresses", "deployment":"api"}]'
      }
      agent {
        kubernetes {
          label 'uaddresses-deploy'
          defaultContainer 'jnlp'
          yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    stage: deploy
spec:
  tolerations:
  - key: "ci"
    operator: "Equal"
    value: "${BUILD_TAG}"
    effect: "NoSchedule"
  containers:
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.13.2
    command:
    - cat
    tty: true
  nodeSelector:
    node: ${BUILD_TAG}
"""
        }
      }
      steps {
        container(name: 'kubectl', shell: '/bin/sh') {
          sh 'apk add curl bash'
          sh 'echo " ---- step: Deploy to cluster ---- ";'
          sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/autodeploy.sh -o autodeploy.sh; bash ./autodeploy.sh'
        }
      }
    }
//     stage('Delete instance') {
//       agent {
//         kubernetes {
//           label 'delete-instance-uaddresses-${BUILD_TAG}'
//           defaultContainer 'jnlp'
//           yaml '''
// apiVersion: v1
// kind: Pod
// metadata:
//   labels:
//     stage: prepare-instance
// spec:
//   tolerations:
//   - key: "node"
//     operator: "Equal"
//     value: "ci"
//     effect: "NoSchedule"
//   containers:
//   - name: gcloud
//     image: google/cloud-sdk:234.0.0-alpine
//     command:
//     - cat
//     tty: true
//   nodeSelector:
//     node: build-uaddresses-${BUILD_TAG}
// '''
//         }
//       }
//       steps {
//         container(name: 'gcloud', shell: '/bin/sh') {
//           withCredentials(file(credentialsId: 'e7e3e6df-8ef5-4738-a4d5-f56bb02a8bb2', variable: 'service-account')) {
//             sh 'gcloud auth activate-service-account jenkins-pool@ehealth-162117.iam.gserviceaccount.com --key-file=$service-account --project=ehealth-162117'
//             sh 'gcloud container node-pools delete uaddresses-build-${BUILD_TAG} --zone=europe-west1-d --cluster=dev --quiet'
//           }
//         }
//       }
//     }
  }
  post { 
    success {
      slackSend (color: 'good', message: "SUCCESSFUL: Job - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>) success in ${currentBuild.durationString}")
    }
    failure {
      slackSend (color: 'danger', message: "FAILED: Job - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>) failed in ${currentBuild.durationString}")
    }
    aborted {
      slackSend (color: 'warning', message: "ABORTED: Job - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>) canceled in ${currentBuild.durationString}")
    }
    always {
      node('delete-instance-uaddresses') {
        container(name: 'gcloud', shell: '/bin/sh') {
          withCredentials([file(credentialsId: 'e7e3e6df-8ef5-4738-a4d5-f56bb02a8bb2', variable: 'KEYFILE')]) {
            sh 'gcloud auth activate-service-account jenkins-pool@ehealth-162117.iam.gserviceaccount.com --key-file=${KEYFILE} --project=ehealth-162117'
            sh 'gcloud container node-pools delete uaddresses-build-${BUILD_NUMBER} --zone=europe-west1-d --cluster=dev --quiet'
          }
          slackSend (color: '#4286F5', message: "Instance for ${env.BUILD_TAG} deleted")
        }
      }
    }
  }
}
