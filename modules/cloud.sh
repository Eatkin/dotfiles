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
    echo "Installing Google Cloud CLI..."
    # Add Google Cloud package repo
    if ! grep -q "packages.cloud.google.com" /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null; then
        echo "Adding Google Cloud SDK repo..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
    fi
    sudo apt update
    sudo apt install -y google-cloud-cli
    echo "Google Cloud CLI installed"
fi

if ! command -v localstack >/dev/null 2>&1; then
    echo "Installing LocalStack..."
    # Install via pip (ensure pip exists)
    if ! command -v pip3 >/dev/null 2>&1; then
        sudo apt install -y python3-pip
    fi
    pip3 install --user localstack
    echo "LocalStack installed"
fi

