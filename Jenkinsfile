pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-build
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
    - name: aws-secret
      mountPath: /root/.aws
  - name: git-git
    image: alpine/git:latest
    command:
    - sleep
    args:
    - 99d
  volumes:
  - name: aws-secret
    secret:
      secretName: aws-credentials # Секрет із вашими AWS інтерейсами в K8s
'''
        }
    }

    environment {
        ECR_URL   = '228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr'
        REPO_URL  = 'https://github.com/Anastasia-Danyliuk/lesson-7-Kubernetes.git'
    }

    stages {
        stage('Build & Push to ECR via Kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --context=dir://. \
                      --dockerfile=Dockerfile \
                      --destination=${ECR_URL}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Update Helm Values') {
            steps {
                container('git-git') {
                    sh """
                    sed -i "s|tag:.*|tag: \\"${BUILD_NUMBER}\\"|g" charts/django-app/values.yaml
                    """
                }
            }
        }

        stage('Push Changes to GitHub') {
            steps {
                container('git-git') {
                    withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                        git config user.email "nastia.danyliuk@example.com"
                        git config user.name "Anastasia Danyliuk"

                        git add charts/django-app/values.yaml
                        git commit -m "chore: update image tag to ${BUILD_NUMBER} [skip ci]"

                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Anastasia-Danyliuk/lesson-7-Kubernetes.git HEAD:lesson-8-9
                        '''
                    }
                }
            }
        }
    }
}