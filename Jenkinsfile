pipeline {
    agent any

    environment {
        VERSION = "${env.BUILD_ID}" // Version from Jenkins Build ID
        DOCKER_HOSTED_EP = "3.92.204.104:8083"   // Nexus Docker repo endpoint
        HELM_HOSTED_EP = "3.92.204.104:8081"     // Nexus Helm repo endpoint
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
        }

        stage("Build Docker Image & Push to Nexus") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'NEXUS_PASS')]) {
                        sh '''
                            echo "🔧 Building Docker image..."
                            docker build -t ${DOCKER_HOSTED_EP}/javawebapp:${VERSION} .

                            echo "🔐 Logging into Nexus Docker registry..."
                            echo "${NEXUS_PASS}" | docker login -u admin --password-stdin ${DOCKER_HOSTED_EP}

                            echo "📦 Pushing Docker image to Nexus..."
                            docker push ${DOCKER_HOSTED_EP}/javawebapp:${VERSION}
                        '''
                    }
                }
            }
        }

        stage("Push Helm Charts to Nexus Repo") {
            steps {
                script {
                    dir('kubernetes/') {
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
