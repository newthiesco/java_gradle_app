pipeline {
    agent any

    environment {
        GRADLE_OPTS = "-Dorg.gradle.daemon=false"  // Prevent background Gradle processes
        VERSION = "${env.BUILD_ID}"               // Version is set from Jenkins Build ID
        DOCKER_HOSTED_EP = "34.229.88.101:8081"   // Nexus Docker repo endpoint
    }

    stages {

        stage('Sonar Quality Check') {
            steps {
                script {
                    withSonarQubeEnv(installationName: 'sonarserver', credentialsId: 'sonar-token') {
                        // Ensure gradlew is executable and run SonarQube analysis
                        sh '''
                            chmod +x gradlew
                            ./gradlew clean build sonarqube --info --stacktrace
                        '''
                    }

                    timeout(time: 15, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "❌ Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

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

                            echo "🧹 Cleaning up local image..."
                            docker rmi ${DOCKER_HOSTED_EP}/javawebapp:${VERSION}
                        """
                    }
                }
            }
        }
    }
}
