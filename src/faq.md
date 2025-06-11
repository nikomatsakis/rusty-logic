# Frequently Asked Questions

This chapter addresses common questions about our approach through a socratic dialogue between the authors and an interested PhD student in mathematical logic who is learning about Rust's trait system.

## What exactly are we trying to prove?

**Student**: I'm confused about the soundness property you're establishing. When you say "soundness," what exactly are you trying to prove?

**Author**: Great question! The property we want is actually about runtime safety. Our definition of "going wrong" is when Rust code executes and attempts to access a member of a trait that it believes to be implemented for a given type—like calling `<T as Trait>::method`—but there would in fact be no impl of `Trait` that applies to `T`.

**Student**: But wait, when does this trait member access actually happen at runtime? I thought type checking happened at compile time.

**Author**: You're absolutely right to question this. Our model doesn't include functions at all—we're keeping things as simple as possible. The idea is that in Rust, a function body that believes `Trait` is implemented for `T` *could* call any of its methods. So what we really want to check is: when do functions believe traits are implemented?

**Student**: Ah, so you're abstracting away from actual function calls and focusing on the "belief system"—when does the type system convince a function that `T: Trait`?

**Author**: Exactly! The property we want is: **"If the type system proves `T: Trait` (making it available as an assumption to function bodies), then there exists a concrete impl that witnesses this trait bound."**

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

**Student**: Here's something that puzzles me: in a function like `fn foo<T>() where T: Trait`, we assume `T: Trait` without any impl. How does this fit into the "impl existence" guarantee?

**Author**: That's a really important question. One way to think about it is that in Rust, all execution begins with `fn main` that has no where-clauses in scope. So we're concerned with whether it's possible to ultimately prove that a trait is implemented without any assumptions.

**Student**: Are you sure that's sufficient? What if we can prove an implication that lets us make some assumption that causes a problem?

**Author**: You're right to be skeptical! I'm somewhat uncertain about this in the face of implications. If we set up our soundness proof properly, that should be okay, but it's definitely something we need to dig into further.

## Associated types and projections

**Student**: What about associated type projections? If we prove `T: Iterator<Item = String>`, what impl are we claiming exists?

**Author**: We're claiming that there literally exists an impl with `type Item = String`.

**Student**: And if we have `trait Iterator { type Item: Display; }` with `impl Iterator for Vec<String> { type Item = String; }`, then proving `Vec<String>: Iterator` requires also proving `String: Display`?

**Author**: Exactly! This is captured by our requirement that "all where-clauses of the impl are provable." The associated type constraints become part of what we need to verify.

---

*This FAQ will be updated as we continue to refine our understanding of the model and address new questions that arise.*