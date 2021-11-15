pipeline {
    agent any

    stages {
        stage('Prepare environments') {
            steps {
                ansiColor('xterm') {
                  sh "terraform init"
                  sh "terraform apply -auto-approve"
                  sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i \"\$(terraform output -json | jq -r '.instance_ip.value[0]'),\" --extra-vars \"ansible_user=ubuntu\" --extra-vars \"ansible_ssh_private_key_file=~/.ssh/ec2\" playbook.yml"
                }
            }    
        }
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'aws', variable: 'ACCOUNT_ID')]) {
                    sh "aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com"
                    sh "docker build -t ${ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/testpython:${BUILD_NUMBER} ."
                    sh "docker push ${ACCOUNT_ID}.dkr.ecr.eu-north-1.amazonaws.com/testpython:${BUILD_NUMBER}"
                }
            }
        }
        stage('Deploy') {
            steps {
                ansiColor('xterm') {
                  sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i \"\$(terraform output -json | jq -r '.instance_ip.value[0]'),\" --extra-vars \"ansible_user=ubuntu\" --extra-vars \"ansible_ssh_private_key_file=~/.ssh/ec2\" --extra-vars BUILD_NUMBER=${BUILD_NUMBER} deploy.yml"
                }
            }    
        }
    }
}
