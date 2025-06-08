# Basic axioms

## *Assumption*: Using context

$$\frac{W \in \Gamma}{\Gamma \vdash W} \text{[Assumption]}$$

If a where clause $W$ is already in our context $\Gamma$, then we can conclude it holds.

## *Implication*: Forming conditionals

$$\frac{\Gamma,W_0 \vdash W_1}{\Gamma \vdash (W_0 \Rightarrow W_1)} \text{[Implication]}$$

If we can prove $W_1$ under the assumption that $W_0$ holds, then we can conclude that $W_0$ implies $W_1$.

## *Forall*: Universal quantification

$$\frac{\Gamma \vdash W \quad X \notin FV(\Gamma, W)}{\Gamma \vdash \forall \overline{X}.W} \text{[Forall]}$$

If we can prove $W$ and the variables $\overline{X}$ don't appear free in our context or conclusion, then we can universally quantify over $\overline{X}$.

## *Exists*: Existential quantification

$$\frac{\Gamma \vdash [\overline{\tau}/\overline{X}] W}{\Gamma \vdash \exists{\overline{X}}.W} \text{[Exists]}$$

If we can prove $W$ with specific types $\overline{\tau}$ substituted for variables $\overline{X}$, then there exist types satisfying $W$.

## *And*: Combining propositions

$$\frac{\Gamma \vdash W_0 \quad \Gamma \vdash W_1}{\Gamma \vdash W_0 \wedge W_1} \text{[And]}$$

If we can prove both $W_0$ and $W_1$ separately, then we can conclude their conjunction.

## *Or*: Handling disjunction

$$\frac{\Gamma \vdash W_i}{\Gamma \vdash W_0 \vee W_1} \text{[Or]}$$

If we can prove one of $W_0$ or $W_1$, then we can conclude their disjunction.
