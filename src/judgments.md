# Judgments

## Where clause provable

The judgment
$$\Gamma \vdash W$$
indicates that the where clause $W$ is provable from the context $\Gamma$.

In our base system, the only form of where clause is $\tau: T$, so this judgment reduces to: can we prove that $\tau$ implements trait $T$?

The context $\Gamma$ is a set of where clauses that are assumed to hold (e.g., from the where clauses on the enclosing function or impl).

## Inference rules

There are two ways to prove $\Gamma \vdash \tau: T$:

1. **Assumption**: The where clause $\tau: T$ is already in $\Gamma$.
2. **Impl**: There exists an impl in the program that, after substitution, proves $\tau: T$. See [Trait implementation](./trait-impl-judgment.md).

### Assumption rule

$$\frac{(\tau: T) \in \Gamma}{\Gamma \vdash \tau: T} \text{[Assumption]}$$

If $\tau: T$ is already in our context, we can conclude it holds.

## Example

Consider this program:

```rust
struct String {}
struct Vec<T> {}

trait Debug {}

impl Debug for String {}
impl<T> Debug for Vec<T> where T: Debug {}
```

From this program, we can derive:

1. $\emptyset \vdash \text{String}: \text{Debug}$ — via the concrete impl
2. $\emptyset \vdash \text{Vec}\langle\text{String}\rangle: \text{Debug}$ — via the blanket impl with $T = \text{String}$, since the where clause $\text{String}: \text{Debug}$ is provable

The empty context $\emptyset$ indicates these judgments hold without additional assumptions.
