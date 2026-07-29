# 🛠️ Installed Tools Reference

Quick reference for all pre-installed tools in this dev environment.

## 📋 Complete Tool List

### Programming Languages
| Tool | Version | Command | Description |
|------|---------|---------|-------------|
| Python | 3.12 | `python3` | Latest Python interpreter |
| Node.js | 20.x LTS | `node` | JavaScript runtime |
| npm | Latest | `npm` | Node package manager |
| Go | 1.23.2 | `go` | Google's Go compiler |
| Rust | Latest | `rustc`, `cargo` | Rust toolchain |

### Package Managers
| Tool | Command | Description |
|------|---------|-------------|
| UV | `uv` | Blazing fast Python package manager |
| npm | `npm` | Node.js package manager |
| pip | `pip3` | Standard Python package installer |
| cargo | `cargo` | Rust package manager |
| go get | `go get` | Go package manager |

### CLI Power Tools
| Tool | Command | Description |
|------|---------|-------------|
| FZF | `fzf` | Fuzzy finder - interactive filter |
| Ripgrep | `rg` | Ultra-fast text search (better than grep) |
| Bat | `bat` | Cat clone with syntax highlighting |
| Glow | `glow` | Render markdown in terminal |
| VisiData | `vd` | Terminal spreadsheet viewer/editor |
| xsv | `xsv` | Fast CSV command-line toolkit |
| Markitdown | `markitdown` | Convert files to markdown |

### Data & Database
| Tool | Command | Description |
|------|---------|-------------|
| DuckDB | `duckdb` | Embedded analytical database |
| Harlequin | `harlequin` | Beautiful DuckDB TUI |
| SQLite | `sqlite3` | Embedded SQL database |

### Development Tools
| Tool | Command | Description |
|------|---------|-------------|
| Neovim | `nvim` | Modern Vim text editor |
| Git | `git` | Version control system |
| GitHub CLI | `gh` | GitHub command-line tool |
| Docker | `docker` | Container runtime CLI |

### Shell & Terminal
| Tool | Command | Description |
|------|---------|-------------|
| ZSH | `zsh` | Z shell |
| Oh-My-Zsh | - | ZSH framework (pre-configured) |
| Starship | `starship` | Cross-shell prompt |
| Gum | `gum` | Glamorous shell scripts |
| Glow | `glow` | Terminal markdown renderer |

### Editor
| Tool | Port | Description |
|------|------|-------------|
| Code-Server | 8080 | VS Code in browser |

## 📖 Quick Usage Examples

### FZF - Fuzzy Finder
```bash
# Find files interactively
find . -type f | fzf

# Search command history
history | fzf

# Preview files while searching
fzf --preview 'bat --color=always {}'

# Multi-select mode
find . -type f | fzf -m

# Search and edit with vim
vim $(fzf)
```

### Ripgrep - Fast Search
```bash
# Basic search
rg "pattern"

# Case-insensitive
rg -i "pattern"

# Search specific file types
rg "function" -t python
rg "class" -t rust

# Show context (3 lines before/after)
rg "error" -C 3

# Search and replace preview
rg "old" -r "new" --passthru

# Count matches
rg "TODO" --count

# List files with matches
rg "pattern" -l
```

### VisiData - Data Exploration
```bash
# Open CSV file
vd data.csv

# Open multiple files
vd file1.csv file2.json

# Direct database query
vd postgres://user:pass@host/db

# Open URL
vd https://example.com/data.csv
```

**VisiData Keybindings:**
- `q` - quit
- `gq` - quit all sheets
- `H` - help
- `/` - search
- `[` `]` - sort ascending/descending
- `F` - add frequency table
- `+` - aggregate

### xsv - CSV Processing
```bash
# Show statistics
xsv stats data.csv

# Select specific columns
xsv select 1,2,5 data.csv

# Search rows
xsv search "pattern" data.csv

# Count rows
xsv count data.csv

# Sort by column
xsv sort -s column_name data.csv

# Join two CSVs
xsv join id1 file1.csv id2 file2.csv

# Convert to formatted table
xsv table data.csv | less -S
```

### DuckDB - SQL Analysis
```bash
# Start interactive session
duckdb

# Open database file
duckdb mydata.db

# Run query from command line
duckdb -c "SELECT * FROM 'data.csv' LIMIT 10"

# Create persistent database
duckdb mydb.duckdb

# Load CSV and query
duckdb -c "
  CREATE TABLE data AS 
  SELECT * FROM read_csv_auto('data.csv');
  SELECT * FROM data WHERE value > 100;
"

# Export query results
duckdb -c "COPY (SELECT * FROM data) TO 'output.csv' (HEADER, DELIMITER ',')"
```

### Harlequin - DuckDB TUI
```bash
# Start with database
harlequin database.db

# Connect to multiple databases
harlequin db1.db db2.db

# Start with query
harlequin -e "SELECT * FROM table"

# Read-only mode
harlequin --read-only data.db
```

**Harlequin Keybindings:**
- `Ctrl+Q` - quit
- `F1` - help
- `F2` - focus query editor
- `Ctrl+Enter` - run query
- `F9` - format query

### UV - Python Package Manager
```bash
# Create virtual environment
uv venv

# Activate venv
source .venv/bin/activate  # Linux/Mac

# Install package
uv pip install pandas

# Install from requirements
uv pip install -r requirements.txt

# Install with extras
uv pip install "package[extra]"

# Sync exact dependencies
uv pip sync requirements.txt

# List installed packages
uv pip list

# Uninstall package
uv pip uninstall package_name

# Compile requirements
uv pip compile requirements.in > requirements.txt
```

### Git & GitHub CLI
```bash
# Clone repository
gh repo clone owner/repo

# Create repository
gh repo create my-project --public

# View issues
gh issue list

# Create issue
gh issue create --title "Bug" --body "Description"

# View PRs
gh pr list

# Create PR
gh pr create --title "Feature" --body "Description"

# Checkout PR
gh pr checkout 123

# View repo in browser
gh repo view --web
```

### Bat - Enhanced Cat
```bash
# View file with syntax highlighting
bat file.py

# View multiple files
bat file1.js file2.js

# Show line numbers
bat -n script.sh

# Show all characters (including tabs, newlines)
bat -A file.txt

# Plain output (no decorations)
bat -p file.md

# Specify language for highlighting
bat -l python script.txt

# Pager mode (like less)
bat --paging=always large-file.log

# Diff two files
bat --diff file1.txt file2.txt

# Use with pipes
curl https://api.github.com/repos/owner/repo | bat -l json

# Set theme
bat --theme="Monokai Extended" file.py

# List available themes
bat --list-themes
```

### Glow - Markdown Renderer
```bash
# Render markdown file
glow README.md

# Read from URL
glow https://raw.githubusercontent.com/user/repo/main/README.md

# Pager mode (scrollable)
glow -p documentation.md

# Show all markdown files in directory
glow *.md

# Specific width
glow -w 80 file.md

# Render from stdin
echo "# Hello\n**Bold text**\n- List item" | glow -

# Different styles
glow -s dark README.md
glow -s light README.md

# No pager (print all at once)
glow --no-pager file.md
```

### Markitdown - File Converter
```bash
# Convert PDF to markdown
markitdown document.pdf > output.md

# Convert PowerPoint
markitdown presentation.pptx > slides.md

# Convert Word document
markitdown report.docx > report.md

# Convert Excel spreadsheet
markitdown data.xlsx > data.md

# Convert image (extracts text via OCR if available)
markitdown image.png > description.md

# Convert HTML
markitdown webpage.html > content.md

# Use with Python
python3 << 'EOF'
from markitdown import MarkItDown
md = MarkItDown()
result = md.convert("document.pdf")
print(result.text_content)
EOF
```

### Docker CLI
```bash
# List containers
docker ps

# List all containers
docker ps -a

# List images
docker images

# Build image
docker build -t myimage .

# Run container
docker run -d -p 8080:80 myimage

# Execute command in container
docker exec -it container_name bash

# View logs
docker logs container_name

# Stop container
docker stop container_name

# Remove container
docker rm container_name
```

### Neovim - Text Editor
```bash
# Open file
nvim file.txt

# Open at specific line
nvim +42 file.txt

# Open multiple files
nvim file1.txt file2.txt

# Diff mode
nvim -d file1.txt file2.txt
```

**Basic Neovim Commands:**
- `i` - insert mode
- `Esc` - normal mode
- `:w` - save
- `:q` - quit
- `:wq` - save and quit
- `:q!` - quit without saving
- `/pattern` - search
- `dd` - delete line
- `yy` - copy line
- `p` - paste

### Gum - Glamorous Shell Scripts
```bash
# Choose from list
gum choose "Option 1" "Option 2" "Option 3"

# Filter list interactively
ls | gum filter

# Input prompt
NAME=$(gum input --placeholder "Enter name")

# Confirmation
gum confirm "Are you sure?" && echo "Yes!"

# Multi-line input
gum write > output.txt

# Styled output
gum style --bold --foreground 212 "Hello!"

# Spinner
gum spin --spinner dot --title "Loading..." -- sleep 3

# Format text
echo "# Title" | gum format
```

### Starship - Prompt Customization
```bash
# Print config
starship print-config

# Initialize for ZSH
eval "$(starship init zsh)"

# Test prompt
starship prompt

# Explain prompt
starship explain

# Toggle specific modules
starship toggle python
```

## 🎯 Common Workflows

### Data Analysis Workflow
```bash
# 1. Download data
wget https://example.com/data.csv

# 2. Quick stats
xsv stats data.csv

# 3. Interactive exploration
vd data.csv

# 4. SQL analysis
duckdb -c "SELECT * FROM 'data.csv' WHERE value > 100"

# 5. Beautiful TUI
harlequin data.csv
```

### Python Development Workflow
```bash
# 1. Create project
mkdir myproject && cd myproject

# 2. Create virtual env
uv venv

# 3. Activate
source .venv/bin/activate

# 4. Install dependencies
uv pip install pandas numpy matplotlib

# 5. Code
nvim main.py

# 6. Run
python main.py
```

### Node.js Development Workflow
```bash
# 1. Create project
mkdir myapp && cd myapp

# 2. Initialize
npm init -y

# 3. Install dependencies
npm install express dotenv

# 4. Install dev tools
npm install --save-dev nodemon typescript @types/node

# 5. Create server
cat > index.js << 'EOF'
const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Hello World!'));
app.listen(3000, () => console.log('Server running on port 3000'));
EOF

# 6. Run
node index.js
# or with nodemon for auto-reload
npx nodemon index.js
```

### File Search & Processing
```bash
# 1. Find files fuzzy
find . -type f | fzf

# 2. Search content
rg "pattern" -t python

# 3. Edit found file
nvim $(rg "pattern" -l | fzf)

# 4. Process multiple files
rg "pattern" -l | xargs -I {} sed -i 's/old/new/g' {}
```

## 🦙 Ollama (Local LLMs)

**Why:** Run large language models locally without API keys or internet dependency.

### Basic Usage
```bash
# Pull a model (first time only)
ollama pull llama3.2

# List installed models
ollama list

# Run model interactively
ollama run llama3.2

# Quick question
ollama run llama3.2 "Explain Docker in simple terms"

# Exit interactive mode
/bye
```

### Model Management
```bash
# Popular models
ollama pull llama3.2        # Latest Llama (7B)
ollama pull llama3.2:1b     # Smallest, fastest (1B)
ollama pull llama3.2:70b    # Largest, best quality (70B)
ollama pull mistral         # Fast, efficient
ollama pull codellama       # Code-focused
ollama pull phi3           # Microsoft's model

# Show model details
ollama show llama3.2

# Remove a model
ollama rm llama3.2

# Check disk usage
du -sh ~/.ollama/models
```

### API Usage with curl
```bash
# Generate text
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Why is the sky blue?",
  "stream": false
}'

# Chat with history
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "system", "content": "You are a helpful coding assistant."},
    {"role": "user", "content": "How do I read a file in Python?"}
  ],
  "stream": false
}'

# Check if Ollama is running
curl http://localhost:11434/api/tags
```

### Python Integration
```bash
# Install Python client
pip install ollama

# Basic usage
python3 << 'EOF'
import ollama

# Simple chat
response = ollama.chat(
    model='llama3.2',
    messages=[{'role': 'user', 'content': 'Hello!'}]
)
print(response['message']['content'])

# Generate text
response = ollama.generate(
    model='llama3.2',
    prompt='Write a Python function to reverse a string'
)
print(response['response'])

# Streaming
for chunk in ollama.chat(
    model='llama3.2',
    messages=[{'role': 'user', 'content': 'Tell me a story'}],
    stream=True
):
    print(chunk['message']['content'], end='', flush=True)
EOF
```

### Node.js Integration
```bash
# Install Node.js client
npm install ollama

# Basic usage
node << 'EOF'
const ollama = require('ollama').default;

async function main() {
  // Simple chat
  const response = await ollama.chat({
    model: 'llama3.2',
    messages: [{ role: 'user', content: 'Hello!' }],
  });
  console.log(response.message.content);

  // Streaming
  const stream = await ollama.chat({
    model: 'llama3.2',
    messages: [{ role: 'user', content: 'Tell me a story' }],
    stream: true,
  });
  
  for await (const chunk of stream) {
    process.stdout.write(chunk.message.content);
  }
}

main();
EOF
```

### Code Assistant Examples
```bash
# Code review
ollama run codellama "Review this Python code:
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)"

# Generate code
ollama run codellama "Write a Python function to merge two sorted arrays"

# Explain code
ollama run codellama "Explain what this does:
docker-compose up -d"

# Debug help
ollama run codellama "Why am I getting 'module not found' error in Python?"
```

### Advanced Options
```bash
# Control temperature (creativity)
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Write a poem",
  "options": {
    "temperature": 0.8,
    "top_p": 0.9,
    "top_k": 40
  }
}'

# Set context length
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Summarize",
  "options": {
    "num_ctx": 4096
  }
}'

# Custom system prompt
ollama run llama3.2 --system "You are a pirate" "Hello!"
```

### Performance Tips
```bash
# Use smaller models for speed
ollama pull llama3.2:1b  # Fast responses

# Use larger models for quality
ollama pull llama3.2:70b # Better but slower

# Check GPU usage (if available)
nvidia-smi

# Monitor memory
htop

# Preload model (keeps in memory)
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "keep_alive": "5m"
}'
```

### RAG (Retrieval-Augmented Generation) Example
```python
import ollama

# Your documents/context
context = """
Docker is a platform for developing, shipping, and running applications
in containers. Containers are lightweight, portable, and isolated environments.
"""

# Ask question with context
response = ollama.chat(
    model='llama3.2',
    messages=[
        {
            'role': 'system',
            'content': f'Answer based on this context: {context}'
        },
        {
            'role': 'user',
            'content': 'What is Docker?'
        }
    ]
)
print(response['message']['content'])
```

### Common Issues
```bash
# Ollama not responding
ps aux | grep ollama  # Check if running
ollama serve          # Start manually

# Model download failed
rm -rf ~/.ollama/models/incomplete  # Clear incomplete
ollama pull llama3.2                # Retry

# Out of memory
ollama pull llama3.2:1b  # Use smaller model

# Port conflict
# Change OLLAMA_PORT in .env and rebuild container
```

### Best Models by Use Case
- **General chat:** llama3.2, mistral
- **Code:** codellama, llama3.2
- **Speed:** llama3.2:1b, phi3
- **Quality:** llama3.2:70b (requires more RAM)
- **Small size:** phi3, llama3.2:1b

---

## 🔗 External Resources

- [FZF Wiki](https://github.com/junegunn/fzf/wiki)
- [Ripgrep Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [VisiData Docs](https://www.visidata.org/docs/)
- [DuckDB Docs](https://duckdb.org/docs/)
- [UV Docs](https://github.com/astral-sh/uv)
- [Neovim Docs](https://neovim.io/doc/)
- [Gum Examples](https://github.com/charmbracelet/gum#examples)
- [Ollama Docs](https://github.com/ollama/ollama/tree/main/docs)
- [Ollama Models](https://ollama.com/library)

## 💡 Pro Tips

1. **Combine tools with pipes:**
   ```bash
   rg "TODO" -l | fzf | xargs nvim
   ```

2. **Use FZF for command history:**
   ```bash
   # Press Ctrl+R in terminal
   ```

3. **Create aliases in ~/.zshrc:**
   ```bash
   alias vimf='nvim $(fzf)'
   alias rgf='rg -l | fzf'
   ```

4. **Use DuckDB for quick CSV analysis:**
   ```bash
   duckdb -c "SELECT * FROM 'huge.csv' LIMIT 10"
   ```

5. **UV is much faster than pip:**
   ```bash
   time uv pip install pandas  # vs
   time pip install pandas
   ```

---

**Remember:** Press `Ctrl+R` for command history with FZF! 🎯
