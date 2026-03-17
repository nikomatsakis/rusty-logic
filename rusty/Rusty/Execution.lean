/-
  Execution — Reachable statements from main()

  Defines which statements can be reached during execution of a program,
  starting from `main()`. Since `main` has no type parameters, every
  reachable statement involves only concrete (monomorphic) types.

  The `Reachable` relation is the bridge between static typing and
  runtime behavior in the soundness theorem.
-/
import Rusty.IR

-- ANCHOR: Reachable
/-- A statement is reachable if it can be executed starting from `main()`.

    Execution proceeds by:
    1. Starting with statements directly in main's body.
    2. Following function calls: when `f⟨τ̄⟩()` is reachable, the body of `f`
       (with type parameters substituted by `τ̄`) is also reachable. -/
inductive Reachable (p : Program) : Stmt → Prop where
  /-- Statements directly in main's body are reachable. -/
  | inMain :
      f ∈ p.funcs →
      f.name = "main" →
      f.arity = 0 →
      f.whereClauses = [] →
      stmt ∈ f.body →
      Reachable p stmt
  /-- If a function call `f⟨τ̄⟩()` is reachable, then the statements in f's
      body (with type parameters substituted by τ̄) are also reachable. -/
  | viaCall :
      Reachable p (.call fname tyArgs) →
      f ∈ p.funcs →
      f.name = fname →
      stmt ∈ f.body →
      Reachable p (applySubstStmt tyArgs stmt)
-- ANCHOR_END: Reachable
