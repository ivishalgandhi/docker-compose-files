#!/bin/bash
set -e

echo "=========================================="
echo "📦 VS Code Server Extension Installer"
echo "=========================================="

# Function to install extensions from environment variable
install_from_env() {
    if [ -n "$EXTENSIONS" ]; then
        echo "Installing extensions from EXTENSIONS environment variable..."
        IFS=',' read -ra EXT_ARRAY <<< "$EXTENSIONS"
        for extension in "${EXT_ARRAY[@]}"; do
            # Trim whitespace
            extension=$(echo "$extension" | xargs)
            if [ -n "$extension" ]; then
                echo "📥 Installing extension: $extension"
                code-server --install-extension "$extension" 2>/dev/null || echo "⚠️  Failed to install $extension"
            fi
        done
    else
        echo "ℹ️  No extensions specified in EXTENSIONS variable"
    fi
}

# Function to install extensions from extensions.txt file
install_from_file() {
    if [ -f "/extensions.txt" ]; then
        echo "Installing extensions from extensions.txt..."
        while IFS= read -r extension || [ -n "$extension" ]; do
            # Skip empty lines and comments
            [[ -z "$extension" || "$extension" =~ ^#.*$ ]] && continue
            # Trim whitespace
            extension=$(echo "$extension" | xargs)
            if [ -n "$extension" ]; then
                echo "📥 Installing extension: $extension"
                code-server --install-extension "$extension" 2>/dev/null || echo "⚠️  Failed to install $extension"
            fi
        done < "/extensions.txt"
    else
        echo "ℹ️  No extensions.txt file found"
    fi
}

# Function to install extensions from TOML file
install_from_toml() {
    if [ -f "/home/coder/.local/share/code-server/extensions.toml" ]; then
        echo "Installing extensions from extensions.toml..."
        # Extract extensions from TOML (simple parsing)
        extensions=$(grep -E '^\s*".*"' /home/coder/.local/share/code-server/extensions.toml | sed 's/[",]//g' | xargs)
        if [ -n "$extensions" ]; then
            for extension in $extensions; do
                echo "📥 Installing extension: $extension"
                code-server --install-extension "$extension" 2>/dev/null || echo "⚠️  Failed to install $extension"
            done
        fi
    else
        echo "ℹ️  No extensions.toml file found"
    fi
}

# Install extensions based on priority: TOML > extensions.txt > ENV
if [ -f "/home/coder/.local/share/code-server/extensions.toml" ]; then
    install_from_toml
elif [ -f "/extensions.txt" ]; then
    install_from_file
else
    install_from_env
fi

echo "=========================================="
echo "✅ Extension installation complete!"
echo "=========================================="
