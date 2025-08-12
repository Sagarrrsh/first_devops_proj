pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }

    stages {

        stage('Terraform Apply') {
            steps {
                dir('Terraform') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get Instance IP') {
            steps {
                script {
                    dir('Terraform') {
                        // Get only the IP string (no extra text)
                        env.INSTANCE_IP = bat(
                            script: 'terraform output -raw public_ip',
                            returnStdout: true
                        ).trim()
                        echo "EC2 Public IP: ${env.INSTANCE_IP}"
                    }
                }
            }
        }

        stage('Run Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2_ssh_key', // change to your actual Jenkins credential ID
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    script {
                        // Local G:\devops-proj-1\Ansible path in WSL format
                        def playbookPath = "/mnt/g/devops-proj-1/Ansible/install-apache.yml"

                        sh """
                            wsl /usr/bin/ansible-playbook \
                            -i '${env.INSTANCE_IP},' '${playbookPath}' \
                            --user=ubuntu \
                            --private-key="$SSH_KEY" \
                            --ssh-common-args='-o StrictHostKeyChecking=no'
                        """
                    }
                }
            }
        }
    }
}
