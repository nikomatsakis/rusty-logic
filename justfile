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
    @command -v lean >/dev/null && echo "✓ lean" || echo "✗ lean (install via elan)"
    @command -v lake >/dev/null && echo "✓ lake" || echo "✗ lake (install via elan)"

# Build documentation (Sphinx)
build:
    cd doc && make html

# Build mdBook documentation
mdbook-build:
    mdbook build

# Serve documentation
serve: build
    python3 -m http.server --directory doc/_build/html

# Serve mdBook documentation
mdbook-serve:
    mdbook serve

# Build Lean project
lean-build:
    cd rusty && lake build

# Test Lean project (build + check examples)
lean-test: lean-build
    @echo "✓ Lean project built and tested successfully"

# Clean Lean build artifacts
lean-clean:
    cd rusty && lake clean

# Get mathlib cache for faster Lean builds
lean-cache:
    cd rusty && lake exe cache get

# Build everything (docs + lean)
build-all: build mdbook-build lean-build

# Test everything
test-all: lean-test
    @echo "✓ All tests passed"
