# 🟢 Node.js LTS Added!

## ✅ Changes Made

### Core Files Updated

#### 1. **Dockerfile**
- Added Node.js 20.x LTS installation
- Added npm update to latest version
- Set NODE_VERSION=20.x environment variable

```dockerfile
# Install Node.js LTS (20.x)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest
```

#### 2. **docker-entrypoint.sh**
- Added Node.js version display
- Added npm version display

```bash
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
```

#### 3. **Makefile**
- Updated test-tools command to include Node.js and npm

### Documentation Updated

#### 4. **README.md**
- Added Node.js to Languages & Compilers section
- Added "Node.js Development" section with examples:
  - npm init
  - Install dependencies
  - Global packages
  - Development workflows

#### 5. **TOOLS-REFERENCE.md**
- Added Node.js to Programming Languages table
- Added npm to Package Managers table
- Added "Node.js Development Workflow" section with:
  - Project initialization
  - Dependency management
  - Express.js example
  - Development tools (nodemon, TypeScript)

#### 6. **SUMMARY.md**
- Updated Languages count from 3 to 4
- Added Node.js 20.x LTS to installed tools list

#### 7. **START-HERE.md**
- Added Node.js and npm to tools list
- Added version check commands for Node.js and npm

#### 8. **FILE-LIST.md**
- Added Node.js to Dockerfile contents description

## 🎯 What You Get

### Node.js 20.x LTS
- **Version**: Latest LTS (Long Term Support)
- **Command**: `node`
- **Package Manager**: `npm` (latest)

### npm Features
- Install packages: `npm install package-name`
- Global packages: `npm install -g package-name`
- Development tools: `npm install --save-dev nodemon typescript`
- Run scripts: `npm start`, `npm run dev`
- Initialize projects: `npm init -y`

### Common Node.js Tools
Ready to install:
- **Express.js**: `npm install express`
- **TypeScript**: `npm install -g typescript`
- **ts-node**: `npm install -g ts-node`
- **Nodemon**: `npm install --save-dev nodemon`
- **ESLint**: `npm install --save-dev eslint`
- **Prettier**: `npm install --save-dev prettier`
- **Jest**: `npm install --save-dev jest`

## 🚀 Usage Examples

### Quick Test
```bash
# After building
docker-compose exec code-server-dev node --version
docker-compose exec code-server-dev npm --version
```

### Or use Makefile
```bash
make test-tools
```

### Create Express App
```bash
# In VS Code terminal
mkdir ~/workspace/my-express-app
cd ~/workspace/my-express-app
npm init -y
npm install express
```

Create `index.js`:
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Code-Server!');
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
```

Run it:
```bash
node index.js
```

### TypeScript Project
```bash
npm init -y
npm install --save-dev typescript @types/node
npx tsc --init

# Create src/index.ts
mkdir src
cat > src/index.ts << 'EOF'
const greeting: string = "Hello TypeScript!";
console.log(greeting);
EOF

# Compile and run
npx tsc
node dist/index.js
```

## 📦 Updated Tool Count

**Total: 22+ Tools**

### Languages (4) ⬆️
1. Python 3.12
2. **Node.js 20.x LTS** ← NEW!
3. Go 1.23.2
4. Rust (latest)

### Package Managers (5) ⬆️
1. UV (Python)
2. **npm (Node.js)** ← NEW!
3. pip (Python)
4. cargo (Rust)
5. go get (Go)

## 🔄 Next Steps

### To Apply Changes

#### Option 1: Rebuild Everything
```bash
docker-compose down
docker-compose up -d --build
```

#### Option 2: Use Makefile
```bash
make rebuild
```

### First Build
If you haven't built yet:
```bash
./build.sh
# or
make quick
```

### Test Node.js
After build completes:
```bash
make shell
# Then in container:
node --version
npm --version
```

## 📚 Node.js Resources

### Documentation
- [Node.js Docs](https://nodejs.org/docs/latest-v20.x/api/)
- [npm Docs](https://docs.npmjs.com/)
- [Express.js](https://expressjs.com/)
- [TypeScript](https://www.typescriptlang.org/)

### VS Code Extensions
Add these to `extensions.txt`:
```
dbaeumer.vscode-eslint
esbenp.prettier-vscode
ms-vscode.vscode-typescript-next
```

## ✅ Verification

After rebuild, check:
```bash
# Test Node.js
make test-tools

# Or manually
docker-compose exec code-server-dev node --version
docker-compose exec code-server-dev npm --version

# Should show:
# Node.js: v20.x.x
# npm: 10.x.x
```

## 🎉 Complete!

Node.js 20.x LTS is now part of your lightweight dev environment!

**Build it:** `make rebuild` or `docker-compose up -d --build`
