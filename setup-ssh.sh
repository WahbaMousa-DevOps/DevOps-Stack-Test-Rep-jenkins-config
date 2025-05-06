#!/bin/bash
set -e

# This script sets up SSH keys for GitHub and EC2 access

# Define colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up SSH keys for Jenkins...${NC}"

# Create SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key for GitHub if it doesn't exist
if [ ! -f ~/.ssh/github_id_ed25519 ]; then
    echo -e "${GREEN}Generating new SSH key for GitHub...${NC}"
    ssh-keygen -t ed25519 -C "jenkins@example.com" -f ~/.ssh/github_id_ed25519 -N ""
    echo -e "${GREEN}SSH key for GitHub generated.${NC}"
else
    echo -e "${GREEN}Using existing GitHub SSH key.${NC}"
fi

# Generate SSH key for EC2 if it doesn't exist
if [ ! -f ~/.ssh/ec2_id_ed25519 ]; then
    echo -e "${GREEN}Generating new SSH key for EC2...${NC}"
    ssh-keygen -t ed25519 -C "jenkins@example.com" -f ~/.ssh/ec2_id_ed25519 -N ""
    echo -e "${GREEN}SSH key for EC2 generated.${NC}"
else
    echo -e "${GREEN}Using existing EC2 SSH key.${NC}"
fi

# Add to SSH config
cat > ~/.ssh/config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_id_ed25519
    IdentitiesOnly yes

Host ec2-instance
    HostName your-ec2-instance-hostname.amazonaws.com
    User ubuntu
    IdentityFile ~/.ssh/ec2_id_ed25519
    IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config

# Print the public keys
echo -e "${YELLOW}GitHub Public Key (add to GitHub):${NC}"
cat ~/.ssh/github_id_ed25519.pub
echo ""

echo -e "${YELLOW}EC2 Public Key (add to EC2 authorized_keys):${NC}"
cat ~/.ssh/ec2_id_ed25519.pub
echo ""

# Update .env file with SSH keys
echo -e "${GREEN}Updating .env file with SSH keys...${NC}"
GITHUB_KEY=$(cat ~/.ssh/github_id_ed25519 | awk '{printf "%s\\n", $0}')
EC2_KEY=$(cat ~/.ssh/ec2_id_ed25519 | awk '{printf "%s\\n", $0}')

if [ -f ".env" ]; then
    # Backup the existing .env file
    #cp .env .env.bak
    
    # Update the SSH keys in the .env file
    sed -i "s|GITHUB_SSH_PRIVATE_KEY=.*|GITHUB_SSH_PRIVATE_KEY=$GITHUB_KEY|g" .env
    sed -i "s|EC2_SSH_PRIVATE_KEY=.*|EC2_SSH_PRIVATE_KEY=$EC2_KEY|g" .env
    
    echo -e "${GREEN}.env file updated with SSH keys.${NC}"
else
    # Create a new .env file based on .env.example
    if [ -f ".env.example" ]; then
        cp .env.example .env
        sed -i "s|GITHUB_SSH_PRIVATE_KEY=.*|GITHUB_SSH_PRIVATE_KEY=$GITHUB_KEY|g" .env
        sed -i "s|EC2_SSH_PRIVATE_KEY=.*|EC2_SSH_PRIVATE_KEY=$EC2_KEY|g" .env
        echo -e "${GREEN}Created .env file with SSH keys.${NC}"
    else
        echo -e "${RED}Error: .env.example not found. Please create it first.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}SSH setup completed successfully.${NC}"
echo -e "${YELLOW}IMPORTANT: Add the public keys to GitHub and EC2 before starting Jenkins.${NC}"
echo -e "${YELLOW}Instructions:${NC}"
echo -e "1. Add the GitHub public key to your GitHub account at https://github.com/settings/keys"
echo -e "2. Add the EC2 public key to your EC2 instance's ~/.ssh/authorized_keys file"

#Generate SSH keys:
  # chmod +x setup-ssh.sh
  # ./setup-ssh.sh
  # docker compose -d up