# Example programs

## Debug printing

A simple program with a trait, a concrete impl, and a blanket impl:

```rust
struct String {}
struct Vec<T> {}

trait Debug {}

impl Debug for String {}
impl<T> Debug for Vec<T> where T: Debug {}

fn print_vec<T>() where T: Debug {
    assert_impl!(Vec<T>: Debug);
}

fn main() {
    print_vec::<String>();
}
```

Here `main` calls `print_vec::<String>()`. After substituting `T = String`, the assertion becomes `assert_impl!(Vec<String>: Debug)`, which holds because the blanket impl applies with `T = String`, and its where clause `String: Debug` is satisfied by the concrete impl.

## Chained constraints

A program where trait resolution requires multiple steps:

```rust
struct Foo {}

trait A {}
trait B {}

impl A for Foo {}
impl<T> B for T where T: A {}

fn check<T>() where T: B {
    assert_impl!(T: B);
}

fn main() {
    check::<Foo>();
}
```

After substitution, `assert_impl!(Foo: B)` holds because the blanket impl `impl<T> B for T where T: A` applies with `T = Foo`, and its where clause `Foo: A` is satisfied by the concrete impl.
