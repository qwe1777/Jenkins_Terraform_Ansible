pipeline {
    agent any
    tools {
       terraform 'Terraform'
    }
    environment {
        Build_IP_Addr = 'build-vm'
        Prod_IP_Addr = 'prod-vm'
        Docker_pass = 'pass_for_Docker'
        Version = '5.0'
    }

    stages {
        stage('Git') {
           steps{
                git branch: 'main', url: 'https://github.com/qwe1777/Jenkins.git'
            }
        }
        stage('Terraform, create Yandex VM') {
            steps{
                sh 'terraform apply --auto-approve'
                script {
                  Build_IP_Addr = sh(returnStdout: true, script: 'terraform output -raw build_ip').trim()
                  Prod_IP_Addr = sh(returnStdout: true, script: 'terraform output -raw prod_ip').trim()
                }
                sh 'echo "[build]\n${Build_IP_Addr} ansible_user=qwe\n[prod]\n${Prod_IP_Addr} ansible_user=qwe\n" > ansible_var'
            }
        }
        
        stage('Sleep') {
        steps {
            script {
                print('Waiting for SSH connection')
                sleep(150)    
            }
        }
        }
        
        stage('Ansible, install packages') {
            steps{
                sh 'ssh-keyscan -H ${Build_IP_Addr} >> ~/.ssh/known_hosts'
                sh 'ansible-playbook -i ansible_var playbook.yml --private-key /var/lib/jenkins/.ssh/id_rsa --ssh-common-args="-o StrictHostKeyChecking=no"'
            }
        }
        stage ('Build packages with Maven') {
            steps {
                sh '''ssh qwe@${Build_IP_Addr} -o StrictHostKeyChecking=no << EOF
                sudo mvn -f /src/build/boxfuse package
                sudo cp /src/build/boxfuse/target/*.war /src/build/
                << EOF'''
            }
        }        
        stage ('Copy Dockerfile and build image on build VM') {
            steps {
                sh 'cat Dockerfile | ssh qwe@${Build_IP_Addr} -o StrictHostKeyChecking=no "sudo tee -a /src/build/Dockerfile"'
                sh '''ssh qwe@${Build_IP_Addr} -o StrictHostKeyChecking=no << EOF
                cd /src/build/
                sudo docker build -t qwe1777/boxfuse:${Version} .
                sudo docker login -u qwe1277777@gmail.com -p ${Docker_pass}
                sudo docker push qwe1777/boxfuse:${Version}
                << EOF'''
            }
        }        
        stage ('Docker run on prod VM') {
            steps {
                sh 'ssh-keyscan -H ${Prod_IP_Addr} >> ~/.ssh/known_hosts'
                sh '''ssh qwe@${Prod_IP_Addr} -o StrictHostKeyChecking=no << EOF
                sudo docker run -p 8080:8080 -d qwe1777/boxfuse:${Version}
                << EOF'''
            }
        }        
    }
}
