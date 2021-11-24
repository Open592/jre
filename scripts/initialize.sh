#!/bin/bash

set -euo pipefail

# The purpose of this script is to initialize the repository with the
# minimal JRE environment which can run the following applications:
#
# - Appletviewer
# - Loader
# - Client
#
# The launcher will be responsible for loading this before starting the
# applet viewer
#
# TODO:
#
# - Support dynamically generating list of required components for the above
#   applications.

log() {
    echo "[${0##*/}]: $1" >&2
}

fatal() {
    log "<FATAL> $1"

    exit 1
}

verify_command() {
    if [ $? != 0 ]; then
        fatal $1
    fi
}

download_jdk() {
    log "Downloading JDK: $1"

    if [ -d $2 ]; then
        log "Removing existing download directory: $2"

        rm -rf $2
    fi

    wget -P $2 $1

    verify_command "Failed to download JDK files: $2"
}

create_jre() {
    # We are intending this script to be run on Linux
    JLINK_SCRIPT="$LINUX_DOWNLOAD_DIRECTORY/out/$JDK_NAME/bin/jlink"

    sh $JLINK_SCRIPT --compress=2 --module-path $1 --add-modules $2 --output $3    
}

# We require wget to download jdk files
if ! [ -x "$(command -v wget)" ]; then
    fatal "This script requires 'wget' to be installed"
fi

# We require tar to extract jdk files for OSX and Linux
if ! [ -x "$(command -v tar)" ]; then
    fatal "This script requires 'tar' to be installed"
fi

# We require unzip to extract jdk files for Windows
if ! [ -x "$(command -v unzip)" ]; then
    fatal "This script requires 'unzip' to be installed"
fi

log "Downloading JDKs..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$SCRIPT_DIR/.."

JDK_NAME="jdk-17.0.1"

ROOT_DOWNLOAD_DIRECTORY="$REPO_ROOT/downloads"
LINUX_DOWNLOAD_DIRECTORY="$ROOT_DOWNLOAD_DIRECTORY/linux"
OSX_DOWNLOAD_DIRECTORY="$ROOT_DOWNLOAD_DIRECTORY/osx"
WINDOWS_DOWNLOAD_DIRECTORY="$ROOT_DOWNLOAD_DIRECTORY/windows"

# Links to JRE for each platform
LINUX_JDK_LINK="https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz"
OSX_JDK_LINK="https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_macos-x64_bin.tar.gz"
WINDOWS_JDK_LINK="https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_windows-x64_bin.zip"

log "Downloading Linux JDK files..."
download_jdk $LINUX_JDK_LINK $LINUX_DOWNLOAD_DIRECTORY
log "Extracting Linux JDK files..."
mkdir -p "$LINUX_DOWNLOAD_DIRECTORY/out"
tar -xf "$LINUX_DOWNLOAD_DIRECTORY"/*.tar.gz -C "$LINUX_DOWNLOAD_DIRECTORY/out"
verify_command "Failed to extract Linux JDK files"

log "Downloading OSX JDK files..."
download_jdk $OSX_JDK_LINK $OSX_DOWNLOAD_DIRECTORY
log "Extracting OSX JDK files..."
mkdir -p "$OSX_DOWNLOAD_DIRECTORY/out"
tar -xf "$OSX_DOWNLOAD_DIRECTORY"/*.tar.gz -C "$OSX_DOWNLOAD_DIRECTORY/out"
verify_command "Failed to extract OSX JDK files"

log "Downloading Windows JDK files..."
download_jdk $WINDOWS_JDK_LINK $WINDOWS_DOWNLOAD_DIRECTORY
log "Extracting Windows JDK files..."
mkdir -p "$WINDOWS_DOWNLOAD_DIRECTORY/out"
unzip -q "$WINDOWS_DOWNLOAD_DIRECTORY"/*.zip -d "$WINDOWS_DOWNLOAD_DIRECTORY/out"
verify_command "Failed to extract Windows JDK files"

# Create JREs for each platform
MODULE_LIST=""
LINUX_MODULE_PATH="$LINUX_DOWNLOAD_DIRECTORY/out/$JDK_NAME/jmods"
LINUX_OUTPUT_PATH="$REPO_ROOT/linux"
OSX_MODULE_PATH="$OSX_DOWNLOAD_DIRECTORY/out/$JDK_NAME.jdk/Contents/Home/jmods"
OSX_OUTPUT_PATH="$REPO_ROOT/osx"
WINDOWS_MODULE_PATH="$WINDOWS_DOWNLOAD_DIRECTORY/out/$JDK_NAME/jmods"
WINDOWS_OUTPUT_PATH="$REPO_ROOT/windows"