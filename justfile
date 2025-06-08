# Install tools only if they're missing
setup:
    @command -v mdbook >/dev/null || (echo "Installing mdbook..." && cargo install mdbook)
    @command -v mdbook >/dev/null && echo "✓ mdbook already installed"
    @command -v mdbook-katex >/dev/null || (echo "Installing mdbook-katex..." && cargo install mdbook-katex)
    @command -v mdbook-katex >/dev/null && echo "✓ mdbook-katex already installed"

# Check what tools are installed
check:
    @echo "Checking required tools:"
    @command -v mdbook >/dev/null && echo "✓ mdbook" || echo "✗ mdbook (run 'just setup')"
    @command -v mdbook-katex >/dev/null && echo "✓ mdbook-katex" || echo "✗ mdbook-katex (run 'just setup')"

build:
    cd doc && make html

serve: build
    python3 -m http.server --directory doc/_build/html
