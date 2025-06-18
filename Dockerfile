FROM quay.io/buildah/stable

USER root

# Install system dependencies
RUN dnf -y install \
      java-latest-openjdk \
      curl \
      gcc-c++ \
      make \
      gnupg2 \
      nodejs \
      which \
      git \
      unzip \
      python3 \
      shadow-utils && \
    dnf clean all

# Install kubectl (explicit stable version)
RUN curl -LO https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm -f kubectl

# Setup Jenkins agent
RUN mkdir -p /usr/share/jenkins && \
    curl -sSL -o /usr/share/jenkins/agent.jar \
    https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3208/remoting-3208.jar

# Install SonarQube Scanner CLI
RUN curl -sSLo /tmp/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip && \
    unzip /tmp/sonar-scanner.zip -d /opt/ && \
    ln -s /opt/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner && \
    rm -f /tmp/sonar-scanner.zip

# Create Jenkins user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
    chown -R jenkins:jenkins /home/jenkins /usr/share/jenkins

USER jenkins
WORKDIR /home/jenkins

CMD ["java", "-jar", "/usr/share/jenkins/agent.jar"]

