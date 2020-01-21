pipeline {
  agent none
  environment {
    VER = "1.11.0"
  }
  stages {
    stage('Build with Kaniko') {
      agent {
        kubernetes {
          label "kaniko"
          yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  nodeSelector:
    hardware: minipc
  tolerations:
  - key: "resource"
    operator: "Equal"
    value: "limited"
    effect: "PreferNoSchedule"
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-v0.15.0
    command:
    - /busybox/cat
    tty: true
"""
        }
      }
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        checkout([$class: 'GitSCM', branches: [[name: env.GIT_BRANCH]],
          userRemoteConfigs: [[url: 'https://github.com/EnthrallRecords/vue-storefront-container.git']]])
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor --build-arg BRANCH=custom -c `pwd` --skip-tls-verify --destination=containers.internal/vue-storefront:$VER --destination=containers.internal/vue-storefront:$BUILD_ID
          /kaniko/executor --build-arg BASE=containers.internal/vue-storefront:$BUILD_ID -c `pwd` -f Dockerfile-extcheckout --skip-tls-verify --destination=containers.internal/vue-storefront:extcheckout-$VER --destination=containers.internal/vue-storefront:extcheckout-$BUILD_ID
          '''
        }
      }
    }
    stage('Deploy') {
      agent {
        kubernetes {
          label "kubectl"
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
          kubectl -n vuestorefront set image deployment.v1.apps/vuestorefront vuestorefront=containers.internal/vue-storefront:$BUILD_ID
          '''
        }
      }
    }
  }
}

def getRepoURL() {
  sh "git config --get remote.origin.url > .git/remote-url"
  return readFile(".git/remote-url").trim()
}
 
def getCommitSha() {
  sh "git rev-parse HEAD > .git/current-commit"
  return readFile(".git/current-commit").trim()
}
 
def updateGithubCommitStatus(build) {
  // workaround https://issues.jenkins-ci.org/browse/JENKINS-38674
  repoUrl = getRepoURL()
  commitSha = getCommitSha()
 
  step([
    $class: 'GitHubCommitStatusSetter',
    reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
    commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commitSha],
    errorHandlers: [[$class: 'ShallowAnyErrorHandler']],
    statusResultSource: [
      $class: 'ConditionalStatusResultSource',
      results: [
        [$class: 'BetterThanOrEqualBuildResult', result: 'SUCCESS', state: 'SUCCESS', message: build.description],
        [$class: 'BetterThanOrEqualBuildResult', result: 'FAILURE', state: 'FAILURE', message: build.description],
        [$class: 'AnyBuildResult', state: 'PENDING', message: build.description]
      ]
    ]
  ])
}