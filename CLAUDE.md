# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## mdBook Authoring Guidelines

When working on mdBook content:

- **Consult notation conventions**: Always refer to the [Notation](./src/notation.md) chapter for mathematical and code formatting conventions
- **Maintain factual tone**: Avoid unnecessary adjectives, opinions, or promotional language
- **Add cross-references**: Link to related sections where concepts are defined or explained  
- **Target audience**: Write for PL researchers familiar with type theory but not necessarily Rust

### Literate Programming Style

This project uses a "literate programming lite" approach:

- **Include Lean code in mdBook**: Use mdBook's `{{#include}}` feature with anchors to include relevant Lean code sections
- **Add anchors in Lean files**: Surround important definitions with `-- ANCHOR: name` and `-- ANCHOR_END: name` comments
- **Create "Lean Implementation" sections**: Add these to mdBook chapters to show the formal definitions alongside mathematical notation
- **Program parameter convention**: Lean judgments include an explicit `Program` parameter for implementation needs, but this is intentionally omitted from the mathematical notation in mdBook for clarity

**Example interaction pattern:**
```
User: I want to work on X
Assistant: I see X involves A, B, and C. Should we start with A, or would you prefer to discuss the overall approach first?
User: Let's start with A  
Assistant: [does A] I've completed A. Here's what I found... Should we move to B next, or would you like to discuss something else?
```

## Ongoing Work Tracking

Track ongoing development work and progress in the `.ongoing/` directory:

- Create `.md` files for each major feature or investigation
- Include status, progress summary, next steps, and debugging context
- Update files as work progresses to maintain context across sessions
- Use descriptive filenames like `feature-name.md` or `bug-investigation.md`

## Project Overview

This is a hybrid academic/research project called "Rusty Logic" that combines:
- **LaTeX academic paper** using Springer Nature journal template  
- **Lean 4 formal verification** code for logic proofs
- **mdBook web documentation** that includes the generated PDF

The project explores formal logic concepts, likely related to Rust programming language semantics.

## Common Commands

### Build System (using `just`)
- `just build` - Build Sphinx documentation 
- `just serve` - Serve Sphinx documentation on local HTTP server
- `just mdbook-build` - Build mdBook documentation
- `just mdbook-serve` - Serve mdBook with live reload
- `just build-all` - Build all documentation and Lean code
- `just test-all` - Run all tests (currently just Lean)
- `just check` - Check what tools are installed

### Lean 4 Development  
- `just lean-build` - Build Lean 4 library and dependencies
- `just lean-test` - Build and test Lean 4 code
- `just lean-clean` - Clean Lean build artifacts
- `just lean-cache` - Download mathlib4 cache for faster builds

### Manual LaTeX Build
- `pdflatex sn-article.tex` - Compile main academic paper
- Bibliography workflow (currently commented): `bibtex sn-article && pdflatex sn-article.tex` (run twice)

### Documentation
- `mdbook build` - Build documentation only
- `mdbook serve` - Serve documentation with live reload

## Architecture

### Project Structure
```
rusty-logic/
├── sn-article.tex          # Main LaTeX academic paper
├── sn-bibliography.bib     # Bibliography
├── rusty/                  # Lean 4 formal verification code
│   ├── Rusty.lean         # Main library entry point  
│   ├── Rusty/Basic.lean   # Basic logic proofs
│   └── lakefile.lean      # Lean package configuration
├── src/                   # mdBook documentation source
└── book/                  # Generated mdBook output
```

### Lean 4 Package Configuration
- Package name: "rusty"
- Depends on mathlib4 for mathematical foundations
- Uses Lake as build system and dependency manager
- Pretty-printing enabled for unicode function notation

### Build Pipeline
1. LaTeX compilation generates `sn-article.pdf`
2. mdBook builds web documentation 
3. Generated PDF is copied to `book/assets/` for web access

## Development Notes

- The Lean 4 code includes AST definitions for the Rusty language subset with formal verification examples
- LaTeX uses Springer Nature Mathematical Physics style (`sn-mathphys-num`)
- Bibliography compilation is currently disabled in justfile
- Automated CI/CD configured for mdBook deployment and Lean testing
- Project uses git for version control
