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
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Run Ansible') {
      steps {
        dir('ansible') {
          script {
            def ip = sh(script: "terraform -chdir=../terraform output -raw public_ip", returnStdout: true).trim()
            echo "Ubuntu EC2 IP: ${ip}"

            withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER')]) {
              sh "wsl ansible-playbook -i ${ip}, install_apache.yml --user=${SSH_USER} --private-key=${SSH_KEY_FILE}"
            }
          }
        }
      }
    }
  }
}
