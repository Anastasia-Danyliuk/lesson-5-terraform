pipeline {
    agent {
        kubernetes {
            defaultContainer 'git'
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command: [/busybox/sh, -c]
      args: [cat]
      tty: true
      volumeMounts:
        - name: aws-credentials
          mountPath: /kaniko/.aws
          readOnly: true
    - name: git
      image: alpine/git:2.47.2
      command: [sh, -c]
      args: [cat]
      tty: true
  volumes:
    - name: aws-credentials
      secret:
        secretName: aws-credentials
'''
        }
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_URL = '228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr'
        DEPLOY_BRANCH = 'lesson-8-9'
        VALUES_FILE = 'charts/django-app/values.yaml'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Verify') {
            steps {
                sh 'test -f manage.py && test -f Dockerfile && test -f ${VALUES_FILE}'
            }
        }

        stage('Build and push image') {
            steps {
                container('kaniko') {
                    sh '''
                      /kaniko/executor \
                        --context="${WORKSPACE}" \
                        --dockerfile="${WORKSPACE}/Dockerfile" \
                        --destination="${ECR_URL}:${IMAGE_TAG}" \
                        --cache=true \
                        --cache-repo="${ECR_URL}-cache"
                    '''
                }
            }
        }

        stage('Update Helm image tag') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-token',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_TOKEN'
                )]) {
                    sh '''
                      sed -i -E 's|^(  tag: ).*$|\\1"'"${IMAGE_TAG}"'"|' "${VALUES_FILE}"
                      git config user.email "jenkins@example.com"
                      git config user.name "Jenkins CI"
                      git add "${VALUES_FILE}"
                      git diff --cached --quiet && exit 0
                      git commit -m "chore(deploy): use image ${IMAGE_TAG} [skip ci]"
                      AUTH_URL="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/Anastasia-Danyliuk/lesson-5-terraform.git"
                      git push "${AUTH_URL}" "HEAD:${DEPLOY_BRANCH}"
                    '''
                }
            }
        }
    }

    post {
        success { echo "Published ${ECR_URL}:${IMAGE_TAG}; Argo CD will synchronize it." }
        failure { echo 'Pipeline failed. Check the failed stage and pod logs.' }
    }
}
