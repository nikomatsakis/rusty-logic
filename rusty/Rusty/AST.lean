-- AST definitions for the Rusty subset
-- Based on the formal logic system defined in the mdBook

-- Basic name types
abbrev StructName := String
abbrev TraitName := String
abbrev AssocTypeName := String
abbrev TypeParam := String
abbrev FieldName := String

-- ANCHOR: rusty-type
-- Types in the Rusty subset
-- From types.md: τ ::= S⟨τ₀,...,τₙ⟩ | (τ₀,...,τₙ) | A:τ | X
inductive RustyType where
  | struct : StructName → List RustyType → RustyType        -- S⟨τ₀,...,τₙ⟩
  | tuple : List RustyType → RustyType                      -- (τ₀,...,τₙ) where () is unit
  | assoc : AssocTypeName → RustyType → RustyType          -- A:τ
  | param : TypeParam → RustyType                          -- X
  deriving Repr
-- ANCHOR_END: rusty-type

-- ANCHOR: where-clause
-- Where clauses
-- From where-clauses.md: W ::= τ: T | τ: T<A = τ₁> | for<X...> W | W₀ => W₁ | W₀ ∧ W₁ | W₀ ∨ W₁ | ∃X. W
inductive WhereClause where
  | traitImpl : RustyType → TraitName → WhereClause                              -- τ: T
  | traitAssoc : RustyType → TraitName → AssocTypeName → RustyType → WhereClause -- τ: T<A = τ₁>
  | forAll : List TypeParam → WhereClause → WhereClause                         -- for<X...> W
  | implies : WhereClause → WhereClause → WhereClause                           -- W₀ => W₁ (future extension)
  | and : WhereClause → WhereClause → WhereClause                               -- W₀ ∧ W₁
  | or : WhereClause → WhereClause → WhereClause                                -- W₀ ∨ W₁
  | exists : List TypeParam → WhereClause → WhereClause                         -- ∃X. W
  deriving Repr
-- ANCHOR_END: where-clause

-- ANCHOR: struct-def
-- Struct definitions
structure StructDef where
  name : StructName
  typeParams : List TypeParam
  fields : List (FieldName × RustyType)
  deriving Repr
-- ANCHOR_END: struct-def

-- ANCHOR: trait-def
-- Trait definitions
-- From traits-and-impls.md: trait has supertraits, one associated type with bounds
structure TraitDef where
  name : TraitName
  supertraits : List TraitName                    -- T_s_0, ..., T_s_n
  assocType : AssocTypeName                       -- exactly one associated type
  assocBounds : List TraitName                    -- T_b_0, ..., T_b_m bounds on A
  deriving Repr
-- ANCHOR_END: trait-def

-- ANCHOR: trait-impl
-- Trait implementations
structure TraitImpl where
  typeParams : List TypeParam                     -- X_0, ..., X_n
  traitName : TraitName                          -- T
  implType : RustyType                           -- τ
  whereClause : List WhereClause                 -- W_0, ..., W_m
  assocTypeValue : RustyType                     -- τ_A for type A = τ_A
  deriving Repr
-- ANCHOR_END: trait-impl

-- Context for judgments (list of where clauses)
abbrev Context := List WhereClause

-- Judgments from judgments.md
inductive Judgment where
  | traitImpl : Context → TraitName → RustyType → Judgment            -- Γ ⊢ T : τ
  | assocNorm : Context → AssocTypeName → RustyType → RustyType → Judgment -- Γ ⊢ A : τ ↦ τ₁
  | whereClause : Context → WhereClause → Judgment                    -- Γ ⊢ W
  deriving Repr

-- Program containing all definitions
structure Program where
  structs : List StructDef
  traits : List TraitDef
  impls : List TraitImpl
  deriving Repr

-- Special traits (Copy, Send, Sync)
inductive SpecialTrait where
  | copy : SpecialTrait    -- Copy trait
  | send : SpecialTrait    -- Send auto trait
  | sync : SpecialTrait    -- Sync auto trait
  deriving Repr

-- Auto trait implementation (coinductive for Send/Sync)
inductive AutoTraitImpl where
  | auto : StructDef → List WhereClause → AutoTraitImpl
  deriving Repr
