# Introduction

Rust's trait system provides interfaces and type-level programming capabilities. The formal properties of this system—particularly around soundness—require precise specification for rigorous analysis.

This paper presents **Rusty**, a minimal subset of Rust focused on the trait system. Rusty is designed for programming language researchers familiar with type theory but not necessarily with Rust, providing a formal foundation for reasoning about trait resolution.

The current version of Rusty captures the core mechanics:

- Generic struct types with type parameters
- Trait definitions (as simple marker interfaces)
- Trait implementations with where-clause constraints
- Functions with generic type parameters and where clauses
- A soundness model based on monomorphic execution

We deliberately start with the simplest possible system and plan to extend it incrementally. See [Future extensions](./future-extensions.md) for the roadmap of features we plan to add.
