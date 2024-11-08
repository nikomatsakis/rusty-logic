# Rusty, a featherweight Rust

This section briefly introduces Rusty, a subset of Rust focusing on traits. It is meant for people familiar with PL theory but not Rust in particular.

## Notation

We use an overline $\overline{S}$ to indicate zero or more instances of the symbol $S$ (rendered in code as `S...`).
Syntactically it is represented as a comma-separated list (with optional trailing comma).

We reference the following terminals (also called tokens):

* a struct name $S$ (rendered in code as `S`)
* a trait name $T$ (rendered in code as `T`)
* a function name $n$ (rendered in code as `n`)
* an associated type name $A$ (rendered in code as `A`)
* a type parameter $X$ (rendered in code as `X`)

In the sections that follow we define the following non-terminals:

* a type name $\tau$ (rendered in code as `t`)
* a trait definition and implementations
* a where clause $W$ (rendered as code as `W`)
* an expression $e$ (rendered in code as `e`)
* a program $P$

## Types

A type $\tau$ is...

* a struct $S\langle\overline{\tau}\rangle$ with type parameters $\overline{\tau}$
* a tuple $(\overline{\tau})$ of types (with the empty tuple $()$ representing the unit type)
* an associated type $A\:\tau$
* a type parameter $X$

## Programs

A Rusty program $P$ is a tuple of

* trait definitions and implementations
* function definitions
* struct definitions

including one function named `main` that has no type parameters or where-clauses and which indicates the start of execution.

## Trait definitions and impls in Rust

In Rust, a *trait $T$* is an interface, declared like so:

```rust
trait T: T_s... {
    type A: T_b...;
}
```

Traits in Rust contain methods and other kinds of members,
but we limit ourselves to the case of exactly one associated type.
The trait definition includes:

* The trait name $T$
* A list of "supertraits" $\overline{T_s}$. Every type that implements $T$ must also implement $\overline{T_s}$.
* An associated type $A$. Every impl of $T$ must prove a value $\tau_A$ for $A$.
* A list of bounds $\overline{T_b}$ on $A$. The value $\tau_A$ provided for $A$ must satisfy the bounds $\overline{T_b}$.

Traits are *implemented* for a given type $\tau$ via a `impl`:

```rust
impl<X...> T for t where W... {
    type A = t_A;
}
```

Implementations in Rust include:

* A set of type parameters $\overline{X}$
* The trait $T$ being implemented
* The self type $\tau$
* A list of where clauses $\overline{W}$ which must hold for the impl to apply
* A value $t_A$ for the associated type $A$

### Traits without associated types

In our formal grammar, all traits define exactly one associated type. In code examples we will sometimes show trait definitions and impls without any associated type. This can be translated to the model by adding an associated type with a fresh name.

## Where clauses

A provable predicate in our system is a *where clause* $W$:

* `t: T` indicates that $\tau$ implements the trait $T$.
* `t: T<A = t_1>` indicates that $\tau$ implements the trait $T$ and that the associated type $A$ is equal to $\tau_1$.
* `for<X...> W` indicates that $W$ is provable for all values of $overline{X}$.
* `W0 => W1`, not available in Rust today, indicates that $W_0 \Rightarrow W_1$ (i.e., $W_0$ being true implies $W_1$ holds).

## Functions and expressions

Functions and expressions in Rusty are not meant to reflect actual Rust computation but are simply a medium to test whether traits are implemented. A function definition has type parameters $\overline{X}$, where-clauses $\overline{WC}$, and an expression $e$:

```rust
fn n<X...>()
where
    WC...
{
    e
}
```

An expression $e$ can be one of

* a function call $n(\overline{\tau})$ (in code, `n::<t...>()`);
* a *trait assertion* $T\:\tau$ (in code `t as T`) that trait $T$ is implemented for $\tau$;
* a sequence $e_1; e_2$.

Trait assertions are not actually part of Rust. They are meant to model "some operation defined in the trait $T$". In real Rust, these operations might be calls to method, but there are also traits built-in to the language that gate access to certain operations. For example the trait `Copy` determines whether a value can be duplicated; it is only implemented for scalar types or aggregates of scalars, which never need a destructor. If it is possible to conclude that $\text{Copy}\:\tau$ for some type $\tau$ which is not a scalar, then this would allow unsound duplication of resources (leading to e.g. double frees).

## Struct definitions

A struct type $S$ with type parameters $\overline{X}$ in Rusty is declared like

```rust
struct S<X...> { }
```

We do not model struct field types.

## Example programs

Here are some example programs we'll use later on.
≈g
### Magic Copy

This program should not compile:

```rust
struct String {}

trait Copy { }
trait Magic: Copy { }

impl<T> Magic for T
where
    T: Magic
{ }

fn takes_magic<T: Magic>() {
    T as Copy
}

fn main() {
    takes_magic::<String>()
}
```

The problem here is that `takes_magic` is invoked with `String`. In its body, it includes a trait assertion `String as Copy`. However, there is no implementation of `Copy` that applies to `String` (the only implementation is for `Magic`).
