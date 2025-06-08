variable (p q r : Prop)

example : p ∧ q ↔ q ∧ p :=
  Iff.intro
    (fun (⟨hp, hq⟩ : p ∧ q) => ⟨hq, hp⟩)
    (fun (⟨hq, hp⟩ : q ∧ p) => ⟨hp, hq⟩)
