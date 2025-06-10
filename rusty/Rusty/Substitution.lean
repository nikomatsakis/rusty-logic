-- Substitution operations for the Rusty type system
import Rusty.AST

-- ANCHOR: substitution
-- Type parameter substitution (capture-avoiding)
-- Maps type parameters to concrete types
abbrev Substitution := List (TypeParam × RustyType)

-- Get free type parameters in a type
def freeVars : RustyType → List TypeParam
  | RustyType.struct _ args => args.bind freeVars
  | RustyType.tuple args => args.bind freeVars
  | RustyType.assoc _ base => freeVars base
  | RustyType.param x => [x]

-- Get free type parameters in a substitution
def freeVarsSubst (s : Substitution) : List TypeParam :=
  s.bind (fun (_, t) => freeVars t)

-- Remove bindings from substitution for given parameters
def removeBindings (s : Substitution) (params : List TypeParam) : Substitution :=
  s.filter (fun (x, _) => x ∉ params)

-- Apply substitution to a type
def applySubst (s : Substitution) : RustyType → RustyType
  | RustyType.struct name args => RustyType.struct name (args.map (applySubst s))
  | RustyType.tuple args => RustyType.tuple (args.map (applySubst s))
  | RustyType.assoc assoc base => RustyType.assoc assoc (applySubst s base)
  | RustyType.param x => 
      match s.find? (fun p => p.1 = x) with
      | some (_, t') => t'
      | none => RustyType.param x

-- Apply capture-avoiding substitution to where clauses
def applySubstWhere (s : Substitution) (w : WhereClause) : WhereClause :=
  match w with
  | WhereClause.traitImpl t trait => WhereClause.traitImpl (applySubst s t) trait
  | WhereClause.traitAssoc t trait assoc val => 
      WhereClause.traitAssoc (applySubst s t) trait assoc (applySubst s val)
  | WhereClause.forAll params body => 
      -- Capture-avoiding: remove conflicting bindings from substitution
      let s' := removeBindings s params
      WhereClause.forAll params (applySubstWhere s' body)
  | WhereClause.implies w1 w2 => WhereClause.implies (applySubstWhere s w1) (applySubstWhere s w2)
  | WhereClause.and w1 w2 => WhereClause.and (applySubstWhere s w1) (applySubstWhere s w2)
  | WhereClause.or w1 w2 => WhereClause.or (applySubstWhere s w1) (applySubstWhere s w2)
  | WhereClause.exists params body => 
      -- Capture-avoiding: remove conflicting bindings from substitution
      let s' := removeBindings s params
      WhereClause.exists params (applySubstWhere s' body)

-- Apply substitution to a list of where clauses
def applySubstWheres (s : Substitution) (ws : List WhereClause) : List WhereClause :=
  ws.map (applySubstWhere s)
-- ANCHOR_END: substitution