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
                dir('ansible') {
                    script {
                        def ip = bat(script: "terraform -chdir=../terraform output -raw public_ip", returnStdout: true).trim()
                        echo "Ubuntu EC2 IP: ${ip}"
                        env.INSTANCE_IP = ip
                    }
                }
            }
        }
        
        stage('Run Ansible') {
            steps {
                dir('ansible') {
                    bat "wsl ansible-playbook -i ${env.INSTANCE_IP}, install_apache.yml --user=ubuntu --private-key=~/.ssh/id_rsa"
                }
            }
        }
    }
}