# Trait definitions and impls in Rust

In Rust, a _trait_ $T$ is an interface, declared like so:

```rust
trait T: T_s_0, ..., T_s_n {
    type A: T_b_0, ..., T_b_m;
}
```

Traits in Rust contain methods and other kinds of members,
but we limit ourselves to the case of exactly one associated type.
The trait definition includes:

- The trait name $T$
- A list of "supertraits" $\overline{T_s}$. Every type that implements $T$ must also implement $\overline{T_s}$.
- An associated type $A$. Every impl of $T$ must prove a value $\tau_A$ for $A$.
- A list of bounds $\overline{T_b}$ on $A$. The value $\tau_A$ provided for $A$ must satisfy the bounds $\overline{T_b}$.

Traits are _implemented_ for a given type $\tau$ via a `impl`:

```rust
impl<X_0, ..., X_n> T for τ where W_0, ..., W_m {
    type A = τ_A;
}
```

Implementations in Rust include:

- A set of type parameters
