---
layout: default
title : Homs.base
date : 2021-05-22
author: William DeMeo
---

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-} -- cubical #-}

open import structures.base


module Homs.base {𝑅 𝐹 : Signature} where

open import agda-imports
open import overture.preliminaries
open import overture.inverses
open import relations.discrete
open import relations.quotients
open import relations.extensionality

open import structures.Congruences {𝑅 = 𝑅}{𝐹 = 𝐹}

private variable  α β : Level
-- ρ ρ' γ


-- Development for Structures (Sigma type representation)

module _ (𝑨 : Structure α 𝑅 ℓ₀ 𝐹)(𝑩 : Structure β 𝑅 ℓ₀ 𝐹) where

 CompRel : (fst 𝑅) → ((fst 𝑨) → (fst 𝑩)) → Type α
 CompRel R h = ∀ a → ((R ʳ 𝑨) a) → ((R ʳ 𝑩) (h ∘ a))

 IsHom-rel : ((fst 𝑨) → (fst 𝑩)) → Type α
 IsHom-rel h = ∀ R →  CompRel R h

 CompOp : (fst 𝐹) → ((fst 𝑨) → (fst 𝑩)) → Type (α ⊔ β)
 CompOp f h = ∀ a → h ((f ᵒ 𝑨) a) ≡ (f ᵒ 𝑩) (h ∘ a)

 IsHom-op : ((fst 𝑨) → (fst 𝑩)) → Type (α ⊔ β)
 IsHom-op h = ∀ f → CompOp f h

 IsHom : ((fst 𝑨) → (fst 𝑩)) → Type (α ⊔ β)
 IsHom h = IsHom-rel h × IsHom-op h

 Hom : Type (α ⊔ β)
 Hom = Σ[ h ∈ ((fst 𝑨) → (fst 𝑩)) ] IsHom h

module _ {γ : Level} (𝑨 : Structure α 𝑅 ℓ₀ 𝐹){𝑩 : Structure β 𝑅 ℓ₀ 𝐹}(𝑪 : Structure γ 𝑅 ℓ₀ 𝐹) where

 ∘-IsHom-rel : {f : (fst 𝑨) → (fst 𝑩)}{g : (fst 𝑩) → (fst 𝑪)}
  →             IsHom-rel 𝑨 𝑩 f → IsHom-rel 𝑩 𝑪 g → IsHom-rel 𝑨 𝑪 (g ∘ f)
 ∘-IsHom-rel {f}{g} fhr ghr R a = λ z → ghr R (λ z₁ → f (a z₁)) (fhr R a z)

 ∘-IsHom-op : {f : (fst 𝑨) → (fst 𝑩)}{g : (fst 𝑩) → (fst 𝑪)}
  →            IsHom-op 𝑨 𝑩 f → IsHom-op 𝑩 𝑪 g → IsHom-op 𝑨 𝑪 (g ∘ f)
 ∘-IsHom-op {f}{g} fho gho 𝑓 a = cong g (fho 𝑓 a) ∙ gho 𝑓 (f ∘ a)

 ∘-IsHom : {f : (fst 𝑨) → (fst 𝑩)}{g : (fst 𝑩) → (fst 𝑪)}
  →         IsHom 𝑨 𝑩 f → IsHom 𝑩 𝑪 g → IsHom 𝑨 𝑪 (g ∘ f)
 ∘-IsHom {f} {g} fhro ghro = ihr , iho
  where
  ihr : IsHom-rel 𝑨 𝑪 (g ∘ f)
  ihr = ∘-IsHom-rel {f}{g} (fst fhro) (fst ghro)

  iho : IsHom-op 𝑨 𝑪 (g ∘ f)
  iho = ∘-IsHom-op {f}{g} (snd fhro) (snd ghro)

 ∘-hom : Hom 𝑨 𝑩  →  Hom 𝑩 𝑪  →  Hom 𝑨 𝑪
 ∘-hom (f , fh) (g , gh) = g ∘ f , ∘-IsHom {f}{g} fh gh


𝒾𝒹 : (𝑨 : Structure α 𝑅 ℓ₀ 𝐹) → Hom 𝑨 𝑨
𝒾𝒹 _ = id , (λ R a z → z)  , (λ f a → refl)  -- (λ R a → refl)

module _ (𝑨 : Structure α 𝑅 ℓ₀ 𝐹)(𝑩 : Structure β 𝑅 ℓ₀ 𝐹) where

 IsMon : ((fst 𝑨) → (fst 𝑩)) → Type (α ⊔ β)
 IsMon g = IsHom 𝑨 𝑩 g × IsInjective g

 Mon : Type (α ⊔ β)
 Mon = Σ[ g ∈ ((fst 𝑨) → (fst 𝑩)) ] IsMon g

 IsEpi : ((fst 𝑨) → (fst 𝑩)) → Type (α ⊔ β)
 IsEpi g = IsHom 𝑨 𝑩 g × IsSurjective g

 Epi : Type (α ⊔ β)
 Epi = Σ[ g ∈ ((fst 𝑨) → (fst 𝑩)) ] IsEpi g

Mon→Hom : (𝑨 : Structure α 𝑅 ℓ₀ 𝐹){𝑩 : Structure β 𝑅 ℓ₀ 𝐹} → Mon 𝑨 𝑩 → Hom 𝑨 𝑩
Mon→Hom _ ϕ = (fst ϕ) , fst (snd ϕ )

Epi→Hom : {𝑨 : Structure α 𝑅 ℓ₀ 𝐹}(𝑩 : Structure β 𝑅 ℓ₀ 𝐹 ) → Epi 𝑨 𝑩 → Hom 𝑨 𝑩
Epi→Hom _ ϕ = (fst ϕ) , fst (snd ϕ)

\end{code}


-- open Lift

-- 𝓁𝒾𝒻𝓉 : {α β : Level}{𝑨 : Structure α 𝑅 𝐹} → hom 𝑨 (Lift-str 𝑨 β)
-- 𝓁𝒾𝒻𝓉 = lift , 𝒾𝒹

-- 𝓁ℴ𝓌ℯ𝓇 : {α β : Level}{𝑨 : Structure α 𝑅 𝐹} → hom (Lift-str 𝑨 β) 𝑨
-- 𝓁ℴ𝓌ℯ𝓇 = lower , 𝒾𝒹

#### <a id="kernels-of-homomorphisms">Kernels of homomorphisms</a>

The kernel of a homomorphism is a congruence relation and conversely for every congruence relation θ, there exists a homomorphism with kernel θ (namely, that canonical projection onto the quotient modulo θ).

\begin{code}


-- Our first use of the function extensionality THEOREM of Cubical Agda!

module _ {𝑨 : Structure α 𝑅 ℓ₀ 𝐹}{𝑩 : Structure ℓ₀ 𝑅 ℓ₀ 𝐹} {wd : swelldef ℓ₀} where
 Homker-comp : (h : Hom 𝑨 𝑩) → Compatible 𝑨 (ker (fst h))
 Homker-comp h f {u}{v} kuv = ((fst h) ((f ᵒ 𝑨) u))  ≡⟨(snd (snd h)) f u ⟩
                              ((f ᵒ 𝑩)((fst h) ∘ u)) ≡⟨ wd (f ᵒ 𝑩) ((fst h) ∘ u) ((fst h) ∘ v) kuv ⟩
                              ((f ᵒ 𝑩)((fst h) ∘ v)) ≡⟨((snd (snd h)) f v)⁻¹ ⟩
                              ((fst h)((f ᵒ 𝑨) v))   ∎

 KerCon : Hom 𝑨 𝑩 → Con 𝑨
 KerCon h = θ , Cθ
  where
  θ : Equivalence ∣ 𝑨 ∣
  θ = ker ∣ h ∣ , ker-IsEquivalence ∣ h ∣
  Cθ : Compatible 𝑨 ∣ θ ∣
  Cθ = Homker-comp h

\end{code}

With this congruence we construct the corresponding quotient, along with some syntactic sugar to denote it.

\begin{code}

module _ {𝑨 : Structure α 𝑅 ℓ₀ 𝐹} {wd : swelldef ℓ₀} where
 KerQuo : {𝑩 : Structure ℓ₀ 𝑅 ℓ₀ 𝐹} → Hom 𝑨 𝑩 → Structure (lsuc ℓ₀ ⊔ α) 𝑅 ℓ₀ 𝐹
 KerQuo {𝑩 = 𝑩} h = 𝑨 ╱ KerCon{𝑨 = 𝑨}{𝑩 = 𝑩}{wd = wd} h
 -- _╱_ : (𝑩 : Structure{ρ} 𝑅 𝐹 {β}) → Con{ρ} 𝑩 → Structure{ρ} 𝑅 𝐹 {lsuc ρ ⊔ β}

-- module _ {α β ρ ρ : Level} {𝑨 : Structure {ρ} 𝑅 𝐹 {α}} where

 -- kerquo : {𝑩 : Structure {ρ} 𝑅 𝐹 {β}} → hom 𝑨 𝑩 → Structure {ρ} 𝑅 𝐹 {lsuc ρ ⊔ α} --  {𝓤 ⊔ lsuc 𝓦}
 -- kerquo {𝑩 = 𝑩} h = 𝑨 ╱ {!kercon h!} -- (kercon {𝑩 = 𝑩} h)


-- ker[_⇒_]_ : (𝑨 : Structure{ρ} 𝑅 𝐹 {α})(𝑩 : Structure{ρ} 𝑅 𝐹 {β}) → hom 𝑨 𝑩 → Structure 𝑅 𝐹
-- ker[ 𝑨 ⇒ 𝑩 ] h = kerquo {𝑩 = 𝑩} h

\end{code}

Thus, given `h : hom 𝑨 𝑩`, we can construct the quotient of `𝑨` modulo the kernel of `h`, and the syntax for this quotient in the [UniversalAlgebra][] library is `𝑨 [ 𝑩 ]/ker h ↾ fe`.



#### <a id="the-canonical-projection">The canonical projection</a>

Given an algebra `𝑨` and a congruence `θ`, the *canonical projection* is a map from `𝑨` onto `𝑨 ╱ θ` that is constructed, and proved epimorphic, as follows.


module _ {𝑩 : Structure 𝑅 𝐹 {β}} where
 open Image_∋_
 πepi : (θ : Con{α} 𝑩) → epi 𝑩 (𝑩 ╱ θ)
 πepi θ = (λ a → ⟪ a / ∣ θ ∣ ⟫) , (γrel , (λ _ _ → refl)) , cπ-is-epic  where  -- (λ _ _ → refl)
  γrel : IsHom-rel 𝑩 (𝑩 ╱ θ) (λ a → ⟪ a / ∣ θ ∣ ⟫)
  γrel R a x = {!!}
  cπ-is-epic : IsSurjective (λ a → ⟪ a / ∣ θ ∣ ⟫)
  cπ-is-epic (C , (a , Ca)) =  eq (C , (a , Ca)) a λ i → {!!} , {!!} -- Image_∋_.im a

\end{code}

In may happen that we don't care about the surjectivity of `πepi`, in which case would might prefer to work with the *homomorphic reduct* of `πepi`. This is obtained by applying `epi-to-hom`, like so.


 πhom : (θ : Con{𝓤}{𝓦} 𝑨) → hom 𝑨 (𝑨 ╱ θ)
 πhom θ = epi-to-hom (𝑨 ╱ θ) (πepi θ)

\end{code}


We combine the foregoing to define a function that takes 𝑆-algebras `𝑨` and `𝑩`, and a homomorphism `h : hom 𝑨 𝑩` and returns the canonical epimorphism from `𝑨` onto `𝑨 [ 𝑩 ]/ker h`. (Recall, the latter is the special notation we defined above for the quotient of `𝑨` modulo the kernel of `h`.)


 πker : (wd : swelldef 𝓥 𝓦){𝑩 : Algebra 𝓦 𝑆}(h : hom 𝑨 𝑩) → epi 𝑨 (ker[ 𝑨 ⇒ 𝑩 ] h ↾ wd)
 πker wd {𝑩} h = πepi (kercon wd {𝑩} h)

\end{code}

The kernel of the canonical projection of `𝑨` onto `𝑨 / θ` is equal to `θ`, but since equality of inhabitants of certain types (like `Congruence` or `Rel`) can be a tricky business, we settle for proving the containment `𝑨 / θ ⊆ θ`. Of the two containments, this is the easier one to prove; luckily it is also the one we need later.


 open IsCongruence

 ker-in-con : {wd : swelldef 𝓥 (𝓤 ⊔ lsuc 𝓦)}(θ : Con 𝑨)
  →           ∀ {x}{y} → ∣ kercon wd {𝑨 ╱ θ} (πhom θ) ∣ x y →  ∣ θ ∣ x y

 ker-in-con θ hyp = /-≡ θ hyp

\end{code}



#### <a id="product-homomorphisms">Product homomorphisms</a>

Suppose we have an algebra `𝑨`, a type `I : Type 𝓘`, and a family `ℬ : I → Algebra 𝓦 𝑆` of algebras.  We sometimes refer to the inhabitants of `I` as *indices*, and call `ℬ` an *indexed family of algebras*.

If in addition we have a family `𝒽 : (i : I) → hom 𝑨 (ℬ i)` of homomorphisms, then we can construct a homomorphism from `𝑨` to the product `⨅ ℬ` in the natural way.


module _ {𝓘 𝓦 : Level}{I : Type 𝓘}(ℬ : I → Algebra 𝓦 𝑆) where

 ⨅-hom-co : funext 𝓘 𝓦 → {𝓤 : Level}(𝑨 : Algebra 𝓤 𝑆) → (∀(i : I) → hom 𝑨 (ℬ i)) → hom 𝑨 (⨅ ℬ)
 ⨅-hom-co fe 𝑨 𝒽 = ((λ a i → ∣ 𝒽 i ∣ a)) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 𝒶)

\end{code}

The family `𝒽` of homomorphisms inhabits the dependent type `Π i ꞉ I , hom 𝑨 (ℬ i)`.  The syntax we use to represent this type is available to us because of the way `-Π` is defined in the [Type Topology][] library.  We like this syntax because it is very close to the notation one finds in the standard type theory literature.  However,
we could equally well have used one of the following alternatives, which may be closer to "standard Agda" syntax:

`Π λ i → hom 𝑨 (ℬ i)` &nbsp; or &nbsp; `(i : I) → hom 𝑨 (ℬ i)` &nbsp; or &nbsp; `∀ i → hom 𝑨 (ℬ i)`.

The foregoing generalizes easily to the case in which the domain is also a product of a family of algebras. That is, if we are given `𝒜 : I → Algebra 𝓤 𝑆 and ℬ : I → Algebra 𝓦 𝑆` (two families of `𝑆`-algebras), and `𝒽 :  Π i ꞉ I , hom (𝒜 i)(ℬ i)` (a family of homomorphisms), then we can construct a homomorphism from `⨅ 𝒜` to `⨅ ℬ` in the following natural way.


 ⨅-hom : funext 𝓘 𝓦 → {𝓤 : Level}(𝒜 : I → Algebra 𝓤 𝑆) → Π[ i ꞉ I ] hom (𝒜 i)(ℬ i) → hom (⨅ 𝒜)(⨅ ℬ)
 ⨅-hom fe 𝒜 𝒽 = (λ x i → ∣ 𝒽 i ∣ (x i)) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 (λ x → 𝒶 x i))

\end{code}



#### <a id="projections-out-of-products">Projection out of products</a>

Later we will need a proof of the fact that projecting out of a product algebra onto one of its factors is a homomorphism.


 ⨅-projection-hom : Π[ i ꞉ I ] hom (⨅ ℬ) (ℬ i)
 ⨅-projection-hom = λ x → (λ z → z x) , λ _ _ → refl

\end{code}

We could prove a more general result involving projections onto multiple factors, but so far the single-factor result has sufficed.





\end{code}















---------- The rest is not yet integrated ------------------------------------------------









(Notice, it is here that the `swelldef` postulate comes into play, and because it is needed to prove `homker-comp`, it is postulated by all the lemmas below that depend upon `homker-comp`.)

It is convenient to define a function that takes a homomorphism and constructs a congruence from its kernel.  We call this function `kercon`.


 kercon : swelldef 𝓥 𝓦 → {𝑩 : Algebra 𝓦 𝑆} → hom 𝑨 𝑩 → Con{𝓤}{𝓦} 𝑨
 kercon wd {𝑩} h = ker ∣ h ∣ , mkcon (ker-IsEquivalence ∣ h ∣)(homker-comp wd {𝑩} h)

\end{code}

With this congruence we construct the corresponding quotient, along with some syntactic sugar to denote it.


 kerquo : swelldef 𝓥 𝓦 → {𝑩 : Algebra 𝓦 𝑆} → hom 𝑨 𝑩 → Algebra (𝓤 ⊔ lsuc 𝓦) 𝑆
 kerquo wd {𝑩} h = 𝑨 ╱ (kercon wd {𝑩} h)


ker[_⇒_]_↾_ : (𝑨 : Algebra 𝓤 𝑆)(𝑩 : Algebra 𝓦 𝑆) → hom 𝑨 𝑩 → swelldef 𝓥 𝓦 → Algebra (𝓤 ⊔ lsuc 𝓦) 𝑆
ker[ 𝑨 ⇒ 𝑩 ] h ↾ wd = kerquo wd {𝑩} h

\end{code}

Thus, given `h : hom 𝑨 𝑩`, we can construct the quotient of `𝑨` modulo the kernel of `h`, and the syntax for this quotient in the [UniversalAlgebra][] library is `𝑨 [ 𝑩 ]/ker h ↾ fe`.



#### <a id="the-canonical-projection">The canonical projection</a>

Given an algebra `𝑨` and a congruence `θ`, the *canonical projection* is a map from `𝑨` onto `𝑨 ╱ θ` that is constructed, and proved epimorphic, as follows.


module _ {𝓤 𝓦 : Level}{𝑨 : Algebra 𝓤 𝑆} where
 πepi : (θ : Con{𝓤}{𝓦} 𝑨) → epi 𝑨 (𝑨 ╱ θ)
 πepi θ = (λ a → ⟪ a ⟫) , (λ _ _ → refl) , cπ-is-epic  where
  cπ-is-epic : IsSurjective (λ a → ⟪ a ⟫)
  cπ-is-epic (C , (a , refl)) =  Image_∋_.im a

\end{code}

In may happen that we don't care about the surjectivity of `πepi`, in which case would might prefer to work with the *homomorphic reduct* of `πepi`. This is obtained by applying `epi-to-hom`, like so.


 πhom : (θ : Con{𝓤}{𝓦} 𝑨) → hom 𝑨 (𝑨 ╱ θ)
 πhom θ = epi-to-hom (𝑨 ╱ θ) (πepi θ)

\end{code}


We combine the foregoing to define a function that takes 𝑆-algebras `𝑨` and `𝑩`, and a homomorphism `h : hom 𝑨 𝑩` and returns the canonical epimorphism from `𝑨` onto `𝑨 [ 𝑩 ]/ker h`. (Recall, the latter is the special notation we defined above for the quotient of `𝑨` modulo the kernel of `h`.)


 πker : (wd : swelldef 𝓥 𝓦){𝑩 : Algebra 𝓦 𝑆}(h : hom 𝑨 𝑩) → epi 𝑨 (ker[ 𝑨 ⇒ 𝑩 ] h ↾ wd)
 πker wd {𝑩} h = πepi (kercon wd {𝑩} h)

\end{code}

The kernel of the canonical projection of `𝑨` onto `𝑨 / θ` is equal to `θ`, but since equality of inhabitants of certain types (like `Congruence` or `Rel`) can be a tricky business, we settle for proving the containment `𝑨 / θ ⊆ θ`. Of the two containments, this is the easier one to prove; luckily it is also the one we need later.


 open IsCongruence

 ker-in-con : {wd : swelldef 𝓥 (𝓤 ⊔ lsuc 𝓦)}(θ : Con 𝑨)
  →           ∀ {x}{y} → ∣ kercon wd {𝑨 ╱ θ} (πhom θ) ∣ x y →  ∣ θ ∣ x y

 ker-in-con θ hyp = /-≡ θ hyp

\end{code}



#### <a id="product-homomorphisms">Product homomorphisms</a>

Suppose we have an algebra `𝑨`, a type `I : Type 𝓘`, and a family `ℬ : I → Algebra 𝓦 𝑆` of algebras.  We sometimes refer to the inhabitants of `I` as *indices*, and call `ℬ` an *indexed family of algebras*.

If in addition we have a family `𝒽 : (i : I) → hom 𝑨 (ℬ i)` of homomorphisms, then we can construct a homomorphism from `𝑨` to the product `⨅ ℬ` in the natural way.


module _ {𝓘 𝓦 : Level}{I : Type 𝓘}(ℬ : I → Algebra 𝓦 𝑆) where

 ⨅-hom-co : funext 𝓘 𝓦 → {𝓤 : Level}(𝑨 : Algebra 𝓤 𝑆) → (∀(i : I) → hom 𝑨 (ℬ i)) → hom 𝑨 (⨅ ℬ)
 ⨅-hom-co fe 𝑨 𝒽 = (λ a i → ∣ 𝒽 i ∣ a) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 𝒶)

\end{code}

The family `𝒽` of homomorphisms inhabits the dependent type `Π i ꞉ I , hom 𝑨 (ℬ i)`.  The syntax we use to represent this type is available to us because of the way `-Π` is defined in the [Type Topology][] library.  We like this syntax because it is very close to the notation one finds in the standard type theory literature.  However,
we could equally well have used one of the following alternatives, which may be closer to "standard Agda" syntax:

`Π λ i → hom 𝑨 (ℬ i)` &nbsp; or &nbsp; `(i : I) → hom 𝑨 (ℬ i)` &nbsp; or &nbsp; `∀ i → hom 𝑨 (ℬ i)`.

The foregoing generalizes easily to the case in which the domain is also a product of a family of algebras. That is, if we are given `𝒜 : I → Algebra 𝓤 𝑆 and ℬ : I → Algebra 𝓦 𝑆` (two families of `𝑆`-algebras), and `𝒽 :  Π i ꞉ I , hom (𝒜 i)(ℬ i)` (a family of homomorphisms), then we can construct a homomorphism from `⨅ 𝒜` to `⨅ ℬ` in the following natural way.


 ⨅-hom : funext 𝓘 𝓦 → {𝓤 : Level}(𝒜 : I → Algebra 𝓤 𝑆) → Π[ i ꞉ I ] hom (𝒜 i)(ℬ i) → hom (⨅ 𝒜)(⨅ ℬ)
 ⨅-hom fe 𝒜 𝒽 = (λ x i → ∣ 𝒽 i ∣ (x i)) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 (λ x → 𝒶 x i))

\end{code}



#### <a id="projections-out-of-products">Projection out of products</a>

Later we will need a proof of the fact that projecting out of a product algebra onto one of its factors is a homomorphism.


 ⨅-projection-hom : Π[ i ꞉ I ] hom (⨅ ℬ) (ℬ i)
 ⨅-projection-hom = λ x → (λ z → z x) , λ _ _ → refl

\end{code}

We could prove a more general result involving projections onto multiple factors, but so far the single-factor result has sufficed.


{% include UALib.Links.md %}









Detailed proofs.
```
 ∘-IsHom-rel : {f : ∣ 𝑨 ∣ → ∣ 𝑩 ∣}{g : ∣ 𝑩 ∣ → ∣ 𝑪 ∣}
  →             IsHom-rel 𝑨 𝑩 f → IsHom-rel 𝑩 𝑪 g → IsHom-rel 𝑨 𝑪 (g ∘ f)
 ∘-IsHom-rel {f}{g} fhr ghr R a = pf
  where
  pf : ((R ʳ 𝑨) a) ≡ (R ʳ 𝑪)(g ∘ f ∘ a)
  pf = (R ʳ 𝑨) a          ≡⟨ fhr R a ⟩
       (R ʳ 𝑩)(f ∘ a)     ≡⟨ ghr R (f ∘ a)⟩
       (R ʳ 𝑪)(g ∘ f ∘ a) ∎

 ∘-IsHom-op : {f : ∣ 𝑨 ∣ → ∣ 𝑩 ∣}{g : ∣ 𝑩 ∣ → ∣ 𝑪 ∣}
  →            IsHom-op 𝑨 𝑩 f → IsHom-op 𝑩 𝑪 g → IsHom-op 𝑨 𝑪 (g ∘ f)
 ∘-IsHom-op {f}{g} fho gho 𝑓 a = pf
  where
  pf : (g ∘ f) ((𝑓 ᵒ 𝑨) a) ≡ (𝑓 ᵒ 𝑪) (λ x → (g ∘ f) (a x))
  pf = (g ∘ f) ((𝑓 ᵒ 𝑨) a) ≡⟨ cong g (fho 𝑓 a)⟩
       g ((𝑓 ᵒ 𝑩)(f ∘ a)) ≡⟨ gho 𝑓 (f ∘ a) ⟩
       (𝑓 ᵒ 𝑪) (λ x → (g ∘ f) (a x)) ∎


```
  hghr : ∀ R a → ((R ʳ 𝑨) a) ≡ (R ʳ 𝑪)(h ∘ g ∘ a)
  hghr R a = (R ʳ 𝑨) a          ≡⟨ ghr R a ⟩
             (R ʳ 𝑩)(g ∘ a)     ≡⟨ hhr R (g ∘ a)⟩
             (R ʳ 𝑪)(h ∘ g ∘ a) ∎

  hgho : ∀ 𝑓 a → (h ∘ g)((𝑓 ᵒ 𝑨) a) ≡ (𝑓 ᵒ 𝑪)(h ∘ g ∘ a)
  hgho 𝑓 a = (h ∘ g)((𝑓 ᵒ 𝑨) a) ≡⟨ cong h (gho 𝑓 a)⟩
             h ((𝑓 ᵒ 𝑩)(g ∘ a)) ≡⟨ hho 𝑓 (g ∘ a)⟩
             (𝑓 ᵒ 𝑪)(h ∘ g ∘ a) ∎
open import Agda.Primitive using (_⊔_; lsuc)


open import Cubical.Core.Primitives using (_≡_; Type; Level; _,_; Σ-syntax;  i0; i1; fst; snd)
open import Cubical.Foundations.Prelude using (refl; sym; _∙_; funExt; cong; _∎; _≡⟨_⟩_)
open import Cubical.Foundations.Function using (_∘_)
open import Cubical.Data.Sigma.Base using (_×_)
open import Cubical.HITs.TypeQuotients -- .Base where


-- Imports from the Agda Universal Algebra Library
open import structures.basic using (Signature; Structure; _ʳ_; _ᵒ_; compatible)
open import overture.preliminaries using (id; _⁻¹; ∣_∣; ∥_∥)
open import overture.inverses using (IsInjective; IsSurjective; Image_∋_; im)
open import relations.discrete using (ker; ker')
open import relations.quotients using (ker-IsEquivalence; ⟪_/_⟫)

