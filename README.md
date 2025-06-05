# Docker-Wipter

## Overview
This repository provides a Dockerized solution for running Wipter, allowing users to share bandwidth and earn passive income securely and efficiently. The setup uses `ghcr.io/techroy23/docker-slimvnc:latest` as base image to ensure minimal system overhead and integrates all necessary dependencies for seamless operation.

## Features
- Lightweight Debian-based image (`ghcr.io/techroy23/docker-slimvnc:latest`).
- Automated installation of required dependencies.
- Optimized with essential tools and libraries for robustness.
- Automated Wipter login via  `WIPTER_EMAIL` `WIPTER_PASSWORD`.
- VNC password can be set via `VNC_PASS`.

## Run
```

docker run -d --name docker-wipter \
  -e VNC_PASS="your_secure_password" \
  -e WIPTER_EMAIL="YourEmail@here.com" \
  -e WIPTER_EMAIL="your_secure_password" \
  -p 5901:5901 -p 6080:6080 \
  --shm-size=2gb \
  ghcr.io/techroy23/docker-wipter:latest

```

## Access
- VNC Client: localhost:5901
- Web Interface (noVNC): http://localhost:6080
