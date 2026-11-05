pipeline {
    agent any

    tools {
        jdk 'JDK17'      // must match the JDK name in Manage Jenkins > Tools
        maven 'Maven'    // must match the Maven name in Manage Jenkins > Tools
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Karate tests') {
            steps {
                bat 'mvn clean test -P regression'
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
            publishHTML(target: [
                reportDir: 'target/karate-reports',
                reportFiles: 'karate-summary.html',
                reportName: 'Karate Report',
                keepAll: true,
                alwaysLinkToLastBuild: true,
                allowMissing: true
            ])
            archiveArtifacts artifacts: 'target/karate-reports/**', allowEmptyArchive: true
        }
    }
}