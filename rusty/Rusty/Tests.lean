-- Unit tests and examples for the Rusty type system rules
-- 
-- This file contains concrete examples that serve as "unit tests" for our inference rules.
-- Each example demonstrates that specific judgments are derivable using our formal system.
--
-- Organization:
-- 1. Example programs - Concrete Rust-like programs encoded in our AST
-- 2. Derivation proofs - Shows specific trait implementations and normalizations work
-- 3. Property statements - Theorems about the type system (proofs in Properties.lean)

import Rusty.AST
import Rusty.Substitution
import Rusty.TraitImpl
import Rusty.AssocTypeNorm

-- ANCHOR: example-program
-- Example program modeling a common Rust pattern:
-- struct Vec<T> {}
-- trait Iterator { type Item; }  
-- impl<T> Iterator for Vec<T> { type Item = T; }
--
-- This demonstrates:
-- - Generic struct definition (Vec with type parameter T)
-- - Trait with associated type (Iterator with Item)
-- - Generic impl that propagates type parameters to associated types
def exampleProgram : Program := {
  structs := [
    { name := "Vec", typeParams := ["T"], fields := [] }
  ],
  traits := [
    { name := "Iterator", supertraits := [], assocType := "Item", assocBounds := [] }
  ],
  impls := [
    { 
      typeParams := ["T"], 
      traitName := "Iterator", 
      implType := RustyType.struct "Vec" [RustyType.param "T"], 
      whereClause := [], 
      assocTypeValue := RustyType.param "T" 
    }
  ]
}
-- ANCHOR_END: example-program

-- ANCHOR: example-derivations
-- Example 1: Concrete trait implementation
-- 
-- Demonstrates: The inference rule correctly derives that Vec<String> implements Iterator
-- by finding the generic impl<T> Iterator for Vec<T> and instantiating T = String
--
-- This tests:
-- - Substitution application (T ↦ String)
-- - Empty where clause handling
-- - Basic trait implementation judgment
example : TraitImplJudgment exampleProgram [] (RustyType.struct "Vec" [RustyType.struct "String" []]) "Iterator" := by
  apply TraitImplJudgment.fromImpl
  · -- The impl exists in the program
    simp [exampleProgram]
  · -- Where clauses are satisfied (empty list, so vacuously true)
    intros wc h_in
    simp at h_in
  
-- Example 2: Associated type normalization
--
-- Demonstrates: When Vec<String> implements Iterator, the associated type Item
-- correctly normalizes to String (because impl defines type Item = T)
--
-- This tests:
-- - Associated type resolution through impls
-- - Substitution in associated type values (T ↦ String applied to Item = T)
-- - Interaction between trait implementation and normalization judgments
example : AssocTypeNormJudgment exampleProgram [] "Item" (RustyType.struct "Vec" [RustyType.struct "String" []]) (RustyType.struct "String" []) := by
  apply AssocTypeNormJudgment.fromImpl
  · -- The impl exists 
    simp [exampleProgram]
  · -- Where clauses satisfied
    intros wc h_in
    simp at h_in
  · -- Trait implementation holds
    apply TraitImplJudgment.fromImpl
    · simp [exampleProgram]
    · intros wc h_in; simp at h_in
-- ANCHOR_END: example-derivations

-- ANCHOR: properties
-- Key properties that our type system should satisfy
--
-- These theorems represent important guarantees we want to prove about the system.
-- They ensure our rules behave sensibly and match our intuitions about traits.

-- Property 1: Trait implementations always have associated types
--
-- If a type implements a trait, we can always find how its associated types normalize.
-- This ensures trait implementations are "complete" - they define all required types.
theorem trait_impl_has_assoc_type (p : Program) (γ : Context) (τ : RustyType) (T : TraitName) :
  TraitImplJudgment p γ τ T → 
  ∃ (A : AssocTypeName) (τ_a : RustyType), AssocTypeNormJudgment p γ A τ τ_a := by
  sorry -- TODO: Prove by analyzing the impl structure

-- Property 2: Associated type normalization is deterministic
--
-- A given associated type for a specific type normalizes to exactly one result.
-- This is crucial - without it, the type system would be ambiguous.
theorem assoc_type_deterministic (p : Program) (γ : Context) (A : AssocTypeName) (τ τ₁ τ₂ : RustyType) :
  AssocTypeNormJudgment p γ A τ τ₁ → 
  AssocTypeNormJudgment p γ A τ τ₂ → 
  τ₁ = τ₂ := by
  sorry -- TODO: Prove by showing only one impl can match

-- Property 3: Substitution preserves trait implementation
--
-- If τ implements a trait, then substituting type parameters in τ preserves this.
-- This property is NOT true in general! It requires careful statement about
-- which substitutions are valid. This version is too strong as stated.
theorem subst_preserves_trait_impl (p : Program) (γ : Context) (s : Substitution) (τ : RustyType) (T : TraitName) :
  TraitImplJudgment p γ τ T →
  TraitImplJudgment p γ (applySubst s τ) T := by
  sorry -- TODO: This needs refinement - only true for certain substitutions
-- ANCHOR_END: properties