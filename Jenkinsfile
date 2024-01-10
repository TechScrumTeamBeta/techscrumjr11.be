
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
                    // docker run --rm -it -v "$(pwd):/src" aquasec/tfsec /src

                    sh '''
                    cd BackendTF
                    tfsec .
                    '''
                    // def tfsecImage = docker.image('aquasec/tfsec')
                    // tfsecImage.inside("-v ${pwd()}:/src") {
                    //     sh 'tfsec /src'
                    // }
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
