#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Ubuntu-based Code-Server Dev Environment"
echo "=========================================="

# Install extensions
echo "Installing VS Code extensions..."
/usr/local/bin/install-extensions.sh

# Start Ollama service in background
echo "Starting Ollama service..."
nohup ollama serve > /tmp/ollama.log 2>&1 &
sleep 2

# Display installed tools versions
echo ""
echo "=========================================="
echo "📦 Installed Tools:"
echo "=========================================="
echo "Code-Server: $(code-server --version | head -n 1)"
echo "Python: $(python3 --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Go: $(go version)"
echo "Rust: $(rustc --version)"
echo "UV: $(uv --version)"
echo "FZF: $(fzf --version)"
echo "Ripgrep: $(rg --version | head -n 1)"
echo "DuckDB: $(duckdb --version)"
echo "Neovim: $(nvim --version | head -n 1)"
echo "Docker: $(docker --version)"
echo "Git: $(git --version)"
echo "GitHub CLI: $(gh --version | head -n 1)"
echo "Starship: $(starship --version)"
echo "Gum: $(gum --version)"
echo "Glow: $(glow --version)"
echo "Bat: $(bat --version | head -n 1)"
echo "Markitdown: $(python3 -c 'import markitdown; print(markitdown.__version__)' 2>/dev/null || echo 'installed')"
echo "Ollama: $(ollama --version 2>/dev/null || echo 'installed')"
echo "=========================================="
echo ""
echo "📁 Mounted Directories:"
echo "  ~/workspace     - Your projects"
echo "  /host-home      - Your host home directory"
echo "=========================================="
echo ""
echo "🤖 Ollama (Local LLMs):"
echo "  Service running on: http://localhost:11434"
echo "  Pull models: ollama pull llama3.2"
echo "  Run: ollama run llama3.2"
echo "  List: ollama list"
echo "=========================================="
echo ""

# Start code-server as coder user
echo "Starting code-server on http://0.0.0.0:8080"
echo "Password: ${PASSWORD:-changeme}"
echo "=========================================="

exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --auth password \
    --user-data-dir /root/.local/share/code-server \
    --disable-telemetry \
    /root/workspace
