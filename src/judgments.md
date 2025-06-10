# Judgments

## Where clause provable

The judgment 
$$\Gamma \vdash W$$ indicates that the where clause $W$ is provable from the context $\Gamma$.

For example, when $W$ is the where clause $T: \tau$, this judgment indicates that the trait $T$ is implemented for $\tau$.

## Associated type normalization

The judgment $$\Gamma \vdash A \: \tau \mapsto \tau_1$$ indicates that the associated type $A$, applied to the type $\tau$, reduces to $\tau_1$.

## Program judgments

The judgments are used to reference user-provided program declarations:

* $\text{impl}\langle\overline{X}\rangle\, T \text{ for } \tau \text{ where } \overline{W} \{ \text{type } A = \tau_A; \}$
* $\text{struct } S\langle\overline{X}\rangle \{ \overline{f}: \overline{\tau} \}$

When we reference these judgments, we will sometimes use $\ldots$ to elide parts of the judgment that are not relevant. For example, the following inference rule references the fact that there is an impl of $T$ but it does not need to reference the associated type defined in the impl.

$$\frac{
    \text{impl}\langle\overline{X}\rangle\, T \text{ for } \tau \text{ where } \overline{W} \in P \{ \ldots \} \quad
    \Gamma \vdash \overline{W}
}{
    \Gamma \vdash T : \tau
}$$

This rule states that if the program $P$ contains an implementation of trait $T$ for type $\tau$ with where clauses $\overline{W}$, and the context $\Gamma$ proves all the where clauses $\overline{W}$, then we can conclude that the where clause $T : \tau$ is provable.

## Example

Consider this simplified iterator trait and implementation:

```rust
trait Iter {
    type Item;
}

impl<T> Iter for Vec<T> {
    type Item = T;
}
```

From this code, we can derive the following judgments:

1. **Trait implementation**: $\emptyset \vdash \text{Iter} : \text{Vec}\langle T \rangle$
   
   This states that `Vec<T>` implements the `Iter` trait (for any type `T`).

2. **Associated type normalization**: $\emptyset \vdash \text{Item} : \text{Vec}\langle T \rangle \mapsto T$
   
   This states that when we ask "what is the `Item` type for `Vec<T>`?", the answer is `T`.

The empty context $\emptyset$ indicates these judgments hold without additional assumptions.

## Lean Implementation

The formal definition of judgments in our Lean 4 implementation:

```lean
{{#include ../rusty/Rusty/AST.lean:judgment}}
```

The Lean implementation includes an explicit `Program` parameter that contains all struct, trait, and impl definitions. This parameter is left implicit in the mathematical notation above for clarity, but is necessary in the implementation to access program declarations when evaluating judgments.
