# Trait definitions and impls

In Rust, a _trait_ $T$ is an interface. In our simplified system, a trait is just a name:

```rust
trait T {}
```

Traits are _implemented_ for a given type $\tau$ via an `impl`:

```rust
impl<X_0, ..., X_n> T for τ where W_0, ..., W_m {}
```

An implementation includes:

- A set of type parameters $\overline{X}$
- The trait name $T$ being implemented
- The implementing type $\tau$
- Where clauses $\overline{W}$ that must be satisfied
