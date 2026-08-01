ARG JENKINS_IMAGE=jenkins/jenkins:2.568.1-jdk21
FROM ${JENKINS_IMAGE}
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends docker.io curl gettext-base git \
  && rm -rf /var/lib/apt/lists/*
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
USER root
