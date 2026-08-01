pipeline {
  agent any
  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 90, unit: 'MINUTES')
  }
  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Provision or tear down AWS/k3s')
    booleanParam(name: 'DEPLOY_APP', defaultValue: true, description: 'After apply, trigger app-forked/main')
  }
  environment {
    AWS = credentials('aws')
    MINIO = credentials('minio-tfstate')
    DOCKER = '/usr/bin/docker'
    PATH = "/usr/bin:/usr/local/bin:${env.PATH}"
    TF_DIR = 'terraform/envs/prod'
    CLUSTER_DIR = '/opt/jenkins'
    EC2_KEY = '/opt/jenkins/ssh/exam-devops.pem'
    AWS_EC2_METADATA_DISABLED = 'true'
    ANSIBLE_HOST_KEY_CHECKING = 'False'
    JENKINS_PIPELINE = '1'
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Prepare') {
      steps {
        sh '''
          set -e
          mkdir -p "$CLUSTER_DIR/ssh" "$TF_DIR"
          test -f "$EC2_KEY" || { echo "missing $EC2_KEY — place EC2 key on Jenkins host"; exit 1; }
          chmod 600 "$EC2_KEY"

          OPERATOR_CIDR=$(curl -fsS --max-time 10 https://api.ipify.org)/32
          cat > "$TF_DIR/terraform.tfvars" <<EOF
aws_region     = "eu-central-1"
aws_profile    = ""
project        = "exam-devops"
key_name       = "exam-devops"
instance_type  = "t3.small"
operator_cidrs = ["${OPERATOR_CIDR}"]
jenkins_cidrs  = ["${OPERATOR_CIDR}"]
EOF

          cat > "$TF_DIR/backend.hcl" <<EOF
bucket                      = "tfstate"
key                         = "exam-devops/prod.tfstate"
region                      = "us-east-1"
endpoints                   = { s3 = "http://host.docker.internal:9000" }
access_key                  = "${MINIO_USR}"
secret_key                  = "${MINIO_PSW}"
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_requesting_account_id  = true
skip_region_validation      = true
use_path_style              = true
use_lockfile                = true
EOF
        '''
      }
    }

    stage('Terraform') {
      steps {
        dir(env.TF_DIR) {
          withEnv([
            "AWS_ACCESS_KEY_ID=${env.AWS_USR}",
            "AWS_SECRET_ACCESS_KEY=${env.AWS_PSW}"
          ]) {
            sh '''
              set -e
              terraform init -input=false -reconfigure -backend-config=backend.hcl
              if [ "$ACTION" = "destroy" ]; then
                terraform destroy -input=false -auto-approve -var-file=terraform.tfvars
              else
                terraform apply -input=false -auto-approve -var-file=terraform.tfvars
              fi
            '''
          }
        }
      }
    }

    stage('Inventory') {
      when { expression { return params.ACTION == 'apply' } }
      steps {
        sh '''
          set -e
          APP1=$(terraform -chdir="$TF_DIR" output -raw app1_public_ip)
          APP2=$(terraform -chdir="$TF_DIR" output -raw app2_public_ip)
          APP3=$(terraform -chdir="$TF_DIR" output -raw app3_public_ip)
          LB=$(terraform -chdir="$TF_DIR" output -raw lb_public_ip)
          cat > ansible/inventory/hosts.ini <<EOF
[jenkins_local]
jenkins ansible_host=host.docker.internal ansible_user=root ansible_connection=local

[minio]
jenkins

[monitoring]

[jenkins_agents]

[k3s_server]
app1 ansible_host=${APP1} ansible_user=ubuntu

[k3s_agents]
app2 ansible_host=${APP2} ansible_user=ubuntu
app3 ansible_host=${APP3} ansible_user=ubuntu

[k3s:children]
k3s_server
k3s_agents

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args=-o StrictHostKeyChecking=accept-new
ansible_ssh_private_key_file=${EC2_KEY}
app_domain=${LB}
EOF
          printf '%s' "$LB" > "$CLUSTER_DIR/ingress_ip"
          chmod 644 "$CLUSTER_DIR/ingress_ip"
          echo "lb_public_ip=$LB"
        '''
      }
    }

    stage('Configure k3s') {
      when { expression { return params.ACTION == 'apply' } }
      steps {
        sh '''
          set -e
          chmod -R go-w ansible || true
          cd ansible
          ansible-galaxy collection install -r requirements.yml
          ansible-playbook -i inventory/hosts.ini k3s.yml
        '''
      }
    }

    stage('Publish kubeconfig') {
      when { expression { return params.ACTION == 'apply' } }
      steps {
        sh '''
          set -e
          APP1=$(terraform -chdir="$TF_DIR" output -raw app1_public_ip)
          ssh -i "$EC2_KEY" -o StrictHostKeyChecking=accept-new ubuntu@"$APP1" \
            'sudo cat /etc/rancher/k3s/k3s.yaml' \
            | sed "s/127.0.0.1/${APP1}/g; s/localhost/${APP1}/g" \
            > "$CLUSTER_DIR/kubeconfig"
          chmod 644 "$CLUSTER_DIR/kubeconfig"
          export KUBECONFIG="$CLUSTER_DIR/kubeconfig"
          kubectl get nodes -o wide
        '''
      }
    }

    stage('Cleanup cluster files') {
      when { expression { return params.ACTION == 'destroy' } }
      steps {
        sh '''
          : > "$CLUSTER_DIR/ingress_ip" || true
          : > "$CLUSTER_DIR/kubeconfig" || true
        '''
      }
    }

    stage('Deploy app') {
      when {
        allOf {
          expression { return params.ACTION == 'apply' }
          expression { return params.DEPLOY_APP }
          branch 'main'
        }
      }
      steps {
        build job: 'app-forked/main', wait: true, propagate: true
      }
    }
  }
  post {
    always {
      script {
        def ingress = 'n/a'
        try {
          def ip = readFile('/opt/jenkins/ingress_ip').trim()
          if (ip) { ingress = "http://${ip}/" }
        } catch (ignored) {}
        try {
          emailext(
            subject: "infra [${env.BRANCH_NAME}] #${env.BUILD_NUMBER} ${params.ACTION} - ${currentBuild.currentResult}",
            body: "Action: ${params.ACTION}\nBuild: ${env.BUILD_URL}\nIngress: ${ingress}",
            to: '${DEFAULT_RECIPIENTS}'
          )
        } catch (err) {
          echo "email skipped: ${err}"
        }
      }
    }
  }
}
