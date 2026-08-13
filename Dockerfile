# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG NODE_MAJOR=22
ARG TERRAFORM_VERSION=1.12.2
ARG HELM_VERSION=3.18.4
ARG YQ_VERSION=v4.47.2
ARG KUBECTL_VERSION=v1.34.0

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/workspace \
    PATH=/home/agent/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Packages derived from the Dev Bot host inventory. See TOOLING.md for the
# complete, intentionally curated package and command matrix.
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash-completion \
      build-essential \
      ca-certificates \
      curl \
      ffmpeg \
      git \
      gnupg \
      iputils-ping \
      jq \
      less \
      make \
      openssh-client \
      openssl \
      python3 \
      python3-pip \
      python3-venv \
      rsync \
      shellcheck \
      sudo \
      unzip \
      wget \
      xz-utils \
      zip \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
       | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" \
       > /etc/apt/sources.list.d/docker.list \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli nodejs \
    && corepack enable \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod 0755 /usr/local/bin/kubectl \
    && curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
       | tar -xz --strip-components=1 -C /usr/local/bin linux-amd64/helm \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/local/bin/yq \
    && chmod 0755 /usr/local/bin/yq \
    && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip -q /tmp/terraform.zip -d /usr/local/bin \
    && rm -f /tmp/terraform.zip \
    && userdel -r ubuntu 2>/dev/null || true \
    && useradd --create-home --shell /bin/bash --uid 1000 agent \
    && install -d -o agent -g agent -m 0755 /workspace \
    && echo 'agent ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/agent \
    && chmod 0440 /etc/sudoers.d/agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Betriebsanweisung fuer den AUFRUFENDEN Agenten (nicht fuer diesen Container
# selbst) - liegt im Image, damit sie mit jedem Build/Update automatisch
# aktuell bleibt, statt als Kopie an anderer Stelle zu veralten.
COPY --chown=agent:agent AGENT_PROMPT.md /home/agent/AGENT_PROMPT.md

# Install nvm and tenv for Node/tool version management.
RUN su - agent -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash' \
    && su - agent -c 'bash -lc ". \"$HOME/.nvm/nvm.sh\" && nvm install --lts && nvm alias default node && corepack enable"' \
    && curl -fsSL https://github.com/tofuutils/tenv/releases/latest/download/tenv_linux_amd64.tar.gz | tar -xz -C /usr/local/bin tenv || true

USER agent
WORKDIR /workspace
CMD ["bash"]