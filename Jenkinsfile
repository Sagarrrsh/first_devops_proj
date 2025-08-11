pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    bat '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Run Ansible') {
            steps {
                script {
                    def ec2_ip = bat(
                        script: '''
                            for /f "usebackq tokens=*" %%i in (`terraform output -raw public_ip`) do @echo %%i
                        ''',
                        returnStdout: true
                    ).trim()
                    echo "EC2 Public IP: ${ec2_ip}"

                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'SSH_KEY_FILE')]) {
                        sh """
                            wsl -d Ubuntu bash -c '
                                mkdir -p ~/.ssh &&
                                cp /mnt/c/\$(echo ${SSH_KEY_FILE} | sed "s#:#/#g") ~/.ssh/id_rsa &&
                                chmod 600 ~/.ssh/id_rsa &&
                                cd /mnt/c/ProgramData/Jenkins/.jenkins/workspace/${JOB_NAME}/ansible &&
                                ansible-playbook -i ${ec2_ip}, playbook.yml --user=ubuntu --private-key=~/.ssh/id_rsa &&
                                rm -f ~/.ssh/id_rsa
                            '
                        """
                    }
                }
            }
        }
    }
}
