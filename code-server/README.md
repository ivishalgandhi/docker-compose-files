# 🚀 Ubuntu LTS Dev Environment - Code Server

A **lightweight** Docker-based development environment with VS Code in the browser, powered by Ubuntu 24.04 LTS and packed with modern CLI tools and programming languages.

## ✨ Features

- 🌐 **Browser-based VS Code** - Access from anywhere
- 💾 **Persistent Storage** - All data survives restarts
- 🔌 **Auto-install Extensions** - Configure via `.env`, `.txt`, or `.toml`
- 🛠️ **Fully Loaded Toolbox** - 20+ dev tools pre-installed
- ⚡ **Lightweight** - Optimized for minimal resource usage
- 🐧 **Ubuntu 24.04 LTS** - Stable and secure base
- 🔒 **Password Protected** - Secure by default

## 📦 Pre-installed Tools

### Languages & Compilers
- 🐍 **Python 3.12** - Latest Python with pip
- 🟢 **Node.js 20.x LTS** - JavaScript runtime with npm
- 🦀 **Rust** - Latest stable toolchain
- 🐹 **Go 1.23.2** - Google's Go compiler

### CLI Power Tools
- 🔍 **FZF** - Fuzzy finder for command line
- 🔎 **Ripgrep** - Ultra-fast grep alternative
- 🦇 **Bat** - Cat clone with syntax highlighting
- ✨ **Glow** - Render markdown in terminal
- 📊 **VisiData** - Terminal spreadsheet multitool
- 🦆 **DuckDB** - In-process SQL OLAP database
- 💎 **Harlequin** - Beautiful DuckDB TUI
- 📈 **xsv** - Fast CSV command-line toolkit
- 🎨 **Gum** - Charm's glamorous shell scripts
- 📝 **Markitdown** - Convert files to markdown

### Development Tools
- � **Neovim 0.10.2** - Modern Vim
- 🐚 **ZSH + Oh-My-Zsh** - Enhanced shell
- ⭐ **Starship** - Beautiful cross-shell prompt
- 🐳 **Docker CLI** - Container management
- 📦 **UV** - Blazing fast Python package manager
- 🐙 **Git + GitHub CLI** - Version control
- 🤖 **Gemini CLI** - Google's AI integration

## 🚀 Quick Start

### 1. Clone or Create Directory
```bash
cd /path/to/code-server
```

### 2. Configure Environment
```bash
cp .env.example .env
nano .env  # Edit your password and settings
```

### 3. Build and Start
```bash
# Option 1: Using build script (recommended)
./build.sh

# Option 2: Using Makefile
make quick

# Option 3: Using docker-compose directly
docker-compose up -d --build
```

### 4. Access VS Code
Open your browser: **http://localhost:8080**

Password: Whatever you set in `.env` (default: `changeme`)

## ⚙️ Configuration

### Environment Variables (`.env`)

```env
PORT=8080                 # Web interface port
PASSWORD=changeme        # Access password
PUID=1000               # User ID (run `id -u` to get yours)
PGID=1000               # Group ID (run `id -g` to get yours)
TZ=America/New_York     # Timezone
GEMINI_API_KEY=         # Optional: Google Gemini API key
EXTENSIONS=             # Comma-separated extension IDs
```

### Extension Installation Methods

**Method 1: Environment Variable** (Quick & Easy)
```env
EXTENSIONS=ms-python.python,golang.go,rust-lang.rust-analyzer
```

**Method 2: extensions.txt** (One Per Line)
```txt
ms-python.python
ms-python.vscode-pylance
golang.go
rust-lang.rust-analyzer
GitHub.copilot
```

**Method 3: extensions.toml** (Structured)
```toml
[extensions]
list = [
    "ms-python.python",
    "golang.go",
    "rust-lang.rust-analyzer"
]
```

## 📂 Directory Structure

```
code-server/
├── docker-compose.yml          # Container orchestration
├── Dockerfile                  # Ubuntu-based image
├── .env                        # Your config (gitignored)
├── .env.example               # Template
├── extensions.txt             # Extension list
├── install-extensions.sh      # Installer script
├── docker-entrypoint.sh       # Startup script
├── data/                      # Code-server data (created on first run)
└── workspace/                 # Your projects (created on first run)
```

## �️ Mounted Directories

Inside the container, you have access to:

- **`~/workspace`** - Your dedicated project workspace
- **`/host-home`** - Your entire host home directory (full access)
- **`~/.ssh`** - SSH keys (read-only)
- **`~/.gitconfig`** - Git configuration (read-only)

**Example**: Access your host Downloads folder at `/host-home/Downloads`

## �🛠️ Tool Usage Examples

### Bat - Better Cat
```bash
# View file with syntax highlighting
bat file.py

# View with line numbers
bat -n file.js

# Show non-printable characters
bat -A file.txt

# Compare to cat
cat file.py   # Plain text
bat file.py   # With colors and line numbers

# Set as cat alias
alias cat='bat'
```

### Glow - Markdown Viewer
```bash
# Render markdown beautifully
glow README.md

# Read from URL
glow https://github.com/user/repo/README.md

# Pager mode
glow -p file.md

# Show all markdown files
glow *.md

# Use with pipe
echo "# Hello\n**World**" | glow -
```

### Markitdown - Convert to Markdown
```bash
# Convert various files to markdown
markitdown document.pdf > output.md
markitdown presentation.pptx > slides.md
markitdown spreadsheet.xlsx > data.md
markitdown image.jpg > description.md

# Supported formats: PDF, PowerPoint, Word, Excel, Images, HTML, etc.
```

### Python Development with UV
```bash
# Create virtual environment
uv venv myproject
source myproject/bin/activate

# Install packages blazingly fast
uv pip install pandas numpy requests

# Run Python scripts
python script.py
```

### Data Analysis with DuckDB & Harlequin
```bash
# Interactive DuckDB TUI
harlequin database.db

# Quick SQL queries
duckdb -c "SELECT * FROM 'data.csv' LIMIT 10"

# VisiData for CSV exploration
vd data.csv
```

### CSV Processing with xsv
```bash
# View CSV stats
xsv stats data.csv

# Search and filter
xsv search "pattern" data.csv

# Convert CSV to JSON
xsv fmt data.csv | xsv select 1,2,3
```

### Fuzzy Finding with FZF
```bash
# Find files
find . -type f | fzf

# Search command history
history | fzf

# Preview files
fzf --preview 'cat {}'
```

### Fast Searching with Ripgrep
```bash
# Search all files
rg "function"

# Search specific file types
rg "TODO" -t python

# Case-insensitive with context
rg -i "error" -C 3
```

### Docker Management
```bash
# List containers (requires docker socket mount)
docker ps

# Build images
docker build -t myapp .

# Docker Compose
docker-compose up -d
```

### GitHub Operations
```bash
# Clone repos
gh repo clone username/repo

# Create issues
gh issue create

# View PRs
gh pr list
```

### Node.js Development
```bash
# Initialize project
npm init -y

# Install dependencies
npm install express

# Install dev dependencies
npm install --save-dev nodemon

# Run scripts
npm start
npm run dev

# Global packages
npm install -g typescript ts-node
```

### Go Development
```bash
# Initialize module
go mod init myproject

# Install dependencies
go get github.com/gin-gonic/gin

# Build and run
go build
./myproject
```

### Rust Development
```bash
# Create new project
cargo new myproject
cd myproject

# Build and run
cargo build
cargo run

# Add dependencies
cargo add tokio
```

### Ollama - Local LLMs
```bash
# Pull a model (first time)
ollama pull llama3.2

# List installed models
ollama list

# Run a model interactively
ollama run llama3.2

# Run with a prompt
ollama run llama3.2 "Explain Docker in simple terms"

# Use API
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Why is the sky blue?"
}'

# Pull other popular models
ollama pull mistral
ollama pull codellama
ollama pull llama3.2:1b    # Smaller, faster
ollama pull llama3.2:70b   # Larger, better

# Remove a model
ollama rm llama3.2

# Show model info
ollama show llama3.2

# Use with Python
pip install ollama
python3 << 'EOF'
import ollama
response = ollama.chat(model='llama3.2', messages=[
  {'role': 'user', 'content': 'Hello!'}
])
print(response['message']['content'])
EOF
```

## 🎨 Customization

### Add More Tools to Dockerfile

Edit `Dockerfile` and rebuild:
```dockerfile
# Add your custom tools
RUN apt-get install -y your-package
```

Then rebuild:
```bash
docker-compose down
docker-compose up -d --build
```

### Mount Docker Socket

To use Docker from within the container, uncomment in `docker-compose.yml`:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Mount SSH Keys

Already configured! Your `~/.ssh` and `~/.gitconfig` are mounted read-only.

## 📊 Resource Usage

Optimized for lightweight operation:
- **CPU Limit**: 2 cores max
- **Memory Limit**: 2GB max
- **Reservations**: 0.5 CPU, 512MB RAM
- **Base Image**: Ubuntu 24.04 LTS (minimal)

## 📊 Resource Usage

Optimized for lightweight operation:
- **CPU Limit**: 2 cores max
- **Memory Limit**: 2GB max
- **Reservations**: 0.5 CPU, 512MB RAM
- **Base Image**: Ubuntu 24.04 LTS (minimal)

Adjust in `docker-compose.yml` if needed.

## 🔧 Common Commands

### Using Makefile (Easiest)
```bash
make help          # Show all commands
make quick         # First-time setup
make up            # Start container
make down          # Stop container
make logs          # View logs
make shell         # Enter container
make restart       # Restart container
make health        # Health check
make backup        # Backup everything
make install-ext EXT=publisher.name  # Install extension
```

### Using Scripts
```bash
./build.sh         # Interactive setup
./health-check.sh  # System health check
```

### Using Docker Compose
```bash
# Start container
docker-compose up -d

# View logs
docker-compose logs -f

# View tool versions
docker-compose exec code-server-dev code-server --version

# Stop container
docker-compose down

# Rebuild after Dockerfile changes
docker-compose up -d --build

# Enter container shell
docker-compose exec code-server-dev zsh

# Install extension manually
docker-compose exec code-server-dev code-server --install-extension <id>

# List installed extensions
docker-compose exec code-server-dev code-server --list-extensions
```

## 🎯 Export Your Current VS Code Extensions

```bash
# Method 1: Direct export to extensions.txt
code --list-extensions > extensions.txt

# Method 2: Export as comma-separated for .env
code --list-extensions | tr '\n' ','

# Method 3: With descriptions
code --list-extensions --show-versions
```

## 🔒 Security Tips

1. **Change default password** in `.env` immediately
2. **Use strong passwords** (20+ characters)
3. **Consider reverse proxy** for HTTPS (nginx, Caddy, Traefik)
4. **Restrict network access** using firewall rules
5. **Keep image updated** regularly
6. **Don't expose port publicly** without HTTPS

## 🌐 Reverse Proxy Examples

### Nginx
```nginx
server {
    listen 80;
    server_name code.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Caddy
```
code.example.com {
    reverse_proxy localhost:8080
}
```

### Traefik (docker-compose labels)
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.code-server.rule=Host(`code.example.com`)"
  - "traefik.http.services.code-server.loadbalancer.server.port=8080"
  - "traefik.http.routers.code-server.tls=true"
  - "traefik.http.routers.code-server.tls.certresolver=letsencrypt"
```

## 🐛 Troubleshooting

### Extensions Not Installing
```bash
# Check logs
docker-compose logs -f code-server-dev

# Verify extension IDs
docker-compose exec code-server-dev code-server --list-extensions

# Try manual install
docker-compose exec code-server-dev code-server --install-extension ms-python.python
```

### Permission Issues
```bash
# Get your user IDs
id -u  # PUID
id -g  # PGID

# Update .env file with correct IDs
# Then rebuild
docker-compose down
docker-compose up -d
```

### Port Already in Use
```bash
# Find what's using the port
lsof -i :8080

# Kill the process or change PORT in .env
```

### Container Won't Start
```bash
# Check logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose up -d --build
```

### Out of Memory
```bash
# Increase limits in docker-compose.yml
memory: 4G  # Increase from 2G

# Or reduce extensions and tools
```

## 📚 Tool Documentation

- [Code-Server](https://github.com/coder/code-server)
- [UV Python Manager](https://github.com/astral-sh/uv)
- [FZF](https://github.com/junegunn/fzf)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [VisiData](https://www.visidata.org/)
- [DuckDB](https://duckdb.org/)
- [Harlequin](https://harlequin.sh/)
- [xsv](https://github.com/BurntSushi/xsv)
- [Starship](https://starship.rs/)
- [Neovim](https://neovim.io/)
- [GitHub CLI](https://cli.github.com/)
- [Charm Gum](https://github.com/charmbracelet/gum)

## 🔄 Updates

```bash
# Pull latest base images
docker-compose pull

# Rebuild with latest versions
docker-compose down
docker-compose up -d --build

# Update only code-server
docker-compose exec code-server-dev bash -c \
  "curl -fsSL https://code-server.dev/install.sh | sh"
```

## 💾 Backup & Migration

### Backup
```bash
# Backup everything
tar -czf code-server-backup-$(date +%Y%m%d).tar.gz \
  data/ workspace/ .env extensions.txt

# Backup just workspace
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace/
```

### Restore
```bash
# Extract backup
tar -xzf code-server-backup-*.tar.gz

# Restart container
docker-compose up -d
```

### Migrate to New Machine
```bash
# On old machine
tar -czf code-server-full.tar.gz code-server/

# Transfer file
scp code-server-full.tar.gz user@newhost:/path/

# On new machine
tar -xzf code-server-full.tar.gz
cd code-server/
docker-compose up -d
```

## 🎓 Tips & Tricks

### Use Neovim Inside Terminal
```bash
# Open file in terminal
nvim myfile.py

# With plugins
nvim +PluginInstall
```

### Starship Customization
```bash
# Create config
mkdir -p ~/.config
starship preset nerd-font-symbols > ~/.config/starship.toml

# Edit prompt
nvim ~/.config/starship.toml
```

### FZF Keybindings
- `Ctrl+T` - File search
- `Ctrl+R` - Command history
- `Alt+C` - Change directory

### UV Python Workflows
```bash
# Create and activate venv in one command
uv venv && source .venv/bin/activate

# Install from requirements.txt super fast
uv pip install -r requirements.txt

# Sync dependencies
uv pip sync requirements.txt
```

### DuckDB Quick Analysis
```bash
# Load CSV and query
duckdb -c "SELECT * FROM read_csv_auto('data.csv') WHERE value > 100"

# Create persistent database
duckdb mydata.db
```

## 🤝 Contributing

Feel free to customize and extend! Common modifications:

1. **Add language servers** for better IDE features
2. **Install additional tools** in Dockerfile
3. **Mount extra volumes** for datasets
4. **Add custom ZSH plugins** via oh-my-zsh
5. **Configure Neovim** with your favorite plugins

## 📄 License

This configuration is provided as-is for personal and commercial use.

## 🙏 Credits

Built with:
- [Code-Server](https://github.com/coder/code-server) by Coder
- [Ubuntu](https://ubuntu.com/) by Canonical
- [Oh-My-Zsh](https://ohmyz.sh/) by the community
- All the amazing CLI tools listed above

---

**Enjoy your lightweight, powerful dev environment! 🚀**
