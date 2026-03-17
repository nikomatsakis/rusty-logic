/-
  Examples — Worked examples from the mdBook

  Programs are defined directly on the IR for clean proofs.
  Surface syntax versions are shown in comments for readability.
-/
import Rusty.Judgment
import Rusty.Surface

/-!
## Debug printing example

```rust
struct String {}
struct Vec<T> {}
trait Debug {}
impl Debug for String {}
impl<T> Debug for Vec<T> where T: Debug {}
fn print_vec<T>() where T: Debug { assert_impl!(Vec<T>: Debug); }
fn main() { print_vec::<String>(); }
```
-/

-- ANCHOR: debugProgram

/-- `impl Debug for String {}` -/
def implDebugString : ImplDef :=
  { arity := 0, trait := "Debug",
    implTy := .struct "String" [],
    whereClauses := [] }

/-- `impl<T> Debug for Vec<T> where T: Debug {}` — T is bvar 0 -/
def implDebugVec : ImplDef :=
  { arity := 1, trait := "Debug",
    implTy := .struct "Vec" [.bvar 0],
    whereClauses := [⟨.bvar 0, "Debug"⟩] }

def debugProgram : Program :=
  { impls := [implDebugString, implDebugVec],
    funcs := [
      -- fn print_vec<T>() where T: Debug { assert_impl!(Vec<T>: Debug); }
      { name := "print_vec", arity := 1,
        whereClauses := [⟨.bvar 0, "Debug"⟩],
        body := [.assertImpl (.struct "Vec" [.bvar 0]) "Debug"] },
      -- fn main() { print_vec::<String>(); }
      { name := "main", arity := 0,
        whereClauses := [],
        body := [.call "print_vec" [.struct "String" []]] }
    ] }
-- ANCHOR_END: debugProgram

/-!
### Proof: `String: Debug`

Uses `impl Debug for String {}`. No type parameters, so tyArgs = [].
-/

-- ANCHOR: string_debug
theorem string_implements_debug :
    Proves debugProgram [] (.struct "String" []) "Debug" :=
  .byImpl implDebugString []
    (by simp [debugProgram])
    rfl rfl
    (by simp [applySubst, applySubstList, implDebugString])
    (by intro wc hwc; simp [implDebugString] at hwc)
-- ANCHOR_END: string_debug

/-!
### Proof: `Vec<String>: Debug`

Uses `impl<T> Debug for Vec<T> where T: Debug` with tyArgs = [String].
-/

-- ANCHOR: vec_string_debug
theorem vec_string_implements_debug :
    Proves debugProgram [] (.struct "Vec" [.struct "String" []]) "Debug" :=
  .byImpl implDebugVec [.struct "String" []]
    (by simp [debugProgram])  -- implDebugVec ∈ debugProgram.impls
    rfl                        -- trait = "Debug"
    rfl                        -- tyArgs.length = arity
    (by simp [applySubst, applySubstList, implDebugVec])  -- substituted type matches
    (by -- prove each where clause
      intro wc hwc
      simp [implDebugVec] at hwc
      subst hwc
      simp [applySubstWC, applySubst]
      exact string_implements_debug)
-- ANCHOR_END: vec_string_debug

/-!
## Chained constraints example

```rust
struct Foo {}
trait A {}
trait B {}
impl A for Foo {}
impl<T> B for T where T: A {}
fn check<T>() where T: B { assert_impl!(T: B); }
fn main() { check::<Foo>(); }
```
-/

-- ANCHOR: chainedProgram

/-- `impl A for Foo {}` -/
def implAFoo : ImplDef :=
  { arity := 0, trait := "A",
    implTy := .struct "Foo" [],
    whereClauses := [] }

/-- `impl<T> B for T where T: A {}` — T is bvar 0 -/
def implBlanketB : ImplDef :=
  { arity := 1, trait := "B",
    implTy := .bvar 0,
    whereClauses := [⟨.bvar 0, "A"⟩] }

def chainedProgram : Program :=
  { impls := [implAFoo, implBlanketB],
    funcs := [
      -- fn check<T>() where T: B { assert_impl!(T: B); }
      { name := "check", arity := 1,
        whereClauses := [⟨.bvar 0, "B"⟩],
        body := [.assertImpl (.bvar 0) "B"] },
      -- fn main() { check::<Foo>(); }
      { name := "main", arity := 0,
        whereClauses := [],
        body := [.call "check" [.struct "Foo" []]] }
    ] }
-- ANCHOR_END: chainedProgram

/-!
### Proof: `Foo: A`
-/

-- ANCHOR: foo_a
theorem foo_implements_a :
    Proves chainedProgram [] (.struct "Foo" []) "A" :=
  .byImpl implAFoo []
    (by simp [chainedProgram])
    rfl rfl
    (by simp [applySubst, applySubstList, implAFoo])
    (by intro wc hwc; simp [implAFoo] at hwc)
-- ANCHOR_END: foo_a

/-!
### Proof: `Foo: B`

Uses `impl<T> B for T where T: A` with T ↦ Foo.
Where clause `Foo: A` proved above.
-/

-- ANCHOR: foo_b
theorem foo_implements_b :
    Proves chainedProgram [] (.struct "Foo" []) "B" :=
  .byImpl implBlanketB [.struct "Foo" []]
    (by simp [chainedProgram])
    rfl rfl
    (by simp [applySubst, implBlanketB])
    (by intro wc hwc
        simp [implBlanketB] at hwc
        subst hwc
        simp [applySubstWC, applySubst]
        exact foo_implements_a)
-- ANCHOR_END: foo_b

/-!
## Lowering round-trip check

Verify that the surface syntax lowers to the same IR we wrote by hand.
-/

def debugSurface : Surface.Program := {
  impls := [
    { tyParams := [], trait := "Debug",
      implTy := .struct "String" [],
      whereClauses := [] },
    { tyParams := ["T"], trait := "Debug",
      implTy := .struct "Vec" [.param "T"],
      whereClauses := [⟨.param "T", "Debug"⟩] }
  ],
  funcs := [
    { name := "print_vec", tyParams := ["T"],
      whereClauses := [⟨.param "T", "Debug"⟩],
      body := [.assertImpl (.struct "Vec" [.param "T"]) "Debug"] },
    { name := "main", tyParams := [],
      whereClauses := [],
      body := [.call "print_vec" [.struct "String" []]] }
  ]
}

-- Should show that Surface.lower debugSurface = debugProgram
#eval Surface.lower debugSurface
#eval debugProgram
