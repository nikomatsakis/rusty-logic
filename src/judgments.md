# Judgments

## Trait implemented

The judgment 
$$\Gamma \vdash T \: \tau$$ inidicates that the trait $T$ is implemented for $\tau$.

## Associated type normalization

The judgment $$\Gamma \vdash A \: \tau \mapsto \tau_1$$ indicates that the associated type $A$, applied to the type $\tau$, reduces to $\tau_1$.

### Example

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
