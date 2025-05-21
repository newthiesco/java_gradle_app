pipeline {
    agent any

    environment {
        VERSION = "${env.BUILD_ID}" // Version is set from Jenkins Build ID
        DOCKER_HOSTED_EP = "3.92.204.104:8083"   // Nexus Docker repo endpoint
    }

    stages {
        stage("Sonar Quality Check") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube --info'
                    }

                    timeout(time: 15, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        } // ✅ Closing brace added here

        stage("Build Docker Image & Push to Nexus") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_pass_var')]) {
                        sh """
                            echo "🔧 Building Docker image..."
                            docker build -t ${DOCKER_HOSTED_EP}/javawebapp:${VERSION} .

                            echo "🔐 Logging into Nexus Docker registry..."
                            docker login -u admin -p ${nexus_pass_var} ${DOCKER_HOSTED_EP}

                            echo "📦 Pushing Docker image to Nexus..."
                            docker push ${DOCKER_HOSTED_EP}/javawebapp:${VERSION}

                            echo "🧹 Cleaning up local Docker image..."
                            docker rmi ${DOCKER_HOSTED_EP}/javawebapp:${VERSION}
                        """
                    }
                }
            }
        }
    }
}
