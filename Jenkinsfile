
pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
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

        stage('Login and Push to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin %ECR_REGISTRY%

                        docker tag user-service:%BUILD_NUMBER% %ECR_REGISTRY%/user-service:%BUILD_NUMBER%
                        docker tag user-service:%BUILD_NUMBER% %ECR_REGISTRY%/user-service:latest

                        docker tag product-service:%BUILD_NUMBER% %ECR_REGISTRY%/product-service:%BUILD_NUMBER%
                        docker tag product-service:%BUILD_NUMBER% %ECR_REGISTRY%/product-service:latest

                        docker tag order-service:%BUILD_NUMBER% %ECR_REGISTRY%/order-service:%BUILD_NUMBER%
                        docker tag order-service:%BUILD_NUMBER% %ECR_REGISTRY%/order-service:latest

                        docker push %ECR_REGISTRY%/user-service:%BUILD_NUMBER%
                        docker push %ECR_REGISTRY%/user-service:latest

                        docker push %ECR_REGISTRY%/product-service:%BUILD_NUMBER%
                        docker push %ECR_REGISTRY%/product-service:latest

                        docker push %ECR_REGISTRY%/order-service:%BUILD_NUMBER%
                        docker push %ECR_REGISTRY%/order-service:latest

                        docker logout %ECR_REGISTRY%
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                bat '''
                    ssh -o StrictHostKeyChecking=accept-new -i "C:\\ProgramData\\Jenkins\\secrets\\training-key.pem" ubuntu@15.206.117.145 "cd ~/aws-microservices-devops && aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 551336603749.dkr.ecr.ap-south-1.amazonaws.com && IMAGE_TAG=%BUILD_NUMBER% docker compose pull && IMAGE_TAG=%BUILD_NUMBER% docker compose up -d && for i in 1 2 3 4 5 6 7 8 9 10 11 12; do if curl -fsS http://localhost/users/health >/dev/null && curl -fsS http://localhost/products/health >/dev/null && curl -fsS http://localhost/orders/health >/dev/null; then echo DEPLOYMENT_SUCCESS; exit 0; fi; sleep 5; done; echo DEPLOYMENT_FAILED; exit 1"
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: All three microservices were pushed to ECR and deployed successfully to EC2!'
        }
        failure {
            echo 'Pipeline failed. Check the Console Output.'
        }
    }
}
