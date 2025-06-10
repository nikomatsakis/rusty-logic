# Program

A Rust program is defined as a sequence of declarations of

* [structs](./types.md#struct-definitions),
* [traits](./traits-and-impls.md#trait-definition), or
* [impls](./traits-and-impls.md#trait-implementation).

In our formal system, a program $P$ consists of three components:

- $\overline{S}$: A list of struct definitions
- $\overline{T}$: A list of trait definitions  
- $\overline{I}$: A list of trait implementations

## Lean Implementation

The formal definition of a Rust program in our Lean 4 implementation:

```lean
{{#include ../rusty/Rusty/AST.lean:program}}
```
