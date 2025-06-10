# Rusty Logic

A research project exploring the formal logic foundations of Rust's type system through mathematical specification and machine-checked proofs.

## Project Structure

This project combines two complementary approaches to understanding Rust's logic:

- **[mdBook Documentation](./src/)** - Mathematical specification using formal notation, targeting PL researchers familiar with type theory
- **[Lean 4 Formalization](./rusty/)** - Machine-checked proofs and formal verification of the logical foundations

## Key Features

- **Literate Programming**: Lean code definitions are included directly in the mdBook chapters using anchors
- **Mathematical Rigor**: Formal judgments, axioms, and inference rules for trait resolution and type checking
- **Practical Examples**: Real Rust code patterns formalized and verified

## Getting Started

### Prerequisites

Install required tools:
```bash
just setup  # Installs mdbook and mdbook-katex via cargo
# Install Lean 4 via elan (see https://leanprover.github.io/lean4/doc/setup.html)
```

### Building

```bash
# Build everything
just build-all

# Build documentation only
just build

# Build and serve documentation with live reload
just serve

# Build Lean formalization
just lean-build

# Run all tests
just test-all
```

### Development Workflow

- Documentation source lives in `src/` and follows mdBook conventions
- Lean definitions in `rusty/` use anchor comments for inclusion in documentation
- See [CLAUDE.md](./CLAUDE.md) for detailed authoring guidelines and project conventions

## Architecture

```
rusty-logic/
├── src/                   # mdBook documentation source
├── book/                  # Generated mdBook output (ignored by git)
├── rusty/                 # Lean 4 formal verification code
│   ├── Rusty.lean        # Main library entry point  
│   └── Rusty/            # Core definitions and proofs
├── justfile              # Build automation
└── book.toml            # mdBook configuration
```

The project uses a "literate programming lite" approach where mathematical notation in the documentation is backed by formal Lean definitions, bridging the gap between readable exposition and machine-verified correctness.