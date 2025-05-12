pipeline {
    agent any

    environment {
        GRADLE_OPTS = "-Dorg.gradle.daemon=false" // Avoid Gradle daemon issues in CI
        VERSION = "${env.BUILD_ID}" // Tag builds with Jenkins build ID
    }

    stages {
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Set up SonarQube environment
                    withSonarQubeEnv(installationName: 'sonarserver', credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew clean build sonarqube --info'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
    }
}
