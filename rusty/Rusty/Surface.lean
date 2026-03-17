/-
  Surface syntax — Named variables for readability

  This module provides a surface syntax that uses string names for type
  parameters, matching the mdBook notation. A `lower` function translates
  surface programs into the de Bruijn IR.

  The lowering is a convenience for writing examples. If the lowering
  produces incorrect de Bruijn indices, proof terms on the IR side
  simply won't type-check — the right failure mode.
-/
import Rusty.IR

namespace Surface

-- ANCHOR: Surface
/-- A surface type with named type parameters. -/
inductive Ty where
  /-- A named type parameter, e.g., `T` -/
  | param : String → Ty
  /-- A struct type with type arguments: `S⟨τ̄⟩` -/
  | struct : String → List Ty → Ty
  deriving Repr

/-- A surface where clause: `τ: T` -/
structure WhereClause where
  ty : Ty
  trait : String
  deriving Repr

/-- A surface statement in a function body. -/
inductive Stmt where
  /-- A function call: `f⟨τ̄⟩()` -/
  | call : String → List Ty → Stmt
  /-- A trait assertion: `assert_impl!(τ: T)` -/
  | assertImpl : Ty → String → Stmt
  deriving Repr

/-- A surface impl definition with named type parameters. -/
structure ImplDef where
  tyParams : List String
  trait : String
  implTy : Ty
  whereClauses : List WhereClause
  deriving Repr

/-- A surface function definition with named type parameters. -/
structure FuncDef where
  name : String
  tyParams : List String
  whereClauses : List WhereClause
  body : List Stmt
  deriving Repr

/-- A surface program. -/
structure Program where
  impls : List ImplDef
  funcs : List FuncDef
  deriving Repr
-- ANCHOR_END: Surface

/-!
## Lowering to IR

Convert named type parameters to de Bruijn indices. The `params` list
gives the binding order: `params[0]` becomes `bvar 0`, etc.
-/

-- ANCHOR: Lower
/-- Find the index of an element in a list, or `none` if not found. -/
def findIndex? [DecidableEq α] (xs : List α) (x : α) : Option Nat :=
  go xs 0
where
  go : List α → Nat → Option Nat
    | [], _ => none
    | y :: ys, i => if y == x then some i else go ys (i + 1)

mutual
  /-- Lower a surface type to the IR, resolving named params to de Bruijn indices. -/
  def lowerTy (params : List String) : Surface.Ty → _root_.Ty
    | .param x =>
      match findIndex? params x with
      | some i => .bvar i
      | none => .error
    | .struct name args => .struct name (lowerTyList params args)

  /-- Lower a list of surface types. -/
  def lowerTyList (params : List String) : List Surface.Ty → List _root_.Ty
    | [] => []
    | t :: ts => lowerTy params t :: lowerTyList params ts
end

/-- Lower a surface where clause. -/
def lowerWC (params : List String) (wc : Surface.WhereClause) : _root_.WhereClause :=
  ⟨lowerTy params wc.ty, wc.trait⟩

/-- Lower a surface statement. -/
def lowerStmt (params : List String) : Surface.Stmt → _root_.Stmt
  | .call f args => .call f (lowerTyList params args)
  | .assertImpl ty trait => .assertImpl (lowerTy params ty) trait

/-- Lower a surface impl definition. -/
def lowerImplDef (impl : Surface.ImplDef) : _root_.ImplDef :=
  { arity := impl.tyParams.length
    trait := impl.trait
    implTy := lowerTy impl.tyParams impl.implTy
    whereClauses := impl.whereClauses.map (lowerWC impl.tyParams) }

/-- Lower a surface function definition. -/
def lowerFuncDef (func : Surface.FuncDef) : _root_.FuncDef :=
  { name := func.name
    arity := func.tyParams.length
    whereClauses := func.whereClauses.map (lowerWC func.tyParams)
    body := func.body.map (lowerStmt func.tyParams) }

/-- Lower a surface program to the IR. -/
def lower (prog : Surface.Program) : _root_.Program :=
  { impls := prog.impls.map lowerImplDef
    funcs := prog.funcs.map lowerFuncDef }
-- ANCHOR_END: Lower

end Surface

/-!
## Lowering smoke test
-/

-- Lower `impl<T> Debug for Vec<T> where T: Debug`
-- Should produce: arity=1, implTy=struct "Vec" [bvar 0], wc=[⟨bvar 0, "Debug"⟩]
#eval Surface.lowerImplDef {
  tyParams := ["T"], trait := "Debug",
  implTy := .struct "Vec" [.param "T"],
  whereClauses := [⟨.param "T", "Debug"⟩]
}
