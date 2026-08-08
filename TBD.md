# TBD.md - Agent Helper Dev Docker Image

## Open Questions & Improvements

1. **Base Image Version**: Should we use a more recent Ubuntu LTS (24.04) instead of 22.04? 22.04 is still supported until April 2027.

2. **NVM Installation**: The Dockerfile installs nvm via bash, but the container starts as `agent` user. Should we add `source ~/.nvm/nvm.sh` to `/home/agent/.bashrc` for persistent shell access?

3. **SSH Key Handling**: The README mentions `SSH_KEY` as an environment variable. Should we accept it as a file mount (e.g., `-v ~/.ssh/id_rsa:/home/agent/.ssh/id_rsa`) instead of environment variable?

4. **Docker Socket Permissions**: The current setup mounts `/var/run/docker.sock`, but the `agent` user may need `docker` group membership for permission. Should we add `usermod -aG docker agent`?

5. **Image Size Optimization**: The current Dockerfile installs many packages. Could we reduce size by using multi-stage builds or removing temporary dependencies after installation?

6. **Default Shell**: The `CMD ["bash"]` assumes bash. Should we support `sh` as default for minimalism?

## Action Items

- [ ] Verify Docker socket permissions with `docker run` test
- [ ] Test image build locally with `docker build -t agent-helper-dev .`
- [ ] Confirm `lsb_release` is available in the base image (now included via `lsb-release` package)