# Types

A type $\tau$ is...

- a struct $S\langle\overline{\tau}\rangle$ with type parameters $\overline{\tau}$
- a tuple $(\overline{\tau})$ of types (with the empty tuple $()$ representing the unit type)
- an associated type $A\:\tau$
- a type parameter $X$

## Lean Implementation

The formal definition of types in our Lean 4 implementation directly corresponds to the mathematical notation above:

```lean
{{#include ../rusty/Rusty/AST.lean:rusty-type}}
```

Each constructor maps to the mathematical notation:
- `struct` corresponds to $S\langle\overline{\tau}\rangle$ 
- `tuple` corresponds to $(\overline{\tau})$
- `assoc` corresponds to $A\:\tau$
- `param` corresponds to $X$

## Struct Definitions

A struct $S$ defines a composite data type with named fields:

```rust
struct S<X_0, ..., X_n> {
    field_0: τ_0,
    ...
    field_m: τ_m,
}
```

Our struct definitions include:
- The struct name $S$
- A list of type parameters $\overline{X}$
- A list of named fields with their types

### Lean Implementation

```lean
{{#include ../rusty/Rusty/AST.lean:struct-def}}
```

The `StructDef` structure captures the struct name, type parameters, and field types as pairs of field names and their corresponding types.
