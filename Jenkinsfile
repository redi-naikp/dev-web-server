pipeline {
  agent {
    docker {
      label 'static'
      image 'docker-registry.rdti.com/com.redi/builder:0.9'
      args '-v /var/run/docker.sock:/var/run/docker.sock --group-add 992'
    }
  }
  
  environment {
    TAG_VERSION = ''
  }

  stages {
    stage('Git Clone') {
      steps {
        ansiColor('xterm') {
          checkout scm
        }
      }
    }

    stage('Push') {
      steps {
        ansiColor('xterm') {
          sh '''
            IMAGE_VERSION=$(node --print "require('./package').version") npm run docker-build-and-push
          '''
        }
      }
    }

    stage('Version') {
      steps {
        script {
          TAG_VERSION=sh returnStdout: true, script: '''echo v$(node --print "require('./package').version")'''
        }
      }
    }
  }
}
