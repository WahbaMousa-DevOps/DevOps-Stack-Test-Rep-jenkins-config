# CI Dockerfile for Jenkins CI agent
# Creates a Jenkins build agent by Jenkins master "Full .NET SDK + build tools" for building C# apps during Jenkins CI job.
FROM jenkins/inbound-agent:latest-jdk17

# Install dependencies in a single optimized layer, You must be root to install curl, SDK, and do system-level changes
USER root 

RUN <<EOT
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        gnupg2 \
        apt-transport-https && \
    # Install Microsoft package
    wget -qO /tmp/packages-microsoft-prod.deb \
        https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    # Install .NET SDK
    apt-get update -qq && \
    apt-get install -y --no-install-recommends dotnet-sdk-8.0 && \
    # Cleanup
    apt-get purge -y --auto-remove && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/* \
        /usr/share/doc/*
EOT

# Security hardening
RUN chmod -R g-w,o-rwx /home/jenkins && \
    find / -xdev -type d -perm /022 -exec chmod 0755 {} +

    # Switch back to non-root for Jenkins runtime — this is best practice for CI/CD security
USER jenkins 