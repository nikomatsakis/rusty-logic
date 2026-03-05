# Future extensions

The current system captures the minimal core of Rust's trait resolution. We plan to extend it incrementally with the following features:

- **Supertraits** — `trait Sub: Super {}` requiring that implementors of `Sub` also implement `Super`
- **Associated types** — `trait Iterator { type Item; }` with type projections `<T as Iterator>::Item`
- **Associated type bounds** — `trait Iterator { type Item: Display; }` constraining associated types
- **Associated type normalization** — the judgment $\Gamma \vdash A\:\tau \mapsto \tau_1$ for resolving type projections
- **Tuples and unit type** — `(τ₀, ..., τₙ)` including the empty tuple `()` as the unit type
- **Struct fields** — named fields enabling reasoning about well-formedness and auto trait propagation
- **Richer where clauses** — `for<X> W`, `W₀ => W₁`, `W₀ ∧ W₁`, `W₀ ∨ W₁`, `∃X. W`
- **Special traits** — `Copy`, `Send`, `Sync` with their compiler-enforced semantics
- **Auto traits** — compiler-generated impls with coinductive semantics for recursive types
- **Coherence and the orphan rule** — ensuring at most one impl applies for any type/trait pair
