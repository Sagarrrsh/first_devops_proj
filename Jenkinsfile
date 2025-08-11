pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }
    stages {
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    wsl -d Ubuntu bash -c "
                        cd /mnt/c/ProgramData/Jenkins/.jenkins/workspace/${JOB_NAME}/terraform &&
                        terraform init &&
                        terraform apply -auto-approve
                    "
                    '''
                }
            }
        }
        stage('Run Ansible') {
            steps {
                dir('ansible') {
                    script {
                        def ip = sh(script: '''
                            wsl -d Ubuntu bash -c "
                                cd /mnt/c/ProgramData/Jenkins/.jenkins/workspace/${JOB_NAME}/terraform &&
                                terraform output -raw public_ip
                            "
                        ''', returnStdout: true).trim()
                        echo "Ubuntu EC2 IP: ${ip}"
                        withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'SSH_KEY_FILE')]) {
                            sh """
                            wsl -d Ubuntu bash -c '
                                mkdir -p ~/.ssh &&
                                cp /mnt/c/$(echo ${SSH_KEY_FILE} | sed "s#:#/#g") ~/.ssh/id_rsa &&
                                chmod 600 ~/.ssh/id_rsa &&
                                cd /mnt/c/ProgramData/Jenkins/.jenkins/workspace/${JOB_NAME}/ansible &&
                                ansible-playbook -i ${ip}, install_apache.yml --user=ubuntu --private-key=~/.ssh/id_rsa &&
                                rm -f ~/.ssh/id_rsa
                            '
                            """
                        }
                    }
                }
            }
        }
    }
}
