---
layout: default
title : relations.extensionality module
date : 2021-05-22
author: William DeMeo
---

### <a id="relation-extensionality">Relation Extensionality</a>

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-} -- cubical #-}


module relations.extensionality where

open import agda-imports
open import overture.preliminaries
open import overture.inverses
open import Relation.Binary renaming (Rel to BinRel) using (IsEquivalence)
open import relations.continuous
open import relations.quotients
open import relations.truncation


private variable α β γ : Level


DFunExt : Typeω
DFunExt = (α β : Level) → funext α β

module _ {fe : funext β β}{A : Type α}{B : Type β} where

 SurjInvIsRightInv : (f : A → B)(fE : IsSurjective f) → f ∘ (SurjInv f fE) ≡ 𝑖𝑑 B
 SurjInvIsRightInv f fE = fe (λ x → InvIsInv f (fE x))

 epic-factor : {C : Type γ}(f : A → B)(g : A → C)(h : C → B)
  →            f ≡ h ∘ g → IsSurjective f → IsSurjective h

 epic-factor f g h compId fE y = goal
  where
   finv : B → A
   finv = SurjInv f fE

   ζ : f (finv y) ≡ y
   ζ = cong-app (SurjInvIsRightInv f fE) y

   η : (h ∘ g) (finv y) ≡ y
   η = (cong-app (compId ⁻¹)(finv y)) ∙ ζ

   goal : Image h ∋ y
   goal = eq (g (finv y)) (η ⁻¹)
--   eq : {b : B} → (a : A) → b ≡ f a → Image f ∋ b

\end{code}

Here's a better version.  (It's better because it only requires point-wise equality in the hypothesis and doesn't require a function extensionality postulate.)

\begin{code}

module _ {A : Type α}{B : Type β} where

 epic-factor≈ : {C : Type γ}(f : A → B)(g : A → C)(h : C → B)
  →            f ≈ h ∘ g → IsSurjective f → IsSurjective h

 epic-factor≈ f g h comp≈ fE y = goal
  where
   finv : B → A
   finv = SurjInv f fE

   ζ : f (finv y) ≡ y
   ζ = (SurjInvIsRightInv≈ f fE) y

   η : (h ∘ g) (finv y) ≡ y
   η = ((comp≈ (finv y)) ⁻¹) ∙ ζ

   goal : Image h ∋ y
   goal = eq (g (finv y)) (η ⁻¹)

\end{code}


#### <a id="alternative-extensionality-type">An alternative way to express function extensionality</a>

The principle of *proposition extensionality* asserts that logically equivalent propositions are equivalent.  That is, if `P` and `Q` are propositions and if `P ⊆ Q` and `Q ⊆ P`, then `P ≡ Q`. For our purposes, it will suffice to formalize this notion for general predicates, rather than for propositions (i.e., truncated predicates).

\begin{code}

pred-ext : (α ρ : Level) → Type (lsuc (α ⊔ ρ))
pred-ext α ρ = ∀ {A : Type α}{P Q : Pred A ρ} → P ⊆ Q → Q ⊆ P → P ≡ Q

\end{code}

Note that `pred-ext` merely defines an extensionality principle. It does not postulate that the principle holds.  If we wish to postulate `pred-ext`, then we do so by assuming that type is inhabited (see `block-ext` below, for example).



#### <a id="quotient-extensionality">Quotient extensionality</a>

We need an identity type for congruence classes (blocks) over sets so that two different presentations of the same block (e.g., using different representatives) may be identified.  This requires two postulates: (1) *predicate extensionality*, manifested by the `pred-ext` type; (2) *equivalence class truncation* or "uniqueness of block identity proofs", manifested by the `blk-uip` type defined in the [Relations.Truncation][] module. We now use `pred-ext` and `blk-uip` to define a type called `block-ext|uip` which we require for the proof of the First Homomorphism Theorem presented in [Homomorphisms.Noether][].

\begin{code}

module _ {A : Type α}{ρ : Level}{R : Equivalence A{ρ}} where

 block-ext : pred-ext α (α ⊔ ρ) → {u v : A} → ∣ R ∣ u v → Block u {ρ} R ≡ Block v {ρ} R
 block-ext pe {u}{v} Ruv = pe ([]-⊆ ρ {R} u v Ruv) ([]-⊇ ρ {R} u v Ruv)


 to-subtype|uip : blk-uip{α}{ρ} A R → {C D : Pred A (α ⊔ ρ)}{c : IsBlock C {R}}{d : IsBlock D {R}}
  →               C ≡ D → (C , c) ≡ (D , d)

 to-subtype|uip buip {C}{D}{c}{d}CD = to-Σ-≡(CD , buip D(transport (λ A → IsBlock A)CD c)d)


 block-ext|uip : pred-ext α (α ⊔ ρ) → blk-uip A R → ∀{u}{v} → ∣ R ∣ u v → ⟪ u / R ⟫ ≡ ⟪ v / R ⟫
 block-ext|uip pe buip Ruv = to-subtype|uip buip (block-ext pe Ruv)

\end{code}



#### <a id="strongly-well-defined-operations">Strongly well-defined operations</a>

We now describe an extensionality principle that seems weaker than function extensionality, but still (probably) not provable in [MLTT][]. (We address this and other questions  below.)  We call this the principle *strong well-definedness of operations*. We will encounter situations in which this weaker extensionality principle suffices as a substitute for function extensionality.

Suppose we have a function whose domain is a function type, say, `I → A`.  For example, inhabitants of the type `Op` defined above are such functions.  (Recall, the domain of inhabitants of type `Op I A := (I → A) → A` is `I → A`.)

Of course, operations of type `Op I A` are well-defined in the sense that equal inputs result in equal outputs.

\begin{code}

welldef : {A : Type α}{I : Arity}(f : Op A{I}) → ∀ u v → u ≡ v → f u ≡ f v
welldef f u v refl = refl

\end{code}

A stronger form of well-definedness of operations is to suppose that point-wise equal inputs lead to the same output.  In other terms, we could suppose that  for all `f : Op I A`, we have `f u ≡ f v` whenever `∀ i → u i ≡ v i` holds.  We call this formalize this notation in the following type.

\begin{code}

swelldef : (α : Level) → Type (lsuc α)
swelldef α = ∀ {A : Type α}{I : Arity}(f : Op A{I})(u v : I → A) → (∀ i → u i ≡ v i) → f u ≡ f v

funext→swelldef : {α : Level} → funext ℓ₀ α → swelldef α
funext→swelldef fe f u v ptweq = goal
 where
 uv : u ≡ v
 uv = fe ptweq
 goal : f u ≡ f v
 goal = welldef f u v uv


SwellDef : Typeω
SwellDef = (α : Level) → swelldef α

-- 0-smallest→swelldef : {𝓥 𝓤 : Level} → 𝟎-is-smallest → swelldef 𝓥 𝓤
-- 0-smallest→swelldef {𝓥}{𝓤} 0min {A}{I} = kernel-lemma 0min

\end{code}


-----------------------------

#### <a id="general-relation-extensionality">General relation extensionality*</a>

We define the following *relation extensionality* principles which generalize the predicate extensionality principle (`pred-ext`) defined above.

\begin{code}

Rel-ext : (α ρ : Level) → Type (lsuc (α ⊔ ρ))
Rel-ext α ρ = ∀ {I : Arity}{A : Type α}{P Q : Rel A {I} {ρ} } → P ⊆ Q → Q ⊆ P → P ≡ Q

REL-ext : (α ρ : Level) → Type (lsuc (α ⊔ ρ))
REL-ext α ρ = ∀ {I : Arity}{𝒜 : I → Type α}{P Q : RelΠ I 𝒜 {ρ}} → P ⊆ Q → Q ⊆ P → P ≡ Q

\end{code}

These types are not used in other modules of the [UniversalAlgebra][] library.


-------

#### <a id="open-questions-about-extensionality">Open questions about strength and provability of extensionality principles</a>

Here are some questions about extensionaity for future consideration.

**Questions about strong vs weak well-definedness**.

1. Is strong well-definedness of operations (`swelldef`) provable in [MLTT][]?

2. Is strong well-definedness of operations strictly weaker than function extensionality?


**Answers**.

1. No (see answer to 2)

2. No, they're equivalent.



**Questions about prop vs pred extensionality**.

1. Is predicate extensionality (`pred-ext`) at least as strong as proposition extensionality?  That is, does `pred-ext 𝓤 𝓦` imply

   `∀(A : Type 𝓤)(P : Pred A 𝓦)(x : A)(p q : P x) → p ≡ q` ?

2. Are the relation extensionality principles `cont-relext` and `dep-relext` at least as strong as proposition extensionality?


---------------------------------------

[← Relations.Truncation](Relations.Truncation.html)
<span style="float:right;">[Algebras →](Algebras.html)</span>


{% include UALib.Links.md %}



























<!--

#### <a id="extensionality">Function Extensionality</a>

(This short and simple-minded introduction to function extensionality is for the uninitiated.  Those already familiar with this concept may wish to skip to the next module.)

What does it mean to say that two functions `f g : A → B` are equal?

Suppose `f` and `g` are defined on `A = ℤ` (the integers) as follows: `f x := x + 2` and `g x := ((2 * x) - 8)/2 + 6`.  Should we call `f` and `g` equal? Are they the "same" function?  What does that even mean?

It's hard to resist the urge to reduce `g` to `x + 2` and proclaim that `f` and `g` are equal. Indeed, this is often an acceptable answer and the discussion normally ends there.  In the science of computing, however, more attention is paid to equality, and with good reason.

We can probably all agree that the functions `f` and `g` above, while not syntactically equal, do produce the same output when given the same input so it seems fine to think of the functions as the same, for all intents and purposes. But we should ask ourselves at what point do we notice or care about the difference in the way functions are defined?

What if we had started out this discussion with two functions, `f` and `g`, both of which take a list as argument and produce as output a correctly sorted version of the input list?  Suppose `f` is defined using the [merge sort](https://en.wikipedia.org/wiki/Merge_sort) algorithm, while `g` uses [quick sort](https://en.wikipedia.org/wiki/Quicksort).  Probably few of us would call `f` and `g` the "same" in this case.

In the examples above, it is common to say that the two functions are [extensionally equal](https://en.wikipedia.org/wiki/Extensionality), since they produce the same *external* output when given the same input, but they are not [intensionally equal](https://en.wikipedia.org/wiki/Intension), since their *internal* definitions differ.

Below we describe types that manifest this notion of *extensional equality of functions*, or *function extensionality*.

#### <a id="function-extensionality-types">Function extensionality types</a>

As explained above, a natural notion of function equality is defined as follows:  `f` and `g` are said to be *point-wise equal* provided `∀ x → f x ≡ g x`.  Here is how this is expressed in type theory (e.g., in the [Type Topology][] library).

```agda
_∼_ : {X : Type 𝓤 } {A : X → Type 𝓥 } → Π A → Π A → Type (𝓤 ⊔ 𝓥)
f ∼ g = ∀ x → f x ≡ g x

infix 8 _∼_
```

*Function extensionality* is the principle that point-wise equal functions are *definitionally* equal; that is, for all functions `f` and `g` we have `f ∼ g → f ≡ g`. In Agda this principle is represented by the
`Extensionality` type defined in the `Axiom.Extensionality.Propositional` module of the standard library.  We show the definition here for easy reference.

```agda
funext : (𝓤 𝓦 : Level) → Type (lsuc (𝓤 ⊔ 𝓦))
funext 𝓤 𝓦 = {A : Type 𝓤} {B : A → Type 𝓦} {f g : (x : A) → B x} → f ∼ g → f ≡ g
```

Note that this definition does not postulate function extensionality; it merely defines what the principle is and makes it available in case we want to postulate it.

In most informal settings at least, this so-called *point-wise equality of functions* is typically what one means when one asserts that two functions are "equal."<sup>[4](Overture.Extensionality.html#fn4)</sup>
However, it is important to keep in mind the following fact (see <a href="https://www.cs.bham.ac.uk/~mhe/HoTT-UF-in-Agda-Lecture-Notes/HoTT-UF-Agda.html#funextfromua">Escardó's notes</a>):

*Function extensionality is known to be neither provable nor disprovable in Martin-Löf type theory. It is an independent statement*.


Previous versions of [UniversalAlgebra][] made heavy use of a *global function extensionality principle*. This asserts that function extensionality holds at all universe levels.
However, we decided to remove all instances of global function extensionality from the latest version of the library and limit ourselves to local applications of the principle. This has the advantage of making transparent precisely how and where the library depends on function extensionality. The price we pay for this precision is a library that is littered with extensionality postulates. Eventually we will probably remove these postulates in favor of an alternative approach to extensionality; e.g., *univalence* and/or Cubical Agda.

The following definition is useful for postulating function extensionality when and where needed.

```agda
DFunExt : Setω
DFunExt = (𝓤 𝓥 : Level) → funext 𝓤 𝓥
```

The right-inverse of `f` is obtained by applying `EpicInv` to `f` and a proof of `Epic f`. To see that this does indeed give the right-inverse we prove the `EpicInvIsRightInv` lemma below. This requires function composition, denoted `∘` and defined in the Function module of the [Agda Standard Library][] (and imported above).

```agda
 _∘_ : Π C → (f : A → B) → (x : A) → C (f x)
 g ∘ f = λ x → g (f x)
```

Note that the next proof requires function extensionality, which we postulate in the module declaration.

module _ {fe : funext 𝓦 𝓦}{A : Type 𝓤}{B : Type 𝓦} where

 SurjInvIsRightInv : (f : A → B)(fE : IsSurjective f) → f ∘ (SurjInv f fE) ≡ 𝑖𝑑 B
 SurjInvIsRightInv f fE = fe (λ x → InvIsInv f (fE x))

We can also prove the following composition law for epics.

 epic-factor : {C : Type 𝓩}(f : A → B)(g : A → C)(h : C → B)
  →            f ≡ h ∘ g → IsSurjective f → IsSurjective h

 epic-factor f g h compId fe y = γ
  where
   finv : B → A
   finv = SurjInv f fe

   ζ : f (finv y) ≡ y
   ζ = cong-app (EpicInvIsRightInv f fe) y

   η : (h ∘ g) (finv y) ≡ y
   η = (cong-app (compId ⁻¹)(finv y)) ∙ ζ

   γ : Image h ∋ y
   γ = eq y (g (finv y)) (η ⁻¹)

-->





-- Imports from the Agda (Builtin) and the Agda Standard Library
open import Agda.Builtin.Equality renaming (_≡_ to infix 0 _≡_)
open import Axiom.Extensionality.Propositional renaming (Extensionality to funext)
-- open import Agda.Primitive using (_⊔_; lzero; lsuc; Level)
open import Data.Product renaming (_,_ to infixr 50 _,_) using (Σ; _×_)
open import Level renaming (suc to lsuc; zero to lzero)
open import Relation.Binary using (Rel; IsEquivalence)
open import Relation.Binary.PropositionalEquality.Core using (subst; cong-app)
open import Relation.Unary using (Pred; _⊆_)
open import Function.Base  using (_∘_; id)



-- Imports from the Agda Universal Algebra Library
open import overture.preliminaries using (Type; 𝓤; 𝓥; 𝓦; 𝓩; -Σ; Π; 𝑖𝑑; _⁻¹; _∙_; _≈_)
open import overture.inverses using (IsSurjective; SurjInv; InvIsInv; Image_∋_; eq; SurjInvIsRightInv≈)
open import relations.continuous using (ContRel; DepRel)
open import relations.discrete using (Op)
open import relations.quotients using ([_]; /-subset; /-supset; IsBlock; ⟪_⟫; 𝟎-is-smallest; kernel-lemma)
open import relations.truncation using (blk-uip; to-Σ-≡)
