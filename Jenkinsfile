pipeline {
  agent none
  environment {
    VER = "1.12.3"
  }
  stages {
    stage('Build') {
      agent {
        kubernetes {
          inheritFrom 'kaniko'
        }
      }
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        checkout([$class: 'GitSCM', branches: [[name: 'test']],
          userRemoteConfigs: [[url: 'https://github.com/EnthrallRecords/vue-storefront-container.git']]])
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor --build-arg STOREFRONT_VERSION=v$VER -c "$WORKSPACE" --skip-tls-verify \
            --destination=containers.internal/vue-storefront:$BUILD_ID \
            --destination=containers.internal/vue-storefront:$VER
          '''
        }
      }
    }
    stage('Build with Braintree') {
      agent {
        kubernetes {
          inheritFrom 'kaniko'
        }
      }
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        checkout([$class: 'GitSCM', branches: [[name: 'test']],
          userRemoteConfigs: [[url: 'https://github.com/EnthrallRecords/vue-storefront-container.git']]])
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor --build-arg BASE=vue-storefront:$BUILD_ID -c `pwd` -f Dockerfile-braintree --skip-tls-verify \
            --destination=containers.internal/vue-storefront:braintree-$BUILD_ID \
            --destination=containers.internal/vue-storefront:braintree-$VER
          '''
        }
      }
    }
    stage('Deploy') {
      agent {
        kubernetes {
          yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  serviceAccount: jenkins
  containers:
  - name: kubectl
    image: containers.internal/kubectl:latest
    imagePullPolicy: Always
    command:
    - sh
    args:
    - -c
    - cat
    tty: true
""" 
        }
      }
      steps {
        container(name: 'kubectl', shell: '/bin/sh') {
          sh '''#!/bin/sh
          kubectl -n enthrall-test-store set image deployment.v1.apps/vuestorefront vuestorefront=containers.internal/vue-storefront:braintree-$BUILD_ID
          kubectl -n enthrall-test-store set image deployment.v1.apps/vuestorefront-canary vuestorefront=containers.internal/vue-storefront:braintree-$VER
          '''
        }
      }
    }
  }
}