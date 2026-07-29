FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    CODE_SERVER_VERSION=4.96.2 \
    GO_VERSION=1.23.2 \
    NODE_VERSION=20.x \
    PYTHON_VERSION=3.12 \
    UV_VERSION=0.4.18 \
    STARSHIP_VERSION=1.20.1 \
    HOME=/root

# Install base tools and dependencies (removed build-essential to save ~1GB)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Base essentials
    curl wget git ca-certificates gnupg lsb-release \
    software-properties-common apt-transport-https \
    # ZSH and terminal tools
    zsh tmux nano vim \
    # Python (minimal - no python3-dev to save space)
    python3 python3-pip python3-venv \
    # Database tools
    sqlite3 libsqlite3-dev \
    # Networking and utilities
    net-tools iputils-ping netcat-openbsd \
    jq unzip zip tar gzip bzip2 xz-utils \
    # Essential libraries only
    pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Note: Rust compiler REMOVED to save ~2-3GB
# Using pre-built binaries for Rust-based tools instead

# Install Go
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz && \
    rm go${GO_VERSION}.linux-arm64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js LTS (20.x)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest && \
    npm cache clean --force

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION} && \
    rm -rf /tmp/*

# Install FZF
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/fzf && \
    /usr/local/fzf/install --all --no-update-rc && \
    rm -rf /usr/local/fzf/.git
ENV PATH="/usr/local/fzf/bin:${PATH}"

# Install Ripgrep (from Ubuntu repos - saves compilation time)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ripgrep && \
    rm -rf /var/lib/apt/lists/*

# Install UV (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    rm -rf /tmp/*
ENV PATH="/root/.local/bin:${PATH}"

# Note: xsv pre-built binary not available for ARM64
# Skipping xsv to avoid needing Rust compiler (~2-3GB)
# Alternative CSV tools: csvkit (Python), Miller (pre-built), or DuckDB CLI

# Install VisiData, Harlequin, and Markitdown using uv
RUN uv tool install visidata && \
    uv tool install harlequin && \
    uv tool install markitdown && \
    rm -rf /root/.cache/*

# Install DuckDB CLI
RUN wget https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-aarch64.zip && \
    unzip duckdb_cli-linux-aarch64.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm duckdb_cli-linux-aarch64.zip

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes && \
    rm -rf /tmp/*

# Install Neovim (from Ubuntu PPA for latest version)
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:neovim-ppa/unstable && \
    apt-get update && \
    apt-get install -y --no-install-recommends neovim && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Install Charm tools (Gum, Glow) and Bat
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list && \
    apt-get update && apt-get install -y --no-install-recommends gum glow bat && \
    rm -rf /var/lib/apt/lists/*

# Install Ollama (local LLM runner)
RUN curl -fsSL https://ollama.com/install.sh | sh && \
    rm -rf /tmp/*

# Install oh-my-zsh for root user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    rm -rf /tmp/*

# Configure Starship for ZSH
RUN echo 'eval "$(starship init zsh)"' >> /root/.zshrc && \
    echo 'source /usr/local/fzf/shell/key-bindings.zsh' >> /root/.zshrc && \
    echo 'source /usr/local/fzf/shell/completion.zsh' >> /root/.zshrc && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.zshrc

# Create workspace directory
RUN mkdir -p /root/workspace /root/.local/share/code-server

# Final aggressive cleanup to minimize image size
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/* \
           /root/.cache \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/locale/* \
           /var/cache/apt/* \
           /root/.npm

# Copy scripts
COPY install-extensions.sh /usr/local/bin/install-extensions.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/install-extensions.sh /usr/local/bin/docker-entrypoint.sh

# Set working directory
WORKDIR /root/workspace

# Expose code-server and Ollama ports
EXPOSE 8080 11434

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
