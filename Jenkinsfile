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
            
            // Option 1: Use specific WSL distribution with full path
            sh "wsl -d Ubuntu /usr/bin/ansible-playbook -i ${ip}, install_apache.yml --user=ubuntu --private-key=~/.ssh/id_rsa"
            
            // Option 2: Alternative using Jenkins SSH credentials (uncomment if Option 1 fails)
            // withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh_key', keyFileVariable: 'SSH_KEY_FILE')]) {
            //   sh "wsl -d Ubuntu /usr/bin/ansible-playbook -i ${ip}, install_apache.yml --user=ubuntu --private-key=\${SSH_KEY_FILE}"
            // }
          }
        }
      }
    }
  }
}