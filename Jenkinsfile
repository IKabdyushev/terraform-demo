pipeline {
    agent any

    stages {
        stage('Prepare environments') {
            steps {
                  sh "terraform apply -auto-approve"
                  sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i \"\$(terraform output -json | jq -r '.instance_ip.value[0]'),\" --extra-vars \"ansible_user=ubuntu\" --extra-vars \"ansible_ssh_private_key_file=~/.ssh/ec2\" playbook.yml"
            }
        }
    }
}
