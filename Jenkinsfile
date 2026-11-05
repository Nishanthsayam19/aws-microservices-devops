
pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '551336603749'
        ECR_REGISTRY = '551336603749.dkr.ecr.ap-south-1.amazonaws.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Project') {
            steps {
                bat 'if not exist user-service\\Dockerfile exit /b 1'
                bat 'if not exist product-service\\Dockerfile exit /b 1'
                bat 'if not exist order-service\\Dockerfile exit /b 1'
                echo 'All three Dockerfiles are available.'
            }
        }

        stage('Build User Service') {
            steps {
                bat 'docker build -t user-service:%BUILD_NUMBER% -t user-service:latest .\\user-service'
            }
        }

        stage('Build Product Service') {
            steps {
                bat 'docker build -t product-service:%BUILD_NUMBER% -t product-service:latest .\\product-service'
            }
        }

        stage('Build Order Service') {
            steps {
                bat 'docker build -t order-service:%BUILD_NUMBER% -t order-service:latest .\\order-service'
            }
        }

        stage('Verify Docker Images') {
            steps {
                bat 'docker image inspect user-service:%BUILD_NUMBER%'
                bat 'docker image inspect product-service:%BUILD_NUMBER%'
                bat 'docker image inspect order-service:%BUILD_NUMBER%'
                bat 'docker images'
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-ecr-credentials',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    bat '''
                        set AWS_DEFAULT_REGION=ap-south-1
                        aws sts get-caller-identity
                        aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 551336603749.dkr.ecr.ap-south-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag Images for ECR') {
            steps {
                bat '''
                    docker tag user-service:latest 551336603749.dkr.ecr.ap-south-1.amazonaws.com/user-service:latest
                    docker tag product-service:latest 551336603749.dkr.ecr.ap-south-1.amazonaws.com/product-service:latest
                    docker tag order-service:latest 551336603749.dkr.ecr.ap-south-1.amazonaws.com/order-service:latest
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                bat '''
                    docker push 551336603749.dkr.ecr.ap-south-1.amazonaws.com/user-service:latest
                    docker push 551336603749.dkr.ecr.ap-south-1.amazonaws.com/product-service:latest
                    docker push 551336603749.dkr.ecr.ap-south-1.amazonaws.com/order-service:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'All three microservice Docker images built and pushed to Amazon ECR successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Console Output.'
        }
    }
}
