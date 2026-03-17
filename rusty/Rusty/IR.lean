/-
  Rusty IR — Internal representation with de Bruijn indices

  This is the core formalization layer. Type variables use de Bruijn indices
  (natural numbers) rather than names. Global names (structs, traits, functions)
  remain as strings.

  The surface syntax (Surface.lean) provides a named-variable layer for
  readability, with a lowering function to translate into this IR.
-/

-- ANCHOR: Ty
/-- A type in Rusty. Type variables use de Bruijn indices. -/
inductive Ty where
  /-- A bound type variable, represented as a de Bruijn index. -/
  | bvar : Nat → Ty
  /-- A struct type with type arguments: `S⟨τ₀, ..., τₙ⟩` -/
  | struct : String → List Ty → Ty
  /-- An error type, produced by lowering when a type parameter name is unresolved.
      No inference rule ever matches this, so proofs involving it are impossible. -/
  | error : Ty
  deriving Repr
-- ANCHOR_END: Ty

-- ANCHOR: WhereClause
/-- A where clause `τ: T` — the type `τ` implements trait `T`. -/
structure WhereClause where
  ty : Ty
  trait : String
  deriving Repr
-- ANCHOR_END: WhereClause

-- ANCHOR: Stmt
/-- A statement in a function body. -/
inductive Stmt where
  /-- A function call with explicit type arguments: `f⟨τ̄⟩()` -/
  | call : String → List Ty → Stmt
  /-- A trait assertion: `assert_impl!(τ: T)` -/
  | assertImpl : Ty → String → Stmt
  deriving Repr
-- ANCHOR_END: Stmt

-- ANCHOR: ImplDef
/-- A trait implementation: `impl⟨X₀, ..., Xₙ⟩ T for τ where W̄ {}`
    Type parameters are represented by their count (`arity`);
    the impl body uses `bvar 0` through `bvar (arity - 1)`. -/
structure ImplDef where
  arity : Nat
  trait : String
  implTy : Ty
  whereClauses : List WhereClause
  deriving Repr
-- ANCHOR_END: ImplDef

-- ANCHOR: FuncDef
/-- A function definition: `fn f⟨X₀, ..., Xₙ⟩() where W̄ { s̄ }` -/
structure FuncDef where
  name : String
  arity : Nat
  whereClauses : List WhereClause
  body : List Stmt
  deriving Repr
-- ANCHOR_END: FuncDef

-- ANCHOR: Program
/-- A Rusty program: a collection of impl declarations and function definitions. -/
structure Program where
  impls : List ImplDef
  funcs : List FuncDef
  deriving Repr
-- ANCHOR_END: Program

/-!
## Substitution

A substitution is a list of types, where position `i` maps `bvar i` to the
corresponding type. Out-of-range indices are left unchanged (identity substitution).

We use `mutual` to handle recursion into `List Ty` — this avoids the termination
issue that the previous Lean code encountered with `List.map`.
-/

-- ANCHOR: Subst
/-- A substitution: `s[i]` replaces `bvar i` with the type at position `i`. -/
abbrev Subst := List Ty

mutual
  /-- Apply a substitution to a type. -/
  def applySubst (s : Subst) : Ty → Ty
    | .bvar n => s.getD n (.bvar n)
    | .struct name args => .struct name (applySubstList s args)
    | .error => .error

  /-- Apply a substitution to a list of types. -/
  def applySubstList (s : Subst) : List Ty → List Ty
    | [] => []
    | t :: ts => applySubst s t :: applySubstList s ts
end

/-- Apply a substitution to a where clause. -/
def applySubstWC (s : Subst) (wc : WhereClause) : WhereClause :=
  ⟨applySubst s wc.ty, wc.trait⟩

/-- Apply a substitution to a statement. -/
def applySubstStmt (s : Subst) : Stmt → Stmt
  | .call f args => .call f (applySubstList s args)
  | .assertImpl ty trait => .assertImpl (applySubst s ty) trait
-- ANCHOR_END: Subst

/-!
## Substitution smoke tests
-/

-- bvar 0 with substitution [String] should give String
#eval applySubst [Ty.struct "String" []] (.bvar 0)

-- struct "Vec" [bvar 0] with [String] should give struct "Vec" [struct "String" []]
#eval applySubst [Ty.struct "String" []] (.struct "Vec" [.bvar 0])

-- bvar 1 with [String] should be unchanged (out of range → identity)
#eval applySubst [Ty.struct "String" []] (.bvar 1)
