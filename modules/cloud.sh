#!/usr/bin/env bash
set -e

if ! command -v aws >/dev/null 2>&1; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip
    echo "AWS CLI installed"
fi

if ! command -v gcloud >/dev/null 2>&1; then
    DEST="$HOME/.local/bin"
    mkdir -p "$DEST"
    echo "Installing Google Cloud CLI..."
    curl -fsSL -o /tmp/google-cloud-cli.tar.gz \
        https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf /tmp/google-cloud-cli.tar.gz --directory "$DEST"
    # Install quietly
    "$DEST/google-cloud-sdk/install.sh" --quiet --usage-reporting=false
    # Cleanup
    rm -f /tmp/google-cloud-cli.tar.gz
    echo "Google Cloud CLI installed"
    # Add to PATH to avoid double installs
    export PATH="$DEST/google-cloud-sdk/bin:$PATH"
fi

# Ensure pipx exists
if ! command -v pipx >/dev/null 2>&1; then
    sudo apt install -y pipx
    pipx ensurepath
fi

# LocalStack
if ! command -v localstack >/dev/null 2>&1; then
    echo "Installing LocalStack..."
    pipx install localstack --include-deps
    echo "LocalStack installed"
fi

echo "Installing IaC tools"

# Use Pulumilocal wrapper (includes Pulumi)
if ! command -v pulumilocal >/dev/null 2>&1; then
    echo "Installing Pulumi..."
    curl -fsSL https://get.pulumi.com | sh
    pipx install pulumi-local
    echo "Pulumi installed"
fi

# Ensure PATH is correct
export PATH="$HOME/.local/bin:$PATH":w

# Terraform
if ! command -v terraform >/dev/null 2>&1; then
    echo "Installing terraform"
    sudo apt install -y gnupg software-properties-common curl
    # Terraform doesn't supply "latest"
    TERRAFORM_VERSION="1.14.4"
    DEST="$HOME/.local/bin"
    mkdir -p "$DEST"
    
    curl -fsSL -o /tmp/terraform.zip \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    
    unzip -o /tmp/terraform.zip -d "$DEST"
    rm -f /tmp/terraform.zip

    echo "Terraform installed"
    # Add to PATH to avoid double installs
    export PATH="$DEST:$PATH"
fi
