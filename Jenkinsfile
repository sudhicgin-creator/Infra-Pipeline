pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        AWS_ACCESS_KEY_ID = "${AWS_CREDENTIALS_USR}"
        AWS_SECRET_ACCESS_KEY = "${AWS_CREDENTIALS_PSW}"
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check'
            }
        }
        
        stage('Terraform Validate') {
            steps {
                sh 'terraform init'
                sh 'terraform validate'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Manual Approval') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Deploy'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Fetch Terraform Outputs') {
            steps {
                script {
                    env.WEB_IP = sh(script: 'terraform output -raw web_instance_private_ip', returnStdout: true).trim()
                    env.APP_IP = sh(script: 'terraform output -raw app_instance_private_ip', returnStdout: true).trim()
                    env.RDS_ENDPOINT = sh(script: 'terraform output -raw rds_endpoint', returnStdout: true).trim()
                    echo "Web IP: ${env.WEB_IP}"
                    echo "App IP: ${env.APP_IP}"
                    echo "RDS Endpoint: ${env.RDS_ENDPOINT}"
                }
            }
        }
        
        stage('Configure NGINX with Ansible') {
            steps {
                dir('ansible') {
                    sshagent(credentials: ['ssh-key']) {
                        sh '''
                            ansible-playbook site.yml \
                            -i aws_ec2.yml \
                            --ssh-common-args='-o StrictHostKeyChecking=no' \
                            -v | tee ansible.log
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
            archiveArtifacts artifacts: 'ansible/ansible.log', allowEmptyArchive: true
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
