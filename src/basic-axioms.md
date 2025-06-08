# Basic axioms

$$\frac{W \in \Gamma}{\Gamma \vdash W} \text{[Assumption]}$$

$$\frac{\Gamma,W_0 \vdash W_1}{\Gamma \vdash (W_0 \Rightarrow W_1)} \text{[Implication]}$$

$$\frac{\Gamma \vdash W \quad X \notin FV(\Gamma, W)}{\Gamma \vdash \forall \overline{X}.W} \text{[Forall]}$$

$$\frac{\Gamma \vdash [\overline{\tau}/\overline{X}] W}{\Gamma \vdash \exists{\overline{X}}.W} \text{[Exists]}$$

$$\frac{\Gamma \vdash W_0 \quad \Gamma \vdash W_1}{\Gamma \vdash W_0 \wedge W_1} \text{[And]}$$

$$\frac{\Gamma \vdash W_i}{\Gamma \vdash W_0 \vee W_1} \text{[Or]}$$
