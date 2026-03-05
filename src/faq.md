# Frequently Asked Questions

This chapter addresses common questions about our approach through a socratic dialogue between the authors and an interested PhD student in mathematical logic who is learning about Rust's trait system.

## What exactly are we trying to prove?

**Student**: I'm confused about the soundness property you're establishing. When you say "soundness," what exactly are you trying to prove?

**Author**: Great question! The property we want is about runtime safety. Our definition of "going wrong" is when Rust code executes and attempts to access a member of a trait that it believes to be implemented for a given type—like calling `<T as Trait>::method`—but there would in fact be no impl of `Trait` that applies to `T`.

**Student**: When does this trait member access actually happen? Can you make this concrete?

**Author**: Certainly! Our model includes functions that look like this:
```
fn foo<T₁, T₂, ...>() where W₁, W₂, ... {
    // Function body contains:
    // 1. Calls to other functions: bar::<String, i32>()
    // 2. Assertions: assert_impl!(T₁: Display)
}
```

**Student**: What are these "assertions"?

**Author**: Think of `assert_impl!(T: Trait)` as representing any point where the function body believes `Trait` is implemented for `T` and might call any of its methods. Rather than modeling every possible method call, we model the essential assertion that the trait is implemented.

**Student**: So "going wrong" means executing an assertion that fails?

**Author**: Exactly! **"Going wrong"** means executing `assert_impl!(T: Trait)` when no concrete impl exists to witness it. The soundness property becomes: **"If the type system accepts a program starting from `main`, then execution never reaches a failing assertion."**

## What does "impl existence" mean?

**Student**: When you say there "exists a concrete impl," what exactly do you mean? Are you talking about literal `impl` blocks in the source code?

**Author**: Good question. "Impl existence" means there exists some impl declaration in the program plus some instantiation of its parameters such that:
1. The types are equal after instantiation
2. All of the impl's where-clauses are provable

**Student**: Can you give an example with blanket impls? If I have `impl<T: Debug> Display for T` and I want to prove `String: Display`?

**Author**: Perfect example! The "existing impl" would be this blanket impl with `T = String`, and we'd need to prove `String: Debug`. The impl "exists" if we can find this instantiation and prove all its requirements.

## What about where-clause assumptions?

**Student**: Here's something that puzzles me: in a function like `fn foo<T>() where T: Trait`, we can write `assert_impl!(T: Trait)` justified by the where-clause. But `T` is just a parameter — how does this fit into the "impl existence" guarantee?

**Author**: Excellent question! This is where the execution model becomes crucial. Consider this program:
```
fn foo<T>() where T: Debug {
    assert_impl!(T: Debug);
}

fn main() {
    foo::<String>();
}
```

**Student**: I see that `main` calls `foo` with a concrete type...

**Author**: Exactly! When we execute `foo::<String>()`, we substitute `T = String` throughout `foo`'s body. So `assert_impl!(T: Debug)` becomes `assert_impl!(String: Debug)` — completely monomorphic.

**Student**: So we never actually execute assertions with type parameters?

**Author**: Right! All execution begins with `main()`, which has no type parameters or where-clauses. Every function call from `main` provides concrete types, so every assertion that executes involves only monomorphic types.

**Student**: This eliminates the circularity about assumptions! We only need concrete witnesses.

**Author**: Precisely. The soundness property becomes: "If `main` is well-typed, then every `assert_impl!(ConcreteType: Trait)` that could execute has a concrete impl witness." No reasoning about type parameters during execution — just concrete impl lookup.

---

*This FAQ will be updated as we continue to refine our understanding of the model and address new questions that arise.*
