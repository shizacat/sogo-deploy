# Description

Image and Helm for SoGo.

Repository: https://github.com/shizacat/sogo

# Docker

## Steps

Repository sogo project: https://github.com/inverse-inc/sogo

- Instruction for build (don't work): https://sogo.nu/support/faq/how-do-i-compile-sogo.html
- Example (works): https://github.com/cschweingruber/sogo-build
- http://wiki.sogo.nu/nginxSettings
- https://github.com/our-source/sogo


## Usage

Get image:

```bash
docker pull shizacat/sogo
```

## Build

```bash
docker build -t sogo -f docker/Dockerfile docker

## Configuration

The file '/etc/sogo/sogo.conf' is stored main configuration.

# Helm
```