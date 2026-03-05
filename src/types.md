# Types

A type $\tau$ is one of:

- a struct $S\langle\overline{\tau}\rangle$ with type parameters $\overline{\tau}$
- a type parameter $X$

## Struct Definitions

A struct $S$ declares a named type with zero or more type parameters:

```rust
struct S<X_0, ..., X_n> {}
```

Our struct definitions include:
- The struct name $S$
- A list of type parameters $\overline{X}$

Structs in this layer have no fields — they exist only to give names to types that can be used in trait implementations. Fields are not needed for reasoning about trait resolution.
