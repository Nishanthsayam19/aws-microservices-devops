pipeline {
    agent any

    options {
        timestamps()
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
    }

    post {
        success {
            echo 'All three microservice Docker images built successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Console Output.'
        }
    }
}
