# Where Clauses

A provable predicate in our system is a _where clause_ $W$:

- `t: T` indicates that $\tau$ implements the trait $T$.
- `t: T<A = t1>` indicates that $\tau$ implements the trait $T$ and that the associated type $A$ is equal to $\tau_1$.
- `for<X...> W` indicates that $W$ is provable for all values of $\overline{X}$.
- `W0 => W1`, not available in Rust today, indicates that $W_0$ being true implies $W_1$ holds.

Our system also supports logical connectives for combining where clauses:

- `W0 ∧ W1` (conjunction) indicates both $W_0$ and $W_1$ hold
- `W0 ∨ W1` (disjunction) indicates either $W_0$ or $W_1$ holds  
- `∃X. W` (existential quantification) indicates there exists some $X$ such that $W$ holds

## Lean Implementation

The formal definition of where clauses in our Lean 4 implementation captures the full grammar:

```lean
{{#include ../rusty/Rusty/AST.lean:where-clause}}
```

Each constructor corresponds to the mathematical notation:
- `traitImpl` corresponds to $\tau: T$
- `traitAssoc` corresponds to $\tau: T\langle A = \tau_1 \rangle$
- `forAll` corresponds to $\text{for}\langle\overline{X}\rangle\, W$
- `implies` corresponds to $W_0 \Rightarrow W_1$ (future extension)
- `and` corresponds to $W_0 \land W_1$
- `or` corresponds to $W_0 \lor W_1$
- `exists` corresponds to $\exists\overline{X}.\, W$
