# Base: Jenkins Agent with Node.js
FROM jenkins/inbound-agent:alpine-jdk-17

USER root

# Install Node.js + npm
RUN apk add --no-cache nodejs npm

# Optional: install yarn or other global tools if needed
# RUN npm install -g yarn

# Switch back to Jenkins user
USER jenkins

# Directory where Jenkins jobs will run
WORKDIR /home/jenkins/agent

# Default entrypoint is inherited from jenkins/inbound-agent
