# Formalizing type systems in Lean 4: a practical guide

**A Lean 4 formalization of a simplified Rust trait system is tractable today**, with mature tooling for de Bruijn-based variable binding, inductive typing judgments, and progress/preservation proofs. No Lean 4 formalization of Rust's type system currently exists—this is an open gap—but substantial infrastructure exists in projects like the Metatheory library (10,367 LOC, 497 theorems, zero axioms), PLFaLean, and capless-lean. The recommended architecture: model traits via **dictionary-passing elaboration** (Wadler-Blott style) from a surface language with trait bounds into an explicitly-typed core without traits, then prove type safety on the core. This separates the hard problems (trait resolution and coherence) from standard metatheory (progress/preservation). Below is a concrete, pattern-by-pattern guide.

---

## Name binding: de Bruijn indices dominate Lean 4 PL work

Every major Lean 4 PL formalization uses **de Bruijn indices** or a variant. This isn't accidental—Lean's own kernel represents bound variables as de Bruijn indices (`Expr.bvar : Nat → Expr`), and Lean's elaborator uses locally nameless representation internally. The ecosystem's tooling, tactics, and conventions all align with this choice.

**Pure de Bruijn indices** (used by the Metatheory library, Lean4Lean's specification, PLFaLean) represent variables as natural numbers counting binders:

```lean
inductive Term where
  | var : Nat → Term          -- de Bruijn index
  | app : Term → Term → Term
  | lam : Term → Term         -- no binder name needed
```

Substitution requires shift (lifting) and the actual replacement. The Metatheory library by Ramos et al. (arXiv:2512.09280, December 2025) provides complete, proven infrastructure:

```lean
def shift : Term → Nat → Nat → Term
  | .var v,   n, m => if n <= v then .var (v + m) else .var v
  | .app l r, n, m => .app (shift l n m) (shift r n m)
  | .lam r,   n, m => .lam (shift r (n + 1) m)

def subst : Term → Nat → Term → Term
  | .var v,   n, t => if n < v then .var (v.pred)
                       else if n = v then shift t 0 n
                       else .var v
  | .app l r, n, t => .app (subst l n t) (subst r n t)
  | .lam r,   n, t => .lam (subst r (n + 1) t)
```

The Metatheory library proves **all substitution composition lemmas**—historically the most tedious part of de Bruijn formalizations—in 709 lines, with zero axioms. This is a critical contribution: these lemmas are "notoriously tedious" and often axiomatized in other projects.

**Locally nameless representation** (used by Lean's kernel, Stlc_deBruijn project) uses de Bruijn indices for bound variables and named identifiers for free variables. The Stlc_deBruijn project by Elif Uskuplu (presented at WITS 2025) formalizes STLC confluence and strong normalization using this approach, based on Charguéraud's locally nameless paper. The key technique is **cofinite quantification**: instead of requiring a property for one fresh name, require it for cofinitely many names, which strengthens induction principles.

**Intrinsically-scoped de Bruijn** (used by capless-lean, 14,000+ LOC) parameterizes syntax by exact variable counts, using `Fin n` for variable references:

```lean
-- From capless-lean: terms with n term vars, m type vars, k capture vars
inductive Term (n m k : Nat) where
  | var   : Fin n → Term n m k
  | app   : Term n m k → Term n m k → Term n m k
  | lam   : Term (n+1) m k → Term n m k
  -- ...well-scopedness guaranteed by construction
```

**PHOAS (Parametric Higher-Order Abstract Syntax)** has an official Lean 4 example and avoids substitution lemmas entirely by using Lean's own function space for binding:

```lean
inductive Term' (rep : Ty → Type) : Ty → Type where
  | var : rep ty → Term' rep ty
  | lam : (rep dom → Term' rep ran) → Term' rep (.fn dom ran)
  | app : Term' rep (.fn dom ran) → Term' rep dom → Term' rep ran

def Term (ty : Ty) := {rep : Ty → Type} → Term' rep ty
```

Substitution becomes trivial (`squash` via the identity), and you get different interpretations by instantiating `rep` differently: `Unit` for counting, `String` for printing, `Ty.denote` for evaluation. The tradeoff is that structural induction on terms becomes harder.

**Recommendation for a Rust trait formalization**: Use **pure de Bruijn indices with extrinsic typing**. This is the most battle-tested approach in Lean 4 (Metatheory library provides reusable infrastructure), gives maximum flexibility for defining subtyping and trait resolution as separate relations, and keeps AST definitions simple. If you want stronger static guarantees at the cost of flexibility, intrinsically-scoped de Bruijn (capless-lean style) eliminates well-scopedness obligations but makes term manipulation more complex.

| Approach | Substitution effort | Proof flexibility | Lean 4 maturity |
|---|---|---|---|
| Pure de Bruijn | High (but Metatheory library helps) | Maximum | Very high |
| Locally nameless | Medium | High | Moderate |
| Intrinsically-scoped | Low (by construction) | Medium | High (capless-lean) |
| PHOAS | None | Low (induction is hard) | Official example exists |

---

## AST design: extrinsic typing gives the most flexibility for trait modeling

Two main schools exist in Lean 4: **extrinsic typing** (raw terms + separate typing relation) and **intrinsic typing** (terms indexed by their type). For a Rust trait formalization, extrinsic typing is strongly preferred because you need the flexibility to define multiple relations (typing, subtyping, trait resolution, coherence) over the same term structure.

**Extrinsic approach** (standard for metatheory proofs):

```lean
-- Object-language types
inductive Ty where
  | nat : Ty
  | fn  : Ty → Ty → Ty
  | tvar : Nat → Ty           -- type variables for polymorphism

-- Expressions (Church-style: type annotations on binders)
inductive Expr where
  | var   : Nat → Expr
  | lam   : Ty → Expr → Expr  -- λ(x:τ). e
  | app   : Expr → Expr → Expr
  | tlam  : Expr → Expr       -- Λα. e (type abstraction for System F)
  | tapp  : Expr → Ty → Expr  -- e [τ] (type application)
```

For a language with traits, you would extend this with trait-specific constructs:

```lean
inductive Expr where
  | var     : Nat → Expr
  | lam     : Ty → Expr → Expr
  | app     : Expr → Expr → Expr
  | tlam    : TraitBound → Expr → Expr   -- Λ(α: Bound). e
  | tapp    : Expr → Ty → Expr
  | methCall : Expr → Name → List Expr → Expr  -- e.method(args)
```

**Intrinsic approach** (well-typed by construction):

```lean
-- Terms indexed by context and type
inductive Term : List Ty → Ty → Type where
  | var : Member ty ctx → Term ctx ty
  | lam : Term (a :: ctx) b → Term ctx (.fn a b)
  | app : Term ctx (.fn a b) → Term ctx a → Term ctx b
```

The official Lean 4 well-typed interpreter example uses this with `Vec Ty n` contexts and `HasType` membership proofs as de Bruijn indices. **Type preservation is free**—ill-typed terms are unrepresentable—but defining trait resolution or subtyping as separate relations over intrinsically typed terms is awkward.

**Mutual inductive types** work in Lean 4 but have constraints: all types in a mutual block must share the same universe parameters. For separating expressions and values:

```lean
mutual
  inductive Expr where
    | var : Nat → Expr
    | app : Expr → Expr → Expr
    | lam : Ty → Expr → Expr
  inductive Val where
    | closure : List Val → Expr → Val  -- environment + body
    | nat : Nat → Val
end
```

**Lean 4 limitation**: inductive types cannot be extended with `extends`. If you want to add constructs, you must redefine the full type. Plan your AST carefully upfront, or use a modular design with a base expression type and an extension mechanism (though this adds complexity).

---

## Typing judgments map directly to inductive propositions

Standard on-paper inference rules translate cleanly into Lean 4 `inductive` types in `Prop`. Each rule becomes a constructor, each premise becomes a constructor argument, and the conclusion becomes the constructor's result type. With custom notation, the Lean code can closely mirror paper presentations.

**Typing contexts** are most commonly represented as lists (for de Bruijn) or partial functions (for named variables):

```lean
-- List-based context (de Bruijn): lookup by position
abbrev Ctx := List Ty

inductive Lookup : Ctx → Nat → Ty → Prop where
  | here  : Lookup (τ :: Γ) 0 τ
  | there : Lookup Γ n τ → Lookup (τ' :: Γ) (n + 1) τ

-- Partial-function context (named): lookup by name
abbrev Ctx := String →. Ty   -- Lean 4's partial function type

def Ctx.update (Γ : Ctx) (x : String) (τ : Ty) : Ctx :=
  fun s => if s = x then pure τ else Γ s
```

**The typing judgment itself** as an inductive proposition:

```lean
inductive HasType : Ctx → Expr → Ty → Prop where
  | var : Lookup Γ n τ →
    HasType Γ (.var n) τ
  | lam : HasType (σ :: Γ) e τ →
    HasType Γ (.lam σ e) (.fn σ τ)
  | app : HasType Γ f (.fn σ τ) → HasType Γ a σ →
    HasType Γ (.app f a) τ
```

**Custom notation** makes judgments readable—this is a Lean 4 strength:

```lean
notation:50 Γ " ⊢ " e " : " τ => HasType Γ e τ
notation:50 e " ⟶ " e'       => Step e e'
notation:50 e " ⟶* " e'      => ReflTransGen Step e e'
notation:60 "[" x " ↦ " s "]" t:61 => subst x s t
```

For a trait system, you would add judgments for trait satisfaction and subtyping:

```lean
-- Trait environment: which impls exist
structure TraitEnv where
  impls : List ImplDecl

-- Trait satisfaction: T implements Trait
inductive Implements : TraitEnv → Ty → TraitId → Prop where
  | direct : ImplFor τ trait ∈ Δ.impls →
    Implements Δ τ trait
  | blanket : ImplForAll bound trait ∈ Δ.impls →
    Implements Δ τ bound →
    Implements Δ τ trait

-- Typing with trait bounds
inductive HasType : TraitEnv → Ctx → Expr → Ty → Prop where
  | var : Lookup Γ n τ →
    HasType Δ Γ (.var n) τ
  | traitMethod : Implements Δ τ trait →
    MethodSig trait meth σ →
    HasType Δ Γ (.methCall e meth args) σ
  -- ...
```

A visual convention used in the Aalto STLC formalization places dashes as comment lines between premises and conclusions, mimicking inference rule lines:

```lean
inductive HasType : Ctx → Term → Ty → Prop where
  | Abs : ∀ Γ x T₁ T₂ t₁,
    HasType (Γ.update x T₁) t₁ T₂ →
    --------------------------------------
    HasType Γ (Abs x T₁ t₁) (.Arrow T₁ T₂)
```

---

## Operational semantics and soundness proofs follow a standard template

### Small-step semantics

Define values, then a step relation as an inductive type:

```lean
inductive Value : Expr → Prop where
  | lam : Value (.lam τ body)
  | nat : Value (.nat n)

inductive Step : Expr → Expr → Prop where
  | beta : Value v →
    Step (.app (.lam τ body) v) (subst 0 v body)
  | appL : Step e₁ e₁' →
    Step (.app e₁ e₂) (.app e₁' e₂)
  | appR : Value v₁ → Step e₂ e₂' →
    Step (.app v₁ e₂) (.app v₁ e₂')
```

The **reflexive transitive closure** can use Mathlib's `Relation.ReflTransGen` or a custom inductive:

```lean
inductive MultiStep : Expr → Expr → Prop where
  | refl : MultiStep e e
  | step : Step e e' → MultiStep e' e'' → MultiStep e e''

-- Register with Lean's calc infrastructure
@[refl] lemma multi_refl : MultiStep e e := .refl
@[trans] lemma multi_trans : MultiStep a b → MultiStep b c → MultiStep a c := by
  intro h₁ h₂; induction h₁ with
  | refl => exact h₂
  | step hs _ ih => exact .step hs (ih h₂)
```

### Progress and preservation

**Canonical forms** (helper lemma):

```lean
theorem canonical_fn {v τ₁ τ₂} (hty : HasType [] v (.fn τ₁ τ₂)) (hv : Value v) :
    ∃ body, v = .lam τ₁ body := by
  cases hv <;> cases hty
  exact ⟨_, rfl⟩
```

**Progress** (well-typed closed terms are values or can step):

```lean
theorem progress {e τ} (h : HasType [] e τ) : Value e ∨ ∃ e', Step e e' := by
  induction h with
  | var hlookup => exact absurd hlookup (by intro h; cases h)
  | lam _ => exact Or.inl .lam
  | app hf ha ihf iha =>
    right
    rcases ihf with hv₁ | ⟨e₁', he₁'⟩
    · rcases iha with hv₂ | ⟨e₂', he₂'⟩
      · obtain ⟨body, rfl⟩ := canonical_fn hf hv₁
        exact ⟨_, .beta hv₂⟩
      · exact ⟨_, .appR hv₁ he₂'⟩
    · exact ⟨_, .appL he₁'⟩
```

**Preservation** (typing is preserved by reduction—requires the substitution lemma):

```lean
theorem substitution_lemma :
    HasType (σ :: Γ) e τ → HasType Γ v σ → HasType Γ (subst 0 v e) τ := by
  intro hty hv
  induction hty generalizing Γ with  -- CRITICAL: generalizing Γ
  | var hlookup => ...
  | lam _ ih => ...
  | app _ _ ihf iha => exact .app (ihf hv) (iha hv)

theorem preservation {e e' τ} (hty : HasType [] e τ) (hs : Step e e') :
    HasType [] e' τ := by
  induction hs generalizing τ with
  | beta hval =>
    cases hty with
    | app hfn harg => cases hfn with
      | lam hbody => exact substitution_lemma hbody harg
  | appL _ ih =>
    cases hty with | app hf ha => exact .app (ih hf) ha
  | appR _ _ ih =>
    cases hty with | app hf ha => exact .app hf (ih ha)
```

**Type safety** as a corollary:

```lean
theorem type_safety {e e' τ} (hty : HasType [] e τ) (hsteps : MultiStep e e') :
    Value e' ∨ ∃ e'', Step e' e'' := by
  induction hsteps with
  | refl => exact progress hty
  | step hs _ ih => exact ih (preservation hty hs)
```

### Common pitfalls

The **substitution lemma** is the hardest proof. With de Bruijn indices it requires tedious shifting lemmas; budget 500–700 lines for the full infrastructure (the Metatheory library's benchmark). The critical tactic pattern is `induction h generalizing Γ`—without `generalizing`, the induction hypothesis loses necessary generality and becomes unprovable. Another pitfall: **weakening** must be proved before preservation, and requires its own induction with shifting. Finally, for the intrinsic approach, pattern matching on indexed families generates complex goals with equalities between indices—Lean 4 handles this better than Coq (native dependent pattern matching), but it can still be surprising.

---

## Existing projects and what to learn from each

### Lean 4 formalizations

**Metatheory library** (github.com/arthuraa/metatheory) — The most mature Lean 4 PL framework. **10,367 LOC, 497 theorems, 0 axioms, 0 sorry**. Covers untyped λ-calculus, STLC, STLC+products+sums, combinatory logic, abstract rewriting. Provides three mechanized confluence proof techniques (diamond property via parallel reduction, Newman's lemma, Hindley-Rosen). Proves strong normalization via logical relations. **Most importantly, provides complete de Bruijn substitution infrastructure** that can be reused. Uses Lean 4.

**capless-lean** (github.com/Linyxus/capless-lean) — Complete mechanization of System Capless (capture types + scoped capabilities). **14,000+ LOC**, intrinsically-scoped de Bruijn with three variable sorts. Demonstrates that large-scale type soundness proofs are feasible in Lean 4. Uses `Fin n` indices and Mathlib's `aesop` for automation. Also served as the case study for LLM-assisted proof automation (arXiv:2601.03768), achieving **87% success** on 189 proof tasks.

**PLFaLean** (github.com/rami3l/PLFaLean) — Port of Programming Language Foundations in Agda (Parts 2–3) to Lean 4. Covers STLC properties, intrinsically-typed de Bruijn, bidirectional inference, untyped λ-calculus, confluence, big-step semantics, denotational semantics. Excellent learning resource.

**PLFL** (github.com/plfa/plfl) — The official Lean 4 companion to PLFA, by Philip Wadler himself. Under active development. Uses the verso documentation framework.

**Lean4Lean** (github.com/digama0/lean4lean, arXiv:2403.14064) — Mario Carneiro's formalization of Lean's own type theory. A complete executable typechecker (20–50% slower than C++) that can verify all of Mathlib. Uses pure de Bruijn for specification, locally nameless for implementation. Metatheory proofs (regularity, kernel correctness) are ongoing.

**Stlc_deBruijn** (github.com/ElifUskuplu/Stlc_deBruijn) — STLC with locally nameless in Lean 4. Proves confluence and strong normalization. Uses cofinite quantification. Presented at WITS 2025.

### Rust-specific formalizations (not in Lean 4)

**No Lean 4 formalization of Rust's type system exists.** This is a genuine gap.

**RustBelt** (Coq/Iris, POPL 2018, plv.mpi-sws.org/rustbelt/) uses semantic type safety via logical relations in Iris separation logic. Types are interpreted as ownership predicates. Models λRust (a CPS-style language close to MIR). Verifies unsafe library APIs (Arc, Mutex, Cell, etc.). **Does not model the trait system syntactically**—Send/Sync are modeled as properties of ownership predicates. Lesson: separation logic works beautifully for memory safety but is overkill for trait system modeling.

**Oxide** (arXiv:1903.00982, github.com/aatxe/oxide) provides the first syntactic type safety proof for Rust's borrow checker. Models lifetimes as sets of locations ("regions"). Uses flow-sensitive substructural typing. **Explicitly omits traits**, noting they are "largely described in the literature on typeclasses." Lesson: ownership/borrowing and traits are orthogonal and can be formalized separately.

**MiniRust** by Jonatan Milewski (UBC thesis, 2015) is **the most directly relevant prior work** for trait formalization. It models trait declarations, impl blocks, associated types, trait objects, supertraits, and object safety. Uses **dictionary-passing elaboration** from a surface language (MiniRust) to an explicitly-typed internal language (RustIn). Proves type safety for RustIn and shows well-typed MiniRust programs elaborate to well-typed RustIn programs. **Explicitly omits lifetimes** to focus on traits.

**a-mir-formality** (github.com/rust-lang/a-mir-formality) and the now-sunset **Chalk** (github.com/rust-lang/chalk) are the official Rust project's efforts toward formal modeling of trait resolution and type relations. They provide useful context on how the Rust project itself thinks about these problems, though your formalization may take a different approach.

---

## Lean 4 tactics and techniques for PL metatheory

### Essential tactics

The single most important pattern is **`induction h generalizing x y z`**. Without `generalizing`, Lean fixes variables that should vary across induction cases, making hypotheses too specific. This is the #1 source of frustration for newcomers:

```lean
-- WRONG: loses generality
theorem preservation (hty : HasType [] e τ) (hs : Step e e') : HasType [] e' τ := by
  induction hs  -- τ is fixed; induction hypotheses are too weak

-- CORRECT: generalize τ
theorem preservation (hty : HasType [] e τ) (hs : Step e e') : HasType [] e' τ := by
  induction hs generalizing τ  -- τ varies across cases
```

Other critical tactics for PL proofs:

- **`cases h`** — Inversion on inductive hypotheses. Handles what Coq needs `inversion`/`destruct` for. Essential for canonical forms and rule inversion.
- **`rcases h with ⟨x, y, rfl⟩`** — Recursive case splitting with pattern destructuring. Indispensable for existentials from progress proofs.
- **`obtain ⟨x, hx⟩ := h`** — Combines `have` and `rcases`. Cleaner for single-use destructuring.
- **`simp [f₁, f₂, *]`** — Equational simplification. Use `@[simp]` to tag definitional equalities about substitution, lookup, etc. Use `simp only [...]` for predictability.
- **`omega`** — Decision procedure for linear arithmetic over `Nat`/`Int`. Invaluable for de Bruijn index arithmetic.
- **`<;>`** — Apply a tactic to all generated subgoals. For instance `cases hty <;> cases hval <;> rfl` for canonical forms.
- **`nomatch h`** — Eliminates impossible cases when no constructor matches. Cleaner than `contradiction` for empty pattern matches.
- **`aesop`** — Best-first proof search. Register typing rules with `@[aesop safe constructors]` and lemmas with `@[aesop safe apply]` for automated proof search. The capless-lean project uses aesop extensively.
- **`grind`** (Lean 4.15+) — New SMT-like tactic handling pattern matching, case analysis, and linear arithmetic simultaneously.

### Functional induction

Since Lean 4.8, recursive functions automatically generate `.induct` principles matching their recursion structure:

```lean
-- Lean generates subst.induct automatically
theorem subst_id (e : Expr) : subst x (.var x) e = e := by
  induction e using subst.induct (x := x) (v := .var x) <;> simp_all [subst]
```

### simp lemma management

Tag substitution and lookup equalities as `@[simp]` for automation:

```lean
@[simp] theorem subst_var_eq  : subst x v (.var x) = v := by simp [subst]
@[simp] theorem subst_var_neq (h : x ≠ y) : subst x v (.var y) = .var y := by simp [subst, h]
@[simp] theorem lookup_here   : Lookup (τ :: Γ) 0 τ := .here
```

### Decidable instances

Derive `DecidableEq` for your types to enable `decide` on concrete examples and `if` expressions:

```lean
inductive Ty where | nat | fn : Ty → Ty → Ty
  deriving DecidableEq, Repr
```

### Custom notation for DSLs

Lean 4's macro system enables custom syntax categories:

```lean
declare_syntax_cat myexpr
syntax num : myexpr
syntax "λ" ident ":" ident "." myexpr : myexpr
syntax myexpr myexpr : myexpr
syntax "`[expr| " myexpr "]" : term

macro_rules
  | `(`[expr| $n:num]) => `(Expr.nat $n)
  | `(`[expr| λ $x : $τ . $body]) => `(Expr.lam $(quote (toString x.getId)) ... )
```

### Key differences from Coq

- **Prop is proof-irrelevant** in Lean (like SProp in Coq). You cannot extract computational content from `Prop` proofs.
- **No universe cumulativity**. Use `Sort u` for universe-polymorphic definitions.
- **No Ltac**. Lean 4 tactics are written in Lean itself (MetaM monad)—more powerful but different.
- **`cases` replaces `inversion`**. Lean's `cases` performs inversion automatically; no separate tactic needed.
- **No `auto`**. Use `aesop` (similar to Isabelle's `auto`).
- **Mutual inductives**: natively supported in the kernel, but mutual induction principles and structural recursion support are still maturing. Consider the MutualInduction tactic (github.com/ionathanch/MutualInduction) for complex cases.
- **Termination**: all functions must terminate. Use `termination_by` for explicit measures, fuel-based approaches for interpreters, or define semantics as inductive propositions (no termination obligation).

### Recommended project structure

```
RustTraits/
├── lakefile.lean
├── lean-toolchain
├── RustTraits/
│   ├── Syntax.lean          -- AST: Expr, Ty, TraitDecl, ImplDecl
│   ├── DeBruijn.lean        -- Shift, substitution, de Bruijn infrastructure
│   ├── Context.lean         -- Typing contexts, trait environments
│   ├── Typing.lean          -- Typing judgment (HasType)
│   ├── Traits/
│   │   ├── Resolution.lean  -- Trait resolution rules
│   │   ├── Coherence.lean   -- Coherence/non-overlap
│   │   └── Elaboration.lean -- Dictionary-passing translation
│   ├── Semantics.lean       -- Small-step operational semantics
│   ├── Properties/
│   │   ├── Substitution.lean
│   │   ├── Weakening.lean
│   │   ├── Progress.lean
│   │   ├── Preservation.lean
│   │   └── Safety.lean
│   └── Tactics.lean         -- Custom automation
└── RustTraits.lean          -- Root import
```

---

## Modeling Rust's trait system: dictionary passing is the proven approach

### The architecture

The most successful formal models of type class / trait systems all use the same fundamental idea: **elaboration via dictionary passing** (Wadler and Blott, 1989). The surface language has constrained polymorphism (`T: Trait`); the internal language has explicit dictionary arguments. Type safety is proved on the internal language; the elaboration is proved to preserve well-typedness.

For Rust specifically, this means:

```
Surface language (with traits)     →     Core language (System F + records)
fn foo<T: Display>(x: T)          →     fn foo<T>(dict: DisplayDict<T>, x: T)
trait Display { fn fmt(&self); }   →     struct DisplayDict<T> { fmt: T → String }
impl Display for i32 { ... }       →     let i32DisplayDict = DisplayDict { fmt = ... }
```

In Lean 4, the surface language typing judgment would include trait bound checking:

```lean
-- Surface: trait-aware typing
inductive SHasType : TraitEnv → Ctx → SExpr → Ty → Prop where
  | traitFn : 
    SHasType Δ ((bound, α) :: Γ) body τ →
    ---
    SHasType Δ Γ (.traitFn bound body) (.boundedForall bound τ)
  | traitCall :
    SHasType Δ Γ f (.boundedForall bound τ) →
    Implements Δ σ bound →
    ---
    SHasType Δ Γ (.traitApp f σ) (substTy α σ τ)
```

And the elaboration maps this to a core language:

```lean
-- Core: no traits, explicit dictionaries
inductive CHasType : Ctx → CExpr → Ty → Prop where
  | dictFn :
    CHasType ((dictTy bound) :: Γ) body τ →
    ---
    CHasType Γ (.lam (dictTy bound) body) (.fn (dictTy bound) τ)
  | dictApp :
    CHasType Γ f (.fn (dictTy bound) τ) →
    CHasType Γ dict (dictTy bound) →
    ---
    CHasType Γ (.app f dict) τ
```

### What to model first

Based on Milewski's MiniRust thesis and the broader literature, prioritize these features for a first formalization:

- **Trait declarations with methods**: `trait Foo { fn bar(self) -> T; }`
- **Impl blocks**: `impl Foo for MyType { ... }`
- **Trait bounds**: `fn f<T: Foo>(x: T)` — constrained polymorphism
- **Associated types**: `trait Iterator { type Item; }` — type-level functions determined by impl
- **Coherence**: at most one impl per type per trait (global uniqueness)

Safely defer these to later iterations: lifetimes/borrowing (orthogonal—Oxide proves this), unsafe code, GATs, specialization, auto traits, default method implementations (syntactic sugar), const generics, full orphan rules (start single-crate).

### Coherence modeling

In a single-crate model, coherence reduces to checking that no two impl blocks overlap for the same trait. The Rust rules are: no overlapping impls (without specialization), and orphan rules constrain which crate can define an impl. For a first model, represent the program's complete set of impls and check non-overlap as a well-formedness condition:

```lean
def Coherent (Δ : TraitEnv) : Prop :=
  ∀ τ trait, ∀ i₁ i₂ ∈ Δ.implsFor trait,
    i₁.appliesTo τ → i₂.appliesTo τ → i₁ = i₂
```

For formal coherence proofs of elaboration (different elaboration paths produce equivalent programs), see Bottu et al. (ICFP 2019, "Coherence of Type Class Resolution") which proves coherence via logical relations, and COCHIS (Schrijvers et al., JFP 2019) which provides a general framework covering Rust traits explicitly.

### Associated types as type-level functions

Model associated types as components of the trait dictionary that the trait resolution must determine:

```lean
structure TraitImpl where
  traitId   : TraitId
  selfType  : Ty
  assocTypes : List (Name × Ty)  -- associated type assignments
  methods   : List (Name × Expr) -- method implementations

-- Resolution must determine associated types
inductive Resolves : TraitEnv → Ty → TraitId → TraitImpl → Prop where
  | found : impl ∈ Δ.impls → impl.traitId = trait → impl.selfType = τ →
    Resolves Δ τ trait impl
```

### Key properties to prove

The fundamental theorem you want is **soundness of elaboration**: if a surface program is well-typed (with trait bounds checked) and the trait environment is coherent, then the elaborated program (with explicit dictionaries) is well-typed in the core language. Type safety (progress + preservation) for the core language then follows from standard techniques. Additionally, prove **coherence**: under non-overlap, all valid elaborations produce equivalent programs (contextual equivalence).

---

## References and further reading

### Lean 4 PL formalization projects (dig into these first)

- **Metatheory library** (de Bruijn infrastructure, STLC, confluence, strong normalization — 10K+ LOC, 0 sorry):
  [github.com/arthuraa/metatheory](https://github.com/arthuraa/metatheory)
  Paper: [arXiv:2512.09280](https://arxiv.org/abs/2512.09280) — "A Modular Lean 4 Framework for Confluence and Strong Normalization"

- **capless-lean** (System Capless soundness — intrinsically-scoped de Bruijn, 14K+ LOC):
  [github.com/Linyxus/capless-lean](https://github.com/linyxus/capless-lean)
  LLM-assisted proof study: [arXiv:2601.03768](https://arxiv.org/abs/2601.03768) — "Agentic Proof Automation: A Case Study"

- **PLFaLean** (PLFA Parts 2–3 ported to Lean 4 — STLC, de Bruijn, bidirectional typing, denotational semantics):
  [github.com/rami3l/PLFaLean](https://github.com/rami3l/PLFaLean)

- **PLFL** (official Programming Language Foundations in Lean, by Philip Wadler):
  [github.com/plfa/plfl](https://github.com/plfa/plfl)

- **Lean4Lean** (Lean's own type theory verified in Lean — de Bruijn spec, locally nameless impl):
  [github.com/digama0/lean4lean](https://github.com/digama0/lean4lean)
  Paper: [arXiv:2403.14064](https://arxiv.org/abs/2403.14064) — "Lean4Lean: Verifying a Typechecker for Lean, in Lean"

- **Stlc_deBruijn** (STLC with locally nameless + cofinite quantification in Lean 4):
  [github.com/ElifUskuplu/Stlc_deBruijn](https://github.com/ElifUskuplu/Stlc_deBruijn)
  Talk: [WITS 2025 at POPL](https://popl25.sigplan.org/details/wits-2025-papers/1/Formalizing-locally-nameless-syntax-with-cofinite-quantification)

- **PHOAS in Lean 4** (official example — parametric higher-order abstract syntax):
  [leanprover.cn/lean4/examples/phoas.lean.html](http://www.leanprover.cn/lean4/examples/phoas.lean.html)

- **Well-typed interpreter** (official Lean 4 example — intrinsically typed de Bruijn):
  [lean-lang.org/documentation/examples/interp/](https://lean-lang.org/documentation/examples/interp/)

### Rust-specific formalizations

- **RustBelt** (semantic type safety via Iris separation logic, Coq — the gold standard for unsafe Rust verification):
  [plv.mpi-sws.org/rustbelt](https://plv.mpi-sws.org/rustbelt/)
  Paper: [doi.org/10.1145/3158154](https://dl.acm.org/doi/10.1145/3158154) — POPL 2018

- **Oxide** (syntactic ownership/borrowing type safety — explicitly defers traits):
  [github.com/aatxe/oxide](https://github.com/aatxe/oxide)
  Paper: [arXiv:1903.00982](https://arxiv.org/abs/1903.00982) — "Oxide: The Essence of Rust"

- **a-mir-formality** and **Chalk** (official Rust project trait resolution models — useful background):
  [github.com/rust-lang/a-mir-formality](https://github.com/rust-lang/a-mir-formality) ·
  [github.com/rust-lang/chalk](https://github.com/rust-lang/chalk/blob/master/README.md)

- **Rust types team announcement** (context on formalization goals):
  [blog.rust-lang.org/2023/01/20/types-announcement](https://blog.rust-lang.org/2023/01/20/types-announcement/)

- **MiniRust by Milewski** (UBC 2015 thesis — most relevant prior work for trait dictionary-passing elaboration):
  Search: "Jonatan Milewski MiniRust UBC thesis 2015" — models trait declarations, impls, associated types, trait objects, supertraits via elaboration to System F-like core

### Type class / trait formalization theory

- **Wadler & Blott 1989** — "How to make ad-hoc polymorphism less ad hoc" (original dictionary-passing translation)
- **Bottu et al., ICFP 2019** — "Coherence of Type Class Resolution" (coherence proof via logical relations)
- **Schrijvers et al., JFP 2019** — "COCHIS: Stable and coherent implicits" (general coherence framework, covers Rust traits)
- **Charguéraud, JFP 2012** — "The Locally Nameless Representation" (the standard locally-nameless reference, used by Stlc_deBruijn)

### Lean 4 learning and reference

- **Lean 4 reference manual — expressions and inductive types**:
  [leanprover.github.io/reference/expressions.html](https://leanprover.github.io/reference/expressions.html)

- **Type checking in Lean 4** (inductive types deep dive):
  [ammkrn.github.io/type_checking_in_lean4/declarations/inductive.html](https://ammkrn.github.io/type_checking_in_lean4/declarations/inductive.html)

- **Learning Lean 4** (community resource index):
  [leanprover-community.github.io/learn.html](https://leanprover-community.github.io/learn.html)

- **Lean.Expr documentation** (Lean's own de Bruijn-based expression type):
  [leanprover-community.github.io/mathlib4_docs/Lean/Expr.html](https://leanprover-community.github.io/mathlib4_docs/Lean/Expr.html)

- **Extending inductive types in Lean 4** (design patterns and limitations):
  [jamesoswald.dev/posts/meditation-extending-inductive-types](https://jamesoswald.dev/posts/meditation-extending-inductive-types/)

- **Functions and inductive propositions in Lean 4**:
  [brandonrozek.com/blog/functions-inductive-propositions-lean4](https://brandonrozek.com/blog/functions-inductive-propositions-lean4/)

- **Operational semantics in Lean** (lecture notes):
  [lean-forward.github.io/logical-verification/2018/31_notes.html](https://lean-forward.github.io/logical-verification/2018/31_notes.html)

- **Software Foundations — STLC Properties** (Coq, but the proof structure transfers directly):
  [softwarefoundations.cis.upenn.edu/plf-current/StlcProp.html](https://softwarefoundations.cis.upenn.edu/plf-current/StlcProp.html)

- **MutualInduction tactic** (for complex mutual inductive types):
  [github.com/ionathanch/MutualInduction](https://github.com/ionathanch/MutualInduction)

---

## Conclusion

The Lean 4 ecosystem is ready for serious PL formalization work. The Metatheory library provides battle-tested de Bruijn infrastructure, capless-lean demonstrates that 14,000+ LOC type soundness proofs are feasible, and PLFaLean/PLFL offer pedagogical foundations. For a Rust trait formalization specifically, the path is clear: use extrinsic typing with de Bruijn indices, model traits via dictionary-passing elaboration following Milewski's MiniRust architecture, prove type safety on the elaborated core language, and prove elaboration soundness and coherence separately. Start with single-parameter traits, explicit type annotations (Church-style), and a single-crate coherence model. The tactic `induction h generalizing τ` will be your most-used proof step; `aesop` with registered typing rules will handle routine cases; and `omega` will save you from de Bruijn index arithmetic. The biggest time investment will be the substitution lemma infrastructure—consider reusing or adapting the Metatheory library's proven 709-line substitution package rather than building from scratch.
