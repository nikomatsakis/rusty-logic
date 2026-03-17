/-
  Judgment — Inference rules for trait resolution

  The judgment `Proves p Γ τ T` means: in program `p`, from context `Γ`,
  we can prove that type `τ` implements trait `T`.

  Two inference rules:
  1. **Assumption**: `(τ: T) ∈ Γ`
  2. **Impl**: there exists an impl in `p` and type arguments such that
     the impl applies to `τ` and all its where clauses are provable.
-/
import Rusty.IR

-- ANCHOR: Proves
/-- The core judgment: `Γ ⊢ τ : T` in program `p`.

    Proves that type `τ` implements trait `T`, given context `Γ`
    (a list of assumed where clauses) and program `p`. -/
inductive Proves (p : Program) : List WhereClause → Ty → String → Prop where
  /-- **Assumption rule**: if `(τ: T) ∈ Γ`, then `Γ ⊢ τ : T`.

      $$\frac{(\tau: T) \in \Gamma}{\Gamma \vdash \tau: T}$$ -/
  | assumption :
      ⟨ty, trait⟩ ∈ ctx →
      Proves p ctx ty trait
  /-- **Impl rule**: if there is an impl in `p` that, after substitution
      with `tyArgs`, proves `τ : T` and all its where clauses hold.

      $$\frac{
        \text{impl}\langle\overline{X}\rangle\:T\:\text{for}\:\tau_i\:\text{where}\:\overline{W} \in P \quad
        S = (\overline{X} \mapsto \overline{\tau_s}) \quad
        \Gamma \vdash S(\overline{W})
      }{\Gamma \vdash S(\tau_i) : T}$$ -/
  | byImpl :
      (impl : ImplDef) →
      (tyArgs : List Ty) →
      impl ∈ p.impls →
      impl.trait = trait →
      tyArgs.length = impl.arity →
      applySubst tyArgs impl.implTy = ty →
      (∀ wc ∈ impl.whereClauses,
        Proves p ctx (applySubstWC tyArgs wc).ty (applySubstWC tyArgs wc).trait) →
      Proves p ctx ty trait
-- ANCHOR_END: Proves
