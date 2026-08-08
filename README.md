# Agent Helper Dev Docker Image

This Docker image provides a development environment with all necessary tools for software development tasks. It's designed to be used by agents (via Paperclip or OpenClaw) to work on projects with minimal setup.

## Tools Included

- Node.js (via nvm)
- pnpm (v8.15.0)
- Git
- Docker CLI
- Make
- Python 3
- SSH
- Rsync
- GPG
- Curl
- wget
- Build essentials

## Usage

To use this container, mount your workspace and the Docker socket:

```bash
docker run -v $(pwd):/workspace -v /var/run/docker.sock:/var/run/docker.sock -e SSH_KEY="your_key" -e GITHUB_TOKEN="your_token" -it agent-helper-dev
```

- **`/workspace`**: Your project directory (mounted as the container's working directory)
- **`/var/run/docker.sock`**: Allows the container to interact with the host's Docker daemon
- **`SSH_KEY`**: Your SSH private key (base64 encoded or as a file)
- **`GITHUB_TOKEN`**: Your GitHub personal access token

The container starts with the `agent` user (no sudo required), so you can run commands directly.

## Development

This image is built from the [agent-helper-dev](https://github.com/VIRIDIS-GTI/agent-helper-dev) repository.