
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
                    def tfsecImage = docker.image('aquasec/tfsec')
                    tfsecImage.inside("-v ${pwd()}:/src") {
                        sh 'tfsec /src'
                    }
                }
        }

        stage('Terraform Init') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: params.AWS_CREDENTIAL_ID,
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                    cd application/ecs-backend
                    terraform init
                    '''
                    }
                }
            }
        }

        stage('Terraform Validation') {
            steps {
                echo 'Validating...'
                sh '''
                cd application/ecs-backend
                terraform validate
                '''
            }
        }
        // stage('Create or Select Workspace UAT') {
        //     steps {
        //         sh 'terraform workspace new uat || terraform workspace select uat'
        //     }
        // }

        stage('Terraform plan uat') {
            steps {
                echo 'Planning...'
                sh '''
            cd application/ecs-backend
            terraform plan -var-file=uat.tfvars
            '''
            }
        }

      
    }

    post {
            always {
                cleanWs()
            }
    }
}
