# Program

A Rust program is defined as a sequence of declarations of

* [structs](./types.md#struct-definitions),
* [traits](./traits-and-impls.md#trait-definition),
* [impls](./traits-and-impls.md#trait-implementation), and
* **functions**.

In our formal system, a program $P$ consists of four components:

- $\overline{S}$: A list of struct definitions
- $\overline{T}$: A list of trait definitions  
- $\overline{I}$: A list of trait implementations
- $\overline{F}$: A list of function definitions

## Function Definitions

A function definition has the form:

$$\text{fn } f\langle\overline{X}\rangle() \text{ where } \overline{W} \{ \overline{s} \}$$

where:
- $f$ is the function identifier
- $\overline{X}$ are type parameters
- $\overline{W}$ are where-clause constraints
- $\overline{s}$ are statements in the function body

### Function Statements

Our simplified model includes two types of statements:

1. **Function calls**: $f\langle\overline{\tau}\rangle()$ - calling function $f$ with explicit type arguments $\overline{\tau}$
2. **Trait assertions**: $\text{assert\_impl!}(\tau: T)$ - asserting that type $\tau$ implements trait $T$

The assertion statements represent points where the function body assumes a trait is implemented and might call any of its methods.

## Lean Implementation

The formal definitions in our Lean 4 implementation:

### Function Definitions
```lean
{{#include ../rusty/Rusty/AST.lean:function}}
```

### Program Structure
```lean
{{#include ../rusty/Rusty/AST.lean:program}}
```
