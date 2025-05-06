### Note: 
   The dev docker-compose.yml is kept in the app repo
   The prod docker-compose.prod.yml is kept in the infra or Jenkins repo for centralized control
So,
   Dockerfile → builds minimal runtime image
   docker-compose.prod.yml → deploys the image with prod config
   Jenkins agent → handles building and testing with full SDK (Java + .NET)

# So in your case:

- Dockerfile → builds the Jenkins agent (e.g., dotnet-sdk, java)
- Jenkinsfile → defines the pipeline logic that:
      - Clones repo
      - Builds image (from Dockerfile inside csharp-app/ or java-app/)
      - Runs tests
      - Pushes image
      - Triggers deployment (via docker-compose.prod.yml)

# This is just one of two valid options.

Structure Type	                           Explanation
🅰️ Single "infra" repo (all apps + CI)	 ✅ Used for centralized deployment control — your current structure
🅱️ Each app has its own repo	             ✅ Also valid — when teams own their full CI/CD stack

# | Section                       | Reason for Deletion in `prod`                                    |
| ----------------------------- | ---------------------------------------------------------------- |
| `jenkins:` service            | Jenkins is a CI tool, not needed in production runtime           |
| `java-agent` / `dotnet-agent` | Agents are used only for builds, not for app hosting             |
| Volumes for agents            | Only needed for CI workspace persistence                         |
| Jenkins network settings      | You’ll use a clean app-facing network in prod (e.g., `prod-net`) |


# Production-Grade Jenkins CI/CD Setup

A professional-grade DevOps showcase featuring Jenkins with multiple agents for Java and C# applications, with plans for integration with Vault, Terraform, Ansible, Azure Test Plans, Prometheus, Grafana, ArgoCD, and Kubernetes.

## Overview

This project provides a production-ready Jenkins setup designed for enterprise CI/CD pipelines. It includes:

- Jenkins master configured with JCasC (Jenkins Configuration as Code)
- Dedicated build agents for Java and .NET applications
- Secure SSH-based GitHub integration
- Docker support for containerized builds and deployments
- Seed jobs for automated pipeline creation
- Comprehensive security implementation

## Architecture

The setup consists of:

- **Jenkins Master**: Orchestrates the CI/CD pipelines
- **Java Agent**: Dedicated to building and testing Java applications
- **C# (.NET) Agent**: Dedicated to building and testing C# applications
- **Docker**: Used for containerizing applications and running the Jenkins infrastructure
- **SSH Keys**: For secure communication with GitHub and deployment targets

## Prerequisites

- Docker and Docker Compose
- Git
- SSH key pair for GitHub
- SSH key pair for EC2 instances
- Docker Hub account (for pushing built images)
- Ubuntu system (either local VM or EC2)

## Directory Structure

```
.
├── agents/
│   └── dotnet/                     # Custom Dockerfile for .NET agent
│       └── Dockerfile
├── init-scripts/                   # Jenkins initialization scripts
│   └── init-jenkins.groovy
├── jcasc/                          # Jenkins Configuration as Code files
│   └── jenkins.yaml
├── jobs/                           # Seed job definitions
│   └── seed.groovy
├── .env                            # Environment variables (credentials, secrets)
├── .env.example                    # Example environment file template
├── docker-compose.yml              # Docker Compose definition
├── setup-ssh.sh                    # Script to set up SSH keys
└── README.md                       # This file
```

## Getting Started

### Step 1: Clone this repository

```bash
git clone https://github.com/yourusername/jenkins-devops-showcase.git
cd jenkins-devops-showcase
```

### Step 2: Set up SSH keys

Run the setup script to generate SSH keys:

```bash
chmod +x setup-ssh.sh
./setup-ssh.sh
```

This will generate SSH keys for GitHub and EC2 access and update the `.env` file.

### Step 3: Add SSH public keys to GitHub and EC2

1. Add the GitHub public key to your GitHub account at https://github.com/settings/keys
2. Add the EC2 public key to your EC2 instance's `~/.ssh/authorized_keys` file

### Step 4: Configure environment variables

Create a `.env` file from the example:

```bash
cp .env.example .env
```

Edit the `.env` file and set the following variables:

- `JENKINS_ADMIN_PASSWORD`: A secure password for the Jenkins admin user
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_PASSWORD`: Your Docker Hub password

### Step 5: Create required directories

```bash
mkdir -p jcasc init-scripts agents/dotnet
```

### Step 6: Start Jenkins using Docker Compose

```bash
docker-compose up -d
```

### Step 7: Access Jenkins UI

Open a browser and navigate to `http://localhost:8080/jenkins`

Login with the admin credentials you set in the `.env` file.

## Jenkins Agent Setup

The Jenkins agents are automatically configured via Docker Compose, but if you need to add more agents or customize them, follow these steps:

### Adding a New Agent

1. Add the agent definition to `docker-compose.yml`
2. Create a custom Dockerfile if needed
3. Add the agent configuration to `jcasc/jenkins.yaml`
4. Update the seed job to include the new agent label

## Creating Projects

This setup includes a seed job that automatically creates pipelines for Java and C# projects. To add a new project:

1. Create a repository on GitHub with a Jenkinsfile
2. Run the seed job in Jenkins, providing the repository URL

## Security Considerations

This setup includes several security enhancements:

- SSH keys for secure GitHub access (no password authentication)
- Container isolation for build environments
- Non-root user execution where possible
- CSRF protection enabled
- Jenkins master lockdown (no builds on master)

## Monitoring and Maintenance

Jenkins logs can be accessed using:

```bash
docker-compose logs -f jenkins
```

To perform maintenance:

```bash
# Stop Jenkins
docker-compose down

# Start Jenkins
docker-compose up -d

# Restart Jenkins
docker-compose restart jenkins
```

# Roadmap

## Key Professional Features
### This implementation includes several professional-grade features:

   - Modularity: Clear separation between Jenkins master and agents
   -  Security: SSH key authentication, CSRF protection, proper permissions
   -  Automation: JCasC for reproducible setup, seed jobs for pipeline automation
   -  Scalability: Easy to add more agents or project types
   -  CI/CD Best Practices: Proper pipeline stages with quality gates
   -  Container Security: Non-root users for containers, isolation
   -  Robust Dockerfiles: Multi-stage builds, security scans, proper tagging
   -  Infrastructure as Code: Everything defined in code for reproducibility

## A few suggestions that might further improve it:

 -  Backup strategy: Consider adding configuration for automated Jenkins backup
 -  API token management: Consider explicit configuration for API token usage and rotation
 -  Artifact repository: Add integration with an artifact repository (Nexus, Artifactory)
 -  Monitoring integration: Add integration with monitoring tools

## Future enhancements planned for this project:

1. **Vault Integration**: For secure credential management
2. **Terraform Integration**: For infrastructure as code
3. **Ansible Integration**: For configuration management
4. **Azure Test Plans Integration**: For test management
5. **Prometheus & Grafana**: For comprehensive monitoring
6. **ArgoCD**: For GitOps-based continuous delivery
7. **Kubernetes Deployment**: For container orchestration
8. **Update RAS to ed25519**: For SSH Security Alogorthim

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Final Assessment
## Is it ready? 
   The configuration is now about 85-90% production-ready and follows good DevOps practices. It would pass initial scrutiny and is significantly better than the original.
## Will your manager ask for edits? 
   Possibly, but these would likely be company-specific requirements rather than fundamental flaws. The remaining 10-15% of improvements would typically involve:

- Company-specific security policies
- Integration with existing monitoring systems
- Customization for your specific application needs
- Alignment with existing infrastructure patterns

**For most companies, this revised setup provides a solid foundation that demonstrates DevOps maturity and security consciousness. It's suitable for both test/dev and production environments with minor environment-specific adjustments.**

