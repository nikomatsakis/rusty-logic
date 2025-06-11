# Testing and Properties

The Lean formalization enables both unit testing of inference rules through concrete examples and formal verification of meta-properties like soundness and decidability.

## Unit Testing with Examples

We can construct specific programs and prove that certain judgments are derivable:

```lean
{{#include ../rusty/Rusty/Tests.lean:example-program}}
```

```lean
{{#include ../rusty/Rusty/Tests.lean:example-derivations}}
```

These examples serve as "unit tests" that validate our inference rules work correctly on concrete cases.

## Meta-Properties

The formal system allows us to prove important properties:

```lean
{{#include ../rusty/Rusty/Tests.lean:properties}}
```

## Soundness and Well-Formedness

We define well-formedness predicates and prove soundness properties:

```lean
{{#include ../rusty/Rusty/Properties.lean:well-formed}}
```

```lean
{{#include ../rusty/Rusty/Properties.lean:soundness-properties}}
```

## Decidability

For restricted cases, we can prove decidability results:

```lean
{{#include ../rusty/Rusty/Properties.lean:decidability}}
```

This approach ensures our formal system is both correct and practically useful for reasoning about Rust's trait system.