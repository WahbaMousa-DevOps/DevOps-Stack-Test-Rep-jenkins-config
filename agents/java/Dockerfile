# CI Dockerfile not for Jenkins CI agent
# Create a Jenkins agent by Jenkins master to build Java applications during Jenkins CI builds (compiling .java, running Gradle builds, etc.).
FROM jenkins/inbound-agent:latest-jdk17

USER root

# Install all dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        git \
        curl \
        gnupg \
        lsb-release \
        ca-certificates && \
    # Install Gradle
    wget -q https://services.gradle.org/distributions/gradle-8.6-bin.zip && \
    unzip -q gradle-8.6-bin.zip -d /opt && \
    ln -s /opt/gradle-8.6/bin/gradle /usr/bin/gradle && \
    # Install Docker CLI (official Docker repo)
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    # Cleanup
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        gradle-8.6-bin.zip

USER jenkins