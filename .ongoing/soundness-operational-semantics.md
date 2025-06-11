# Soundness via Operational Semantics

## Current Discussion

We're exploring how to prove soundness for the trait system using an operational semantics approach with progress/preservation.

**My role**: Act as skeptic to double-check logical reasoning

### The Problem
Want to prove: If we can prove a where-clause that a trait is implemented for a given type, then we will always be able to find an impl that applies.

### Proposed Approach
Convert to operational semantics where:
- **States**: Where-clauses we're trying to prove
- **Steps**: Operations like expanding to supertraits, applying impls
- **Progress**: Non-terminal states can always step
- **Preservation**: Steps preserve provability

### Key Insight from Niko
This approach is similar to the modeling in:
- "Programming with Higher-order Logic" 
- "Handbook of Practical Logic and Automated Reasoning"

These books model DPLL and resolution techniques operationally. This is relevant because:
1. Trait resolution is essentially logic programming (Horn clauses)
2. We can model it as a search procedure with backtracking
3. The operational semantics gives us both a proof technique AND an implementation strategy

## Status
- Discussed the general approach
- Started sketching operational semantics structure
- Established connection to DPLL/resolution from logic programming
- **Current focus**: Non-deterministic operational semantics (no backtracking needed for soundness)

## Open Questions (Acting as Skeptic)

1. **Clarification needed on "soundness" direction**: 
   - Niko stated: "If we can prove the where-clause that a trait is implemented for a given type, then we will always be able to find an impl that applies"
   - This sounds like: "If declarative system proves `T: Trait`, then operational system can find proof"
   - That's more like **completeness** of operational w.r.t. declarative, not soundness
   - Traditional soundness would be: "If operational finds impl, then declarative can prove it"
   - **Which direction do we actually want?**

2. **What exactly is "finding an impl that applies"?**
   - Does this mean finding a specific impl declaration in the program?
   - Or does it mean deriving the trait through any means (impls, supertraits, etc.)?
   
3. **Non-determinism assumption check**:
   - We assume non-determinism is OK because we just need to show *some* derivation exists
   - But does our actual property require finding a *specific* impl, not just any derivation?

## Next Steps
1. Understand what this approach reminds Niko of
2. Refine the operational semantics based on his feedback
3. Work through concrete examples
4. Implement and prove progress/preservation theorems

## Context
This builds on our existing work:
- AST definitions in `rusty/Rusty/AST.lean`
- Substitution operations in `rusty/Rusty/Substitution.lean`
- Trait implementation and normalization judgments
- Unit tests in `rusty/Rusty/Tests.lean`
- Property statements in `rusty/Rusty/Properties.lean`