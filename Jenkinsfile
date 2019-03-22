pipeline {
  agent none
  environment {
    PROJECT_NAME = 'uaddresses'
    INSTANCE_TYPE = 'n1-highmem-16'
    RD = "b${UUID.randomUUID().toString()}"
    RD_CROP = "b${RD.take(14)}"
    NAME = "${RD.take(5)}"
  }
  stages {
    stage('Prepare instance') {
      agent {
        kubernetes {
          label 'create-instance'
          defaultContainer 'jnlp'
        }
      }
      steps {
        container(name: 'gcloud', shell: '/bin/sh') {
          sh 'apk update && apk add curl bash'
          withCredentials([file(credentialsId: 'e7e3e6df-8ef5-4738-a4d5-f56bb02a8bb2', variable: 'KEYFILE')]) {
            sh 'gcloud auth activate-service-account jenkins-pool@ehealth-162117.iam.gserviceaccount.com --key-file=${KEYFILE} --project=ehealth-162117'
            sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/create_instance.sh -o create_instance.sh; bash ./create_instance.sh'
          }
          slackSend (color: '#8E24AA', message: "Instance for ${env.BUILD_TAG} created")
        }
      }
      post {
        success {
          slackSend (color: 'good', message: "Job - ${env.BUILD_TAG} STARTED (<${env.BUILD_URL}|Open>)")
        }
        failure {
          slackSend (color: 'danger', message: "Job - ${env.BUILD_TAG} FAILED to start (<${env.BUILD_URL}|Open>)")
        }
        aborted {
          slackSend (color: 'warning', message: "Job - ${env.BUILD_TAG} ABORTED before start (<${env.BUILD_URL}|Open>)")
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
      failFast true
      parallel {
        stage('Test') {
          agent {
            kubernetes {
              label "uaddresses-test-$NAME"
              defaultContainer 'jnlp'
              yaml """
apiVersion: v1
kind: Pod
spec:
  tolerations:
  - key: "ci"
    operator: "Equal"
    value: "$RD_CROP"
    effect: "NoSchedule"
  containers:
  - name: elixir
    image: elixir:1.8.1
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "4048Mi"
        cpu: "2000m"
  - name: postgres
    image: postgres:9.6
    ports:
    - containerPort: 5432
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "2048Mi"
        cpu: "1000m"
  nodeSelector:
    node: "$RD_CROP"
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
              label "uaddresses-build-$NAME"
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
    value: "$RD_CROP"
    effect: "NoSchedule"
  containers:
  - name: docker
    image: edenlabllc/docker:18.09-alpine-elixir-1.8.1
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
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "2048Mi"
        cpu: "1000m"
  - name: postgres
    image: edenlabllc/postgres:9.6.11-alpine
    ports:
    - containerPort: 5432
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "2048Mi"
        cpu: "1000m"
  - name: dind
    image: docker:18.09.2-dind
    securityContext: 
        privileged: true 
    ports:
    - containerPort: 2375
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "5048Mi"
        cpu: "2000m"
    volumeMounts: 
    - name: docker-graph-storage 
      mountPath: /var/lib/docker
  volumes: 
    - name: docker-graph-storage 
      emptyDir: {}
  nodeSelector:
    node: "$RD_CROP"
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
              sh 'sed -i "s/travis/${POD_IP}/g" .env'
              sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/start-container.sh -o start-container.sh; bash ./start-container.sh'
              withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh 'echo " ---- step: Push docker image ---- ";'
                sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/push-changes.sh -o push-changes.sh; bash ./push-changes.sh'
              }
            }
          }
        }
      }
    }
    stage ('Deploy') {
      when {
        allOf {
            environment name: 'CHANGE_ID', value: ''
            branch 'develop'
        }
      }
      environment {
        APPS = '[{"app":"uaddresses_api","label":"api","namespace":"uaddresses","chart":"uaddresses", "deployment":"api"}]'
      }
      agent {
        kubernetes {
          label "uaddresses-deploy-$NAME"
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
    value: "$RD_CROP"
    effect: "NoSchedule"
  containers:
  - name: kubectl
    image: edenlabllc/k8s-kubectl:v1.13.2
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "1024Mi"
        cpu: "500m"
      limits:
        memory: "2048Mi"
        cpu: "1000m"
  nodeSelector:
    node: "$RD_CROP"
"""
        }
      }
      steps {
        container(name: 'kubectl', shell: '/bin/sh') {
          sh 'apk add curl bash jq'
          sh 'echo " ---- step: Deploy to cluster ---- ";'
          sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/autodeploy.sh -o autodeploy.sh; bash ./autodeploy.sh'
        }
      }
    }
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
      node('delete-instance') {
        container(name: 'gcloud', shell: '/bin/sh') {
          withCredentials([file(credentialsId: 'e7e3e6df-8ef5-4738-a4d5-f56bb02a8bb2', variable: 'KEYFILE')]) {
            sh 'apk update && apk add curl bash'
            sh 'gcloud auth activate-service-account jenkins-pool@ehealth-162117.iam.gserviceaccount.com --key-file=${KEYFILE} --project=ehealth-162117'
            sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/delete_instance.sh -o delete_instance.sh; bash ./delete_instance.sh'
          }
          slackSend (color: '#4286F5', message: "Instance for ${env.BUILD_TAG} deleted")
        }
      }
    }
  }
}
