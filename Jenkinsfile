pipeline {
    agent any

    environment {
        GRADLE_OPTS = "-Dorg.gradle.daemon=false" // To avoid daemon issues
        VERSION = "${env.BUILD_ID}" // Corrected syntax for environment variable
    }

    stages {
        stage('Sonar Quality Check') {
            steps {
                withSonarQubeEnv(installationName: 'sonarserver', credentialsId: 'sonar-token') {
                    // Make gradlew executable and run the SonarQube analysis
                    sh 'chmod +x gradlew'
                    sh './gradlew clean build sonarqube --info'
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
}
