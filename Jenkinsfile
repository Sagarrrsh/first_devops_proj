pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        SSH_KEY = credentials('ec2_ssh_key')
    }
    
    stages {
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Get Instance IP') {
            steps {
                script {
                    dir('terraform') {
                        env.INSTANCE_IP = bat(script: 'terraform output -raw public_ip', returnStdout: true).trim()
                        echo "Ubuntu EC2 IP: ${env.INSTANCE_IP}"
                    }
                }
            }
        }
        
        stage('Run Ansible') {
            steps {
                dir('ansible') {
                    bat "wsl ansible-playbook -i ${env.INSTANCE_IP}, install_apache.yml --user=ubuntu --private-key=~/.ssh/id_rsa --ssh-common-args='-o StrictHostKeyChecking=no'"
                }
            }
        }
    }
}