# Coinductive auto traits

The `Send` and `Sync` traits introduced in the previous section
are the most prominent examples of _auto traits_.
Auto traits are a particular set of traits (not user extensible)
for which the compiler automatically adds an implementation.
In other words, the compiler automatically decides if a type $\tau$ implements `Send`
(unless the user opts out by providing their own impl).
The criteria used is that $\tau$ is `Send` if all of its field types are `Send`.
The following listing shows a struct $S$ along with the impl that the compiler would automatically introduce:

```rust
struct S<X_0, ..., X_n> {
    field0: τ_0,
    ...
    fieldN: τ_N,
}

impl<X_0, ..., X_n> Send for S<X_0, ..., X_n>
where
    τ_0: Send,
    ...
    τ_N: Send,
{
    // 
}
```

Besides having an automatic implementation, auto traits are different from other traits in that they use coinductive semantics.
The need for this arises because of the possibility of cycles between types.
To see this, consider the following (recursive) struct `List`:

```rust
struct List {
    next: Option<Box<List>>,
    //    ^^^^^^ This is a Rust enum, which we have not
    //           included in our Rust subset, but which
    //           are a typical algebraic data type
    //           (structs can be considered an enum with
    //           one variant).
}    
```

In this case,

- `List` is `Send` if `Option<Box<List>>` is `Send`,
- `Option<Box<List>>` is `Send` if `Box<List>` is `Send`,
- `Box<List>` is `Send` if `List` is `Send`,
- `List` is `Send` because we have a cycle and `Send` is a coinductive trait.
