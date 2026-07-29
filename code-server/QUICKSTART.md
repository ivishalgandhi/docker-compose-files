# 🚀 Quick Start Guide

Get your lightweight dev environment running in 5 minutes!

## ⚡ Speed Run

```bash
# 1. Configure
cp .env.example .env
nano .env  # Set your password

# 2. Build (first time ~10-15 min)
docker-compose up -d --build

# 3. Watch build progress
docker-compose logs -f

# 4. Access when ready
# Open: http://localhost:8080
```

## ✅ First Time Setup Checklist

- [ ] Copy `.env.example` to `.env`
- [ ] Change `PASSWORD` in `.env`
- [ ] Set `PUID` and `PGID` (run `id -u` and `id -g`)
- [ ] Add your extensions to `extensions.txt` or `.env`
- [ ] (Optional) Add `GEMINI_API_KEY` if using Gemini CLI
- [ ] Build container: `docker-compose up -d --build`
- [ ] Wait for build to complete (~10-15 minutes)
- [ ] Access at http://localhost:8080

## 🎯 Day-to-Day Usage

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Enter shell
docker-compose exec code-server-dev zsh

# Restart after changes
docker-compose restart
```

## 🔑 Get Your User IDs

```bash
# Your user ID
id -u

# Your group ID  
id -g

# Update these in .env as PUID and PGID
```

## 📦 Add Extensions

**Option 1: Edit extensions.txt**
```bash
nano extensions.txt
# Add one extension ID per line
```

**Option 2: Edit .env**
```bash
nano .env
# Set EXTENSIONS=ext1,ext2,ext3
```

Then restart:
```bash
docker-compose restart
```

## 🛠️ Essential Tools Installed

- **Python 3.12** - `python3`
- **Go 1.23** - `go`
- **Rust** - `cargo`, `rustc`
- **UV** - `uv` (fast Python package manager)
- **FZF** - `fzf` (fuzzy finder)
- **Ripgrep** - `rg` (fast search)
- **Neovim** - `nvim`
- **DuckDB** - `duckdb`
- **Harlequin** - `harlequin`
- **VisiData** - `vd`
- **Docker** - `docker`
- **Git + GitHub CLI** - `git`, `gh`

See `TOOLS-REFERENCE.md` for detailed usage!

## 🎨 Customize

### Add More Tools
Edit `Dockerfile`:
```dockerfile
RUN apt-get install -y your-tool
```

Rebuild:
```bash
docker-compose down
docker-compose up -d --build
```

### Mount Docker Socket
Uncomment in `docker-compose.yml`:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Adjust Resources
Edit `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'      # Increase
      memory: 4G       # Increase
```

## 🐛 Troubleshooting

### "Port already in use"
```bash
# Change PORT in .env
PORT=8081

# Or find what's using it
lsof -i :8080
```

### "Permission denied"
```bash
# Fix PUID/PGID in .env
PUID=$(id -u)
PGID=$(id -g)

# Rebuild
docker-compose down
docker-compose up -d
```

### "Container keeps restarting"
```bash
# Check logs
docker-compose logs

# Common issue: build failed
# Solution: rebuild
docker-compose down
docker-compose up -d --build
```

### Build is slow
This is normal! First build takes 10-15 min because it:
- Downloads Ubuntu base
- Compiles Rust & Go
- Installs 20+ tools

Subsequent builds use cache and are much faster.

## 📊 Build Time Expectations

- **First build**: 10-15 minutes
- **With cache**: 1-2 minutes
- **Just restart**: < 10 seconds

## 🎓 Next Steps

1. **Open terminal in VS Code** and test tools:
   ```bash
   python3 --version
   go version
   rustc --version
   fzf --version
   ```

2. **Try FZF** - Press `Ctrl+R` for command history

3. **Test DuckDB**:
   ```bash
   duckdb -c "SELECT 'Hello World'"
   ```

4. **Create Python project**:
   ```bash
   mkdir ~/workspace/myproject
   cd ~/workspace/myproject
   uv venv
   source .venv/bin/activate
   ```

5. **Read tool docs**: Open `TOOLS-REFERENCE.md`

## 🔗 Quick Links

- **Access**: http://localhost:8080
- **README**: `README.md` - Full documentation
- **Tools**: `TOOLS-REFERENCE.md` - All tools with examples
- **Extensions**: `extensions.txt` - Your extension list

## 💡 Pro Tips

1. **Use integrated terminal** in VS Code (more features than external)
2. **Starship prompt** is pre-configured with Git info
3. **FZF keybindings** work in terminal: `Ctrl+T`, `Ctrl+R`, `Alt+C`
4. **UV is faster** than pip - use it for Python packages
5. **Workspace folder** is at `~/workspace` - create projects there

## 📚 Learn More

- Check `README.md` for complete documentation
- Read `TOOLS-REFERENCE.md` for tool usage examples
- Visit tool websites (links in README)

---

**Happy coding! 🎉**
