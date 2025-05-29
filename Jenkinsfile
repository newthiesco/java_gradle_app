pipeline {
    agent any

    environment {
        GRADLE_OPTS = "-Dorg.gradle.daemon=false"  // Prevent background Gradle processes
        VERSION = "${env.BUILD_ID}"               // Version is set from Jenkins Build ID
        DOCKER_HOSTED_EP = "34.227.172.55:8083"   // Nexus Docker repo endpoint
        HELM_HOSTED_EP = "34.227.172.55:8081"
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
        stage("Push Helm Charts to Nexus Repo"){
            steps{
                script{
                    dir('kubernetes/'){
                        withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_pass_var')]) {
                            sh '''
                            helmchartversion=$(helm show chart myapp/ | grep version | awk '{print $2}')
                            helm package myapp/
                            curl -u admin:$nexus_pass_var http://$HELM_HOSTED_EP/repository/helm-hosted/ --upload-file myapp-${helmchartversion}.tgz -v
                            '''
                        }   
                    }
                }
            }
        }
    }
}
