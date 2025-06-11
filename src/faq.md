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

**Student**: Can you give an example with blanket impls? If I have `impl<T: Display> ToString for T` and I want to prove `String: ToString`?

**Author**: Perfect example! The "existing impl" would be this blanket impl with `T = String`, and we'd need to prove `String: Display`. The impl "exists" if we can find this instantiation and prove all its requirements.

## How do supertraits work?

**Student**: What about supertraits? If I have `trait Sub: Super` and `impl Sub for String`, can I prove `String: Super` even though there's no explicit `impl Super for String`?

**Author**: Exactly—this is a key case we need to examine. When you have `trait Sub: Super`, if a generic function knows that `T: Sub`, it can also *assume* that `T: Super`. We need to show that this assumption is well-founded, meaning there MUST exist an impl `Super for T`.

**Student**: But how can there be an impl `Super for T` if I only wrote `impl Sub for T`?

**Author**: This goes back to our definition of "impl existence." The same `impl Sub for String` declaration can witness both `String: Sub` and `String: Super`, because implementing `Sub` implies implementing `Super`.

## What about where-clause assumptions?

**Student**: Here's something that puzzles me: in a function like `fn foo<T>() where T: Trait`, we can write `assert_impl!(T: Trait)` justified by the where-clause. But `T` is just a parameter - how does this fit into the "impl existence" guarantee?

**Author**: Excellent question! This is where the execution model becomes crucial. Consider this program:
```
fn foo<T>() where T: Display {
    assert_impl!(T: Display);
}

fn main() {
    foo::<String>();
}
```

**Student**: I see that `main` calls `foo` with a concrete type...

**Author**: Exactly! When we execute `foo::<String>()`, we substitute `T = String` throughout `foo`'s body. So `assert_impl!(T: Display)` becomes `assert_impl!(String: Display)` - completely monomorphic.

**Student**: So we never actually execute assertions with type parameters?

**Author**: Right! All execution begins with `main()`, which has no type parameters or where-clauses. Every function call from `main` provides concrete types, so every assertion that executes involves only monomorphic types.

**Student**: This eliminates the circularity about assumptions! We only need concrete witnesses.

**Author**: Precisely. The soundness property becomes: "If `main` is well-typed, then every `assert_impl!(ConcreteType: Trait)` that could execute has a concrete impl witness." No reasoning about type parameters during execution - just concrete impl lookup.

## Associated types and normalization

**Student**: What about associated type projections? If I have a function that uses `<T as Iterator>::Item`, what happens during substitution?

**Author**: Excellent question! Consider this example:
```
fn process_items<T>() where T: Iterator {
    assert_impl!(<T as Iterator>::Item: Display);
}

fn main() {
    process_items::<Vec<String>>();
}
```

**Student**: When we substitute `T = Vec<String>`, don't we get `assert_impl!(<Vec<String> as Iterator>::Item: Display)`? That still has an associated type projection!

**Author**: Precisely! Substitution involves **normalization** of associated type projections. We need to normalize `<Vec<String> as Iterator>::Item` to its concrete type (say, `String`), giving us `assert_impl!(String: Display)`.

**Student**: So normalization must always be possible in well-typed programs?

**Author**: That's a key property we want to establish! In a well-typed program, `<Vec<String> as Iterator>::Item` should normalize to exactly one type. This connects to **coherence** - the property that there's no ambiguity about which impl applies.

**Student**: This seems like a separate concern from impl existence...

**Author**: Indeed! For our soundness proof, we might separate these concerns. We could show the weaker property that there exists *some* normalized type for which impl witnesses exist, leaving the uniqueness (coherence) as a separate theorem.

*[Note: The relationship between normalization, coherence, and soundness deserves deeper exploration in a dedicated section.]*

---

*This FAQ will be updated as we continue to refine our understanding of the model and address new questions that arise.*