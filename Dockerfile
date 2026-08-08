FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends curl git wget build-essential ca-certificates lsb-release sudo && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && apt-get install -y docker-ce-cli && rm -rf /var/lib/apt/lists/*
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install --lts && nvm alias default lts/* && nvm use default
RUN curl -L https://pnpm.io/install.sh | sh -s -- --version 8.15.0
ENV PATH="$HOME/.nvm/versions/node/v$(nvm version default)/bin:$PATH"
ENV PATH="$HOME/.local/bin:$PATH"
RUN apt-get update && apt-get install -y --no-install-recommends make python3 ssh rsync gpg && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash agent && echo "agent ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agent && chown -R agent:agent /home/agent
USER agent
WORKDIR /workspace
CMD ["bash"]