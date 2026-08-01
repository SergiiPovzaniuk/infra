ARG JENKINS_IMAGE=jenkins/jenkins:2.568.1-jdk21
FROM ${JENKINS_IMAGE}
USER root
ARG TERRAFORM_VERSION=1.11.4
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       docker.io curl gettext-base git ca-certificates unzip openssh-client \
       python3 python3-pip ansible \
  && curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
  && unzip -o /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && rm -rf /var/lib/apt/lists/*
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
USER root
