
pipeline {
    agent { label 'jenkins_slave' }

    parameters {
        string(name: 'AWS_CREDENTIAL_ID', defaultValue: 'markwang access', description: 'The ID of the AWS credentials to use')
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'The Git branch to build and deploy')
        choice(
            name: 'TFOperation',
            choices: ['apply', 'destroy'],
            description: 'apply for creating, destroy for releasing the resources'
        )
        choice(
            name: 'Environment',
            choices: ['uat', 'prod'],
            description: 'Select the environment'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-southeast-2'
    }

    tools {
        nodejs 'jenkinsnode'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout the specified branch from GitHub
                    checkout([$class: 'GitSCM', branches: [[name: params.GIT_BRANCH]], userRemoteConfigs: [[url: 'https://github.com/TechScrumTeamBeta/techscrumjr11.be']]])
                }
            }
        }

         stage('TFsec scan'){
            steps {
                script {
                    ansiColor('xterm') {
                        try{
                        sh '''
                            tfsec .
                            '''
                        }catch(Exception e){
                            echo "TFsec found vulnerabilities, but continuing the build"
                            echo "${e.getMessage()}"
                        }

                    }
                }
            }
        }

       

      
    }

    post {
            always {
                cleanWs()
            }
    }
}
