#!/bin/bash

if [ "${BUILD_TYPE}" = "FULL" ]; then

    #install AWS CLI
    apt-get install -y awscli

    #install GCP CLI
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        > /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update
    apt-get install -y google-cloud-cli

    # install Azure CLI (needs above MS package key as well)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ jammy main" \
            > /etc/apt/sources.list.d/azure-cli.list

    apt-get update
    apt-get install -y azure-cli

fi