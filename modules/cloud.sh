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
    DEST="$HOME"
    echo "Installing Google Cloud CLI..."
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz --directory "$HOME"
    # Install quietly
    "$DEST/google-cloud-sdk/install.sh" --quiet --usage-reporting=false
    # Cleanup
    rm $DEST/*.tar.gz
    echo "Google Cloud CLI installed"
fi

# Ensure pip exists
if ! command -v pip3 >/dev/null 2>&1; then
    sudo apt install -y python3-pip
fi

# LocalStack
if ! command -v localstack >/dev/null 2>&1; then
    echo "Installing LocalStack..."
    pip3 install --user localstack
    echo "LocalStack installed"
fi

echo "Installing IaC tools"

# Use Pulumilocal wrapper (includes Pulumi)
if ! command -v pulumi >/dev/null 2>&1; then
    echo "Installing Pulumi..."
    pip3 install --user pulumilocal
    echo "Pulumi installed"
fi

# Terraform
if ! command -v terraform >/dev/null 2>&1; then
    sudo apt install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y terraform
    echo "Terraform installed"
fi
