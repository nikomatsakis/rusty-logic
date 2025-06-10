-- Trait implementation judgment rules
import Rusty.AST
import Rusty.Substitution

-- ANCHOR: trait-impl-judgment
-- Trait implementation judgment: Γ ⊢ S(τᵢ) : T
-- This corresponds to the mathematical rule in trait-impl-judgment.md
inductive TraitImplJudgment (p : Program) : Context → RustyType → TraitName → Prop where
  | fromImpl : 
      ∀ (γ : Context) (impl : TraitImpl) (s : Substitution),
      -- The impl exists in the program
      impl ∈ p.impls →
      -- We can prove the substituted where clauses
      (∀ wc ∈ impl.whereClause, WhereClauseJudgment p γ (applySubstWhere s wc)) →
      -- Then we can conclude the substituted impl type implements the trait
      TraitImplJudgment p γ (applySubst s impl.implType) impl.traitName
  
-- Where clause judgment: Γ ⊢ W  
-- This is referenced by the trait implementation rule
inductive WhereClauseJudgment (p : Program) : Context → WhereClause → Prop where
  | assumption : 
      ∀ (γ : Context) (wc : WhereClause),
      wc ∈ γ →
      WhereClauseJudgment p γ wc
  | traitImpl :
      ∀ (γ : Context) (t : RustyType) (trait : TraitName),
      TraitImplJudgment p γ t trait →
      WhereClauseJudgment p γ (WhereClause.traitImpl t trait)
  -- Additional rules would be added here for other where clause forms
-- ANCHOR_END: trait-impl-judgment