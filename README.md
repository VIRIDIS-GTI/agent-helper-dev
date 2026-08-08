
## Debian packages / host environment used to derive tool list

The container installs the following key packages:
- curl, wget
- ca-certificates
- git
- build-essential + make
- python3
- ssh
- rsync
- gpg
- sudo
- lsb-release
- docker-ce-cli (Docker CLI)

## Note about Docker socket

The README expects a mounted Docker socket. This agent runtime environment currently does not expose a docker CLI/socket for me to test the image here, but the Dockerfile includes the Docker CLI and the runtime should provide /var/run/docker.sock via volume mount.

