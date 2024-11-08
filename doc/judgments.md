# Formal rules

## Judgments

The following judgments indicate things present in the source program

### Struct

The struct $S$ has the type parameters $\overline{X}$

$$
\text{struct}\:S \langle \overline{X} \rangle \{ \ldots \}
$$

### Struct fields

The struct $S\langle\overline{\tau}\rangle$ is declared with the given fields

$$
S \langle \overline{\tau} \rangle \{ \overline{\text{field}: \tau_f} \}
$$

### Trait supertraits

The trait $T$ is declared with supertraits $\overline{T_s}$

$$
\text{trait}\:T:\:\overline{T_s} \{ \ldots \}
$$

### Trait associated type bounds

The trait $T$ is declared with the given associated type bound

$$
\text{trait}\:T: \ldots \{ \text{type} A: \overline{T_b} \}
$$

### Implements

The trait $T$ is implemented for $\tau$:

$$
\Gamma \vdash T \: \tau
$$

### Normalizes to

The associated type $A$, applied to the type $\tau$ reduces to $\tau_1$:

$$\Gamma \vdash A \: \tau \mapsto \tau_1$$

## Basic axioms 

### Assumption

$$
\frac{
    W \in \Gamma
}{
    \Gamma \vdash W
}
$$

### Implication

$$
\frac{
    \Gamma,W_0 \vdash W_1
}{
    \Gamma \vdash (W_0 \Rightarrow W_1)
}
$$

### Forall

$$
\frac{
    \Gamma \vdash W \quad
    X \notin FV(\Gamma, W)
}{
    \Gamma \vdash \forall \overline{X}.W
}
$$

### Exists

$$
\frac{
    \Gamma \vdash [\overline{\tau}/\overline{X}] W
}{
    \Gamma \vdash \exists{\overline{X}}.W
}
$$

### And

$$
\frac{
    \Gamma \vdash W_0 \quad
    \Gamma \vdash W_1
}{
    \Gamma \vdash W_0 \wedge W_1
}
$$

### Or

$$
\frac{
    \Gamma \vdash W_i
}{
    \Gamma \vdash W_0 \vee W_1
}
$$

## Type equality

### Reflexive

$$
\frac{
    \Gamma \vdash \tau_2 = \tau_1
}{
    \Gamma \vdash \tau_1 = \tau_2
}
$$

### Syntactic equality rules

$$
\frac{
    \Gamma \vdash \overline{\tau_1 = \tau_2}
}{
    \Gamma \vdash S\langle\overline{\tau_1}\rangle = S\langle\overline{\tau_2}\rangle
}
$$

$$
\frac{
    \Gamma \vdash \overline{\tau_1 = \tau_2}
}{
    \Gamma \vdash (\overline{\tau_1}) = (\overline{\tau_2})
}
$$

$$
\frac{
}{
    \Gamma \vdash X = X
}
$$

### Alias syntactic equality

$$
\frac{
    \Gamma \vdash \overline{\tau_1 = \tau_2}
}{
    \Gamma \vdash A\:\tau_1 = A\:\tau_2
}
$$

### Alias normalization equality

$$
\frac{
    \Gamma \vdash A\:\tau_1 \mapsto \tau_2 \quad
    \Gamma \vdash \tau_2 = \tau_3
}{
    \Gamma \vdash A\:\tau_1 = \tau_3
}
$$

## Trait is implemented

### implemented-from-impl

$$
\frac{
    \begin{gather}
    \text{trait}\:T:\:\overline{T_s} \{ \ldots \} \\
    \text{impl}\langle\overline{X_i}\rangle\:T\:\text{for}\:\tau_i
    \:\text{where}\:\overline{W_i} \{\} \\
    \Gamma, T\:\tau \vdash \tau = [\overline{X_i \mapsto \tau_0}] \tau_i \\
    \Gamma, T\:\tau \vdash [\overline{X_i \mapsto \tau_0}] W_i \\
    \overline{\Gamma\vdash T_s\:\tau}
    \end{gather}
}{
    \Gamma \vdash T\:\tau
}
$$

Key things to note:

* The supertraits are proven in the same environment $\Gamma$
    * This reflects the fact a cycle in that context is unproductive.

### implemented-from-super-trait

$$
\frac{
    \begin{gather}
    \text{trait}\:T:\:\ldots,T_s,\ldots \{ \ldots \} \\
    \Gamma\vdash T\:\tau
    \end{gather}
}{
    \Gamma \vdash T_s\:\tau
}
$$

### implemented-from-associated-type-bound

$$
\frac{
    \begin{gather}
    \text{trait}\:T:\ldots \{ type A: \ldots,T_b,\ldots \} \\
    \end{gather}
}{
    \Gamma \vdash T_b\:A\:\tau
}
$$

## Normalization

### normalize-via-impl

$$
\frac{
    \begin{gather}
    
    \text{trait}\:T:\:\overline{T_s} \{ type A: \overline{T_b} \} \\

    \text{impl}\langle\overline{X_i}\rangle\:T\:\text{for}\:\tau_i
    \:\text{where}\:\overline{W_i} \{ type A = \tau_i \} \\
    
    \Gamma \vdash T\:\tau \\

    \Gamma \vdash \[\overline{X_i \mapsto \tau_s}\] \tau_i = \tau_3

    \end{gather}
}{
    \Gamma \vdash A\:\tau \mapsto \tau_3
}
$$