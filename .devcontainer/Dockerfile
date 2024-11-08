# Use the base image
FROM mcr.microsoft.com/devcontainers/base:bookworm

# Install Python, Rust, and Just
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    rustc \
    cargo \
    python3-sphinx \
    python3-myst-parser \
    texlive-full \
    && rm -rf /var/lib/apt/lists/*

# Set the default user (replace 'vscode' with your preferred non-root user)
USER vscode