-- Soundness and other meta-properties of the Rusty type system
--
-- This file contains formal statements of important properties that ensure
-- our type system is well-behaved. The properties fall into several categories:
--
-- 1. Well-formedness - Types and programs are properly constructed
-- 2. Soundness - Well-typed programs don't get stuck  
-- 3. Determinism - Judgments produce unique results
-- 4. Decidability - For restricted cases, we can algorithmically check properties
--
-- Note: Most proofs are left as 'sorry' for now - they represent
-- important future work to verify our system is correct.

import Rusty.AST
import Rusty.Substitution  
import Rusty.TraitImpl
import Rusty.AssocTypeNorm

-- ANCHOR: well-formed
-- Well-formedness predicates
--
-- WellFormedType ensures:
-- - Struct types reference declared structs with correct arity
-- - All component types are recursively well-formed
-- - Type parameters are treated as always well-formed (they're variables)
def WellFormedType (p : Program) : RustyType → Prop
  | RustyType.struct name args => 
      (∃ def ∈ p.structs, def.name = name ∧ def.typeParams.length = args.length) ∧
      (∀ arg ∈ args, WellFormedType p arg)
  | RustyType.tuple args => ∀ arg ∈ args, WellFormedType p arg
  | RustyType.assoc A base => WellFormedType p base
  | RustyType.param _ => True

def WellFormedProgram (p : Program) : Prop :=
  -- All impl types are well-formed
  (∀ impl ∈ p.impls, WellFormedType p impl.implType ∧ WellFormedType p impl.assocTypeValue) ∧
  -- All traits referenced in impls exist
  (∀ impl ∈ p.impls, ∃ trait ∈ p.traits, trait.name = impl.traitName)
-- ANCHOR_END: well-formed

-- ANCHOR: soundness-properties  
-- Core soundness properties - these ensure our type system is safe and consistent

-- Progress: Well-typed programs can make progress
--
-- If a type implements a trait in a well-formed program, then we can always
-- resolve its associated types. This means type checking won't get "stuck"
-- on well-formed programs.
theorem progress (p : Program) (γ : Context) (τ : RustyType) (T : TraitName) :
  WellFormedProgram p → 
  WellFormedType p τ →
  TraitImplJudgment p γ τ T → 
  ∃ (A : AssocTypeName) (τ_a : RustyType), AssocTypeNormJudgment p γ A τ τ_a := by
  sorry

-- Subject reduction: Operations preserve well-formedness
--
-- Applying a well-formed substitution to a well-formed type produces a well-formed type.
-- This ensures type operations don't break the type system's invariants.
theorem substitution_preserves_wf (p : Program) (s : Substitution) (τ : RustyType) :
  WellFormedType p τ → 
  (∀ (x, τ_s) ∈ s, WellFormedType p τ_s) →
  WellFormedType p (applySubst s τ) := by
  sorry

-- Consistency: No contradictory normalizations
--
-- An associated type cannot normalize to two different types simultaneously.
-- This is a stronger version of determinism - it says we can't derive τ = τ
-- AND τ = τ' where τ ≠ τ'.
theorem no_bad_normalization (p : Program) (γ : Context) (A : AssocTypeName) (τ : RustyType) :
  WellFormedProgram p →
  ¬(AssocTypeNormJudgment p γ A τ τ ∧ 
    ∃ τ' ≠ τ, AssocTypeNormJudgment p γ A τ τ') := by
  sorry
-- ANCHOR_END: soundness-properties

-- ANCHOR: decidability
-- Decidability results (for simple cases)
-- Note: Full decidability may require termination measures

def hasImpl (p : Program) (T : TraitName) (τ : RustyType) : Bool :=
  p.impls.any (fun impl => impl.traitName = T && impl.implType = τ)

-- For ground types (no type parameters), trait implementation should be decidable
theorem trait_impl_decidable_ground (p : Program) (T : TraitName) (τ : RustyType) :
  WellFormedProgram p →
  (τ.freeVars = []) →  -- Ground type (no free variables)
  (TraitImplJudgment p [] τ T) ∨ ¬(TraitImplJudgment p [] τ T) := by
  sorry
-- ANCHOR_END: decidability