pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        SSH_KEY               = credentials('ec2_ssh_key')
        SSH_USER              = 'ubuntu'
    }
    stages {
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Run Ansible from WSL') {
            steps {
                dir('ansible') {
                    script {
                        def ip = sh(script: "terraform -chdir=../terraform output -raw public_ip", returnStdout: true).trim()
                        echo "Ubuntu EC2 IP: ${ip}"
                        writeFile file: 'id_rsa', text: SSH_KEY
                        sh 'chmod 600 id_rsa'

                        // Run inside WSL with login shell so PATH is loaded
                        sh """
                        wsl bash -lc '
                            ansible-playbook -i "${ip}," install_apache.yml \
                            --user=${SSH_USER} \
                            --private-key=\$(wslpath "$(pwd)/id_rsa")
                        '
                        """
                    }
                }
            }
        }
    }
}
