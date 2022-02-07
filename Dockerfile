# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

FROM ubuntu:20.04

# Instructs apt-get to run without a terminal
ENV DEBIAN_FRONTEND=noninteractive

# Update distro (software-properties-common installs the add-apt-repository command)
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils software-properties-common 2>&1 \
    && apt-get dist-upgrade -y \
# Install prerequisites
    && apt-get install -y \
    apt-transport-https \
    wget \
    unzip \
    git \
    curl \
    vim

# Download the Microsoft repository GPG keys
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb

# Update the list of products and Install PowerShell and AZ CLI
RUN apt-get update \
    && apt-get install -y powershell \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az bicep install --version v0.4.1008

# Add repo source files
#JJ TO DO NEED to change release code to pull the mlz-edge code base when we have a release
RUN mkdir /workspaces

COPY src /workspaces/src

RUN cd /workspaces \
    && pwsh ./src/scripts/setup.ps1

WORKDIR /workspaces

# Add the edge user
ARG USERNAME=edge
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN adduser $USERNAME \
    && usermod -aG sudo $USERNAME