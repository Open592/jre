# jre

## About this repository
This repository contains a distribution of JREs which will serve to support
the Launcher when initializing the jvm and running the following applications:

- AppletViewer
- Loader
- Client

The JREs themselves have been built with only the nessasary components to
support running the above applications, and will be bundled with the Launcher
in order to allow users who don't have Java installed on their system (or have
an unsupported version) to run the client without hassle.

## Generation
This repository is the result of the following operation which can be found
within the [scripts/initialize.sh](scripts/initialize.sh) script.

- Download the OpenJDK distribution for each platform from [https://jdk.java.net/](https://jdk.java.net/)
- Extract the files
- Utilize the Linux build to run `jlink` in order to generate a compressed runtime image for each platform
- Save the generated images to the repo

This repo will be updated for each major version update, and may (if needed)
be modified to support the Open592 project.

## Usage
Please do not point directly to `master` but instead point to a tagged release
which will correspond to the Java major version used to generate the images.

## Issues
Please open an issue if you are seeing issues.
