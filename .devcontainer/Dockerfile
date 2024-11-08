# Use the base image
FROM mcr.microsoft.com/devcontainers/base:bookworm

# Install Python, Sphinx, and Rust
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    rustc \
    cargo \
    python3-sphinx \
    python3-myst-parser \
    && rm -rf /var/lib/apt/lists/*

# Install Just
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin

# Other packages:
#
# texlive-full \

# Set the default user (replace 'vscode' with your preferred non-root user)
USER vscode