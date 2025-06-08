# Introduction

Rust's trait system provides interfaces and type-level programming capabilities. The formal properties of this system—particularly around coherence, soundness, and completeness—require precise specification for rigorous analysis.

This paper presents **Rusty**, a subset of Rust that focuses on the trait system. Rusty is designed for programming language researchers familiar with type theory but not necessarily with Rust, providing a formal foundation that includes:

- Basic trait definitions and implementations
- Associated types and where clauses  
- Coherence properties and the orphan rule
- Auto traits like `Send` and `Sync` with coinductive semantics

Our goal is to provide a mathematical model accessible to PL researchers that enables formal analysis of Rust's trait system design and properties.