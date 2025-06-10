# Substitution

We use standard capture-avoiding substitution for type parameters in the Rusty type system.

A substitution $S$ is a mapping from type parameters to types:

$$S = (\overline{X} \mapsto \overline{\tau_s})$$

Where $\overline{X}$ are type parameters and $\overline{\tau_s}$ are the corresponding concrete types.

## Lean Implementation

```lean
{{#include ../rusty/Rusty/Substitution.lean:substitution}}
```