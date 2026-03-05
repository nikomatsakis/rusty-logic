# Substitution

We use standard substitution for type parameters.

A substitution $S$ is a mapping from type parameters to types:

$$S = (\overline{X} \mapsto \overline{\tau_s})$$

where $\overline{X}$ are type parameters and $\overline{\tau_s}$ are the corresponding types.

Applying a substitution $S$ to a type $\tau$, written $S(\tau)$, replaces each type parameter $X$ with its mapped type:

- $S(X) = \tau_s$ if $X \mapsto \tau_s \in S$, otherwise $S(X) = X$
- $S(S'\langle\overline{\tau}\rangle) = S'\langle S(\overline{\tau})\rangle$

Substitution extends pointwise to where clauses:

- $S(\tau: T) = S(\tau): T$
