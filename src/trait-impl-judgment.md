# Trait implemented judgment

This rule determines when a type implements a trait based on an impl declaration.

$$
\frac{
    \begin{gather}
    \text{impl}\langle\overline{X}\rangle\:T\:\text{for}\:\tau_i\:\text{where}\:\overline{W} \{ \ldots \} \\
    S = (\overline{X} \mapsto \overline{\tau_s}) \\
    \Gamma \vdash S(\overline{W})
    \end{gather}
}{
    \Gamma \vdash S(\tau_i) : T
}
$$

The rule works as follows:
- Given an impl declaration that implements trait $T$ for type $\tau_i$ with type parameters $\overline{X}$ and where clauses $\overline{W}$
- We construct a substitution $S$ that maps the type parameters $\overline{X}$ to concrete types $\overline{\tau_s}$
- If we can prove that the where clauses hold under this substitution (i.e., $\Gamma \vdash S(\overline{W})$)
- Then we can conclude that the substituted type $S(\tau_i)$ implements trait $T$

This captures the core logic of Rust's trait resolution: an impl applies to a specific type when its where clauses are satisfied after appropriate type parameter substitution.

## Lean Implementation

The formal rule is implemented in Lean as an inductive judgment:

```lean
{{#include ../rusty/Rusty/TraitImpl.lean:trait-impl-judgment}}
```

The substitution operations are defined in the [Substitution](./substitution.md) section.