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
        - name: docker-config
          mountPath: /kaniko/.docker
    - name: awscli
      image: amazon/aws-cli:latest
      command: [sh, -c]
      args: [cat]
      tty: true
      env:
        - name: AWS_REGION
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: region
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: aws_access_key_id
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: aws_secret_access_key
      volumeMounts:
        - name: docker-config
          mountPath: /tmp/docker
    - name: git
      image: alpine/git:2.47.2
      command: [sh, -c]
      args: [cat]
      tty: true
  volumes:
    - name: docker-config
      emptyDir: {}
'''
        }
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_URL = '228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr'
        DEPLOY_BRANCH = 'final-project'
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

        stage('ECR login') {
            steps {
                container('awscli') {
                    sh '''
                      ECR_REGISTRY="${ECR_URL%/*}"
                      ECR_PASSWORD="$(aws ecr get-login-password --region "${AWS_REGION}")"
                      AUTH="$(printf 'AWS:%s' "${ECR_PASSWORD}" | base64 | tr -d '\\n')"
                      printf '{"auths":{"%s":{"auth":"%s"}}}' "${ECR_REGISTRY}" "${AUTH}" > /tmp/docker/config.json
                    '''
                }
            }
        }

        stage('Build and push image') {
            steps {
                container('kaniko') {
                    sh '''
                      /kaniko/executor \
                        --context="${WORKSPACE}" \
                        --dockerfile="${WORKSPACE}/Dockerfile" \
                        --destination="${ECR_URL}:${IMAGE_TAG}"
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
        always { cleanWs() }
        success { echo "Published ${ECR_URL}:${IMAGE_TAG}; Argo CD will synchronize it." }
        failure { echo 'Pipeline failed. Check the failed stage and pod logs.' }
    }
}
