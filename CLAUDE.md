# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**If you remember nothing else:** Before making edits to files or otherwise beginning execution, confirm the plan with the user.

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
- `just build` - Compiles LaTeX to PDF and builds mdBook documentation
- `just serve` - Serves the built documentation on local HTTP server

### Lean 4 Development
- `cd rusty && lake build` - Build Lean 4 library and dependencies
- `cd rusty && lake exe cache get` - Download mathlib4 cache for faster builds
- `cd rusty && lake clean` - Clean build artifacts

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

- The Lean 4 code is in early stages with basic propositional logic examples
- LaTeX uses Springer Nature Mathematical Physics style (`sn-mathphys-num`)
- Bibliography compilation is currently disabled in justfile
- No automated testing or CI/CD configured
- Project uses git for version control