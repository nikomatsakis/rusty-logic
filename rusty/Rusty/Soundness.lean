/-
  Soundness — Well-typedness and the soundness theorem

  The soundness property: if a program is well-typed, then every
  `assert_impl!(τ: T)` that is reachable from `main()` is provable
  from the empty context.

  In other words: well-typed programs never reach a failing assertion.
-/
import Rusty.Judgment
import Rusty.Execution

/-!
## Well-typedness

A program is well-typed when every function's body is justified by
the function's where clauses.
-/

-- ANCHOR: WellTyped
/-- A statement is well-typed in context `ctx`:
    - `assert_impl!(τ: T)` requires `Proves p ctx τ T`
    - `f⟨τ̄⟩()` requires that every function named f has its where clauses hold after substitution -/
def StmtWellTyped (p : Program) (ctx : List WhereClause) : Stmt → Prop
  | .assertImpl ty trait => Proves p ctx ty trait
  | .call fname tyArgs =>
      ∀ g ∈ p.funcs, g.name = fname →
        ∀ wc ∈ g.whereClauses,
          Proves p ctx (applySubstWC tyArgs wc).ty (applySubstWC tyArgs wc).trait

/-- A function is well-typed when every statement in its body is
    well-typed under the function's where-clause context. -/
def FuncWellTyped (p : Program) (f : FuncDef) : Prop :=
  ∀ stmt ∈ f.body, StmtWellTyped p f.whereClauses stmt

/-- A program is well-typed when all its functions are well-typed. -/
def ProgramWellTyped (p : Program) : Prop :=
  ∀ f ∈ p.funcs, FuncWellTyped p f
-- ANCHOR_END: WellTyped

/-!
## The substitution lemma

The key supporting lemma: if we can prove all of a function's where clauses
(after substitution) from the empty context, then anything provable from
those where clauses is also provable from the empty context (after substitution).

This bridges the gap between:
- The caller proving the callee's where clauses hold (from well-typedness of the call)
- The callee's body being justified from its where clauses (from well-typedness of the callee)
-/

-- ANCHOR: SubstLemma
/-- If every where clause in `ctx` is provable from `[]` after applying substitution `s`,
    then any judgment provable from `ctx` is also provable from `[]` after substitution. -/
theorem proves_subst (p : Program)
    (s : Subst)
    (ctx : List WhereClause)
    (hctx : ∀ wc ∈ ctx, Proves p [] (applySubstWC s wc).ty (applySubstWC s wc).trait)
    (ty : Ty) (trait : String)
    (h : Proves p ctx ty trait) :
    Proves p [] (applySubst s ty) trait := by
  sorry
-- ANCHOR_END: SubstLemma

/-!
## Soundness theorem

Every reachable statement in a well-typed program is well-typed under
the empty context. The main theorem (`soundness`) follows as a corollary
for `assertImpl`.
-/
theorem stmt_subst_preserves_well_typed
  (p : Program)
  (tyArgs : List Ty)
  (ctx : List WhereClause)
  (stmt : Stmt)
  :
  StmtWellTyped p wcs stmt →
  (∀ wc ∈ wcs, Proves p [] (applySubstWC tyArgs wc).ty (applySubstWC tyArgs wc).trait) →
  StmtWellTyped p [] (applySubstStmt tyArgs stmt) := by
    intro stmt_wt_under_wc wcs_wt
    cases stmt with
    | assertImpl ty trait =>
      apply proves_subst p tyArgs wcs wcs_wt ty trait
      exact stmt_wt_under_wc
    | call fname callArgs =>
      
      sorry

theorem call_implies_body_well_typed
  (p : Program)
  (fname : String)
  (tyArgs : List Ty)
  (f : FuncDef)
  (stmt : Stmt)
  : StmtWellTyped p [] (.call fname tyArgs) →
  f ∈ p.funcs →
  f.name = fname →
  stmt ∈ f.body →
  StmtWellTyped p f.whereClauses stmt →
  StmtWellTyped p [] (applySubstStmt tyArgs stmt) := by
    intro call_well_typed f_in_funcs f_has_name _stmt_in_body stmt_wt_under_wc
    have wc_proofs : ∀ wc ∈ f.whereClauses,
      let subst_wc := applySubstWC tyArgs wc
      Proves p [] subst_wc.ty subst_wc.trait := by
        intro wc wc_in_f
        exact call_well_typed f f_in_funcs f_has_name wc wc_in_f
    exact stmt_subst_preserves_well_typed _ _ _ _
      stmt_wt_under_wc
      wc_proofs

-- ANCHOR: SoundnessGen
/-- Every reachable statement in a well-typed program is well-typed
    under the empty context (no assumptions needed). -/
theorem soundness_general
  (p : Program)
  (program_is_well_typed : ProgramWellTyped p)
  (stmt : Stmt)
  (hypothesis_stmt_reachable : Reachable p stmt)
  : StmtWellTyped p [] stmt := by
  induction hypothesis_stmt_reachable with
  | inMain f f_is_main f_arity_zero f_no_wc f_stmt =>
      have f_wf := program_is_well_typed _ f
      have stmt_well_typed := f_wf _ f_stmt
      rw [f_no_wc] at stmt_well_typed
      exact stmt_well_typed
  | viaCall call_to_f_reachable f f_has_name f_stmt substd_stmt_reachable =>
      have f_wf := program_is_well_typed _ f
      have stmt_wt := f_wf _ f_stmt
      exact call_implies_body_well_typed p _ _ _ _
        substd_stmt_reachable  -- proof of: StmtWellTyped p [] (.call fname tyArgs)
        f
        f_has_name
        f_stmt
        stmt_wt

-- ANCHOR_END: SoundnessGen

-- ANCHOR: Soundness
/-- If a program is well-typed, every reachable `assert_impl!` is provable
    from the empty context. -/
theorem soundness (p : Program) (hwt : ProgramWellTyped p)
    {ty : Ty} {trait : String}
    (hreach : Reachable p (.assertImpl ty trait)) :
    Proves p [] ty trait :=
  soundness_general p hwt _ hreach
-- ANCHOR_END: Soundness
