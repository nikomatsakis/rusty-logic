# Notation

We use an overline $\overline{S}$ to indicate zero or more instances of the symbol $S$.
Syntactically it is represented as a comma-separated list (with optional trailing comma).

We reference the following terminals (also called tokens):

- a struct name $S$
- a trait name $T$
- an associated type name $A$
- a type parameter $X$

In the sections that follow we define the following non-terminals:

- A type name $\tau$ (see [Types](./types.md))
- A [trait definition and implementations](./traits-and-impls.md)
- A [where clause](./where-clauses.md) $W$

## Code Block Conventions

In Rust code examples, mathematical overlines are represented using explicit enumeration:
- $\overline{X}$ becomes `X_0, ..., X_n`
- $\overline{W}$ becomes `W_0, ..., W_m`
- $\overline{T_s}$ becomes `T_s_0, ..., T_s_n`

Mathematical symbols are preserved as Unicode: $\tau$ → `τ`, $\tau_A$ → `τ_A`.
