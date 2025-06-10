-- Associated type normalization judgment rules
import Rusty.AST
import Rusty.Substitution
import Rusty.TraitImpl

-- ANCHOR: assoc-type-normalization
-- Associated type normalization judgment: Γ ⊢ A : τ ↦ τ₁
-- This corresponds to the mathematical rule in assoc-type-normalization.md
inductive AssocTypeNormJudgment (p : Program) : Context → AssocTypeName → RustyType → RustyType → Prop where
  | fromImpl : 
      ∀ (γ : Context) (impl : TraitImpl) (s : Substitution) (assocName : AssocTypeName),
      -- The impl exists in the program
      impl ∈ p.impls →
      -- We can prove the substituted where clauses
      (∀ wc ∈ impl.whereClause, WhereClauseJudgment p γ (applySubstWhere s wc)) →
      -- We can prove the substituted impl type implements the trait
      TraitImplJudgment p γ (applySubst s impl.implType) impl.traitName →
      -- Then the associated type normalizes to the substituted associated type value
      AssocTypeNormJudgment p γ assocName (applySubst s impl.implType) (applySubst s impl.assocTypeValue)
-- ANCHOR_END: assoc-type-normalization