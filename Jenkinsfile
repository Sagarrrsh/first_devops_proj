pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
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
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        wsl ansible-playbook -i '${env.INSTANCE_IP},' install_apache.yml \
                        --user=ubuntu \
                        --private-key=$SSH_KEY \
                        --ssh-common-args='-o StrictHostKeyChecking=no'
                    """
                }
            }
        }
    }
}
