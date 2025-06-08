# Where Clauses

A provable predicate in our system is a _where clause_ $W$:

- `t: T` indicates that $\tau$ implements the trait $T$.
- `t: T<A = t1>` indicates that $\tau$ implements the trait $T$ and that the associated type $A$ is equal to $\tau_1$.
- `for<X...> W` indicates that $W$ is provable for all values of $\overline{X}$.
- `W0 => W1`, not available in Rust today, indicates that $W_0$ being true implies $W_1$ holds.
