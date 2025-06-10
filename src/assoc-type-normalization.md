# Associated type normalization

This rule determines when an associated type expression normalizes to a concrete type based on trait implementations.

$$
\frac{
    \begin{gather}
    \text{impl}\langle\overline{X}\rangle\:T\:\text{for}\:\tau_i\:\text{where}\:\overline{W} \{ \text{type}\:A = \tau_a; \} \\
    S = (\overline{X} \mapsto \overline{\tau_s}) \\
    \Gamma \vdash S(\overline{W}) \\
    \Gamma \vdash S(\tau_i) : T
    \end{gather}
}{
    \Gamma \vdash A\:S(\tau_i) \mapsto S(\tau_a)
}
$$

The rule works as follows:
- Given an impl that implements trait $T$ for type $\tau_i$ and defines associated type $A = \tau_a$
- We construct a substitution $S$ that maps the type parameters $\overline{X}$ to concrete types $\overline{\tau_s}$
- If we can prove the where clauses hold under substitution and the impl applies to the substituted type
- Then the associated type $A$ applied to $S(\tau_i)$ normalizes to $S(\tau_a)$

This captures how Rust resolves associated types: given a concrete type that implements a trait, the associated type is determined by the corresponding impl's type definition.

## Lean Implementation

The formal normalization rule is implemented in Lean:

```lean
{{#include ../rusty/Rusty/AssocTypeNorm.lean:assoc-type-normalization}}
```