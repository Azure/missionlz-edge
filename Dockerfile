# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
FROM ubuntu:20.04

# Instructs apt-get to run without a terminal
ENV DEBIAN_FRONTEND=noninteractive

# Update distro (software-properties-common installs the add-apt-repository command)
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils software-properties-common 2>&1 \
    && apt-get dist-upgrade -y

# Install prerequisites
RUN apt-get install -y \
    apt-transport-https \
    wget \
    unzip \
    git \
    curl 

#Add container requirements
# Download the Microsoft repository GPG keys
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb

# Update the list of products
RUN apt-get update

# Install PowerShell
RUN apt-get install -y powershell

# Start PowerShell
RUN pwsh

#Install Powershell
RUN pwsh -Command "Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force"

#Install Azs.Syndication.Admin
RUN pwsh -Command "Install-Module -Name Azs.Syndication.Admin -RequiredVersion 0.1.140 -Force"

# Add the edge user
ARG USERNAME=edge
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN adduser $USERNAME \
    && usermod -aG sudo $USERNAME 

# Reset to the default value
ENV DEBIAN_FRONTEND=dialog
