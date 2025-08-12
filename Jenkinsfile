pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')     // AWS key ID stored in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key') // AWS secret stored in Jenkins
    }

    stages {
        stage('Terraform Apply') {
            steps {
                dir('Terraform') {
                    // Run Terraform init and apply as Windows bat commands
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get Instance IP') {
            steps {
                script {
                    dir('Terraform') {
                        // Capture only the raw IP (no command prompt) from Terraform output
                        env.INSTANCE_IP = bat(script: 'terraform output -raw public_ip', returnStdout: true).trim()
                        echo "EC2 Public IP: ${env.INSTANCE_IP}"
                    }
                }
            }
        }

        stage('Run Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2_ssh_key',  // Your Jenkins SSH credential ID
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    script {
                        // Convert Windows Jenkins workspace path to WSL Linux path
                        // Jenkins workspace root on Windows is usually under C:\ProgramData\Jenkins\.jenkins\workspace\<job_name>
                        def playbookPath = "/mnt/c/ProgramData/Jenkins/.jenkins/workspace/${env.JOB_NAME}/Ansible/install_apache.yml"

                        sh """
                            wsl /usr/bin/ansible-playbook \
                              -i '${env.INSTANCE_IP},' \
                              '${playbookPath}' \
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
