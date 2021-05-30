---
layout: default
title : homs.base
date : 2021-05-22
author: William DeMeo
---

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-} -- cubical #-}

open import structures.base


module homs.base {𝑅 𝐹 : signature} where

open import agda-imports
open import overture.preliminaries
open import overture.inverses
open import relations.discrete
open import relations.quotients
open import relations.extensionality
open import Relation.Binary.PropositionalEquality renaming (sym to ≡-sym; trans to ≡-trans) using ()

open import structures.congruences {𝑅 = 𝑅}{𝐹 = 𝐹}

private variable  α β γ ρ ρ₀ ρ₁ ρ₂ : Level


-- Development for (the record type representation of) structures 

-- module _ (𝑨 : structure {α} 𝑅 {ℓ₀} 𝐹)(𝑩 : structure {β} 𝑅 {ℓ₀} 𝐹) where
module _ (𝑨 : structure {α} 𝑅 {ρ₀} 𝐹)(𝑩 : structure {β} 𝑅 {ρ₁} 𝐹) where

 comm-rel : (symbol 𝑅) → ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ ρ₀ ⊔ ρ₁)
 comm-rel 𝑟 h = ∀ a → ((rel 𝑨) 𝑟 a) → ((rel 𝑩) 𝑟) (h ∘ a)

 is-hom-rel : ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ ρ₀ ⊔ ρ₁)
 is-hom-rel h = ∀ R →  comm-rel R h

 comm-op : (symbol 𝐹) → ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ β)
 comm-op f h = ∀ a → h (((op 𝑨) f) a) ≡ ((op 𝑩) f) (h ∘ a)


 is-hom-op : ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ β)
 is-hom-op h = ∀ f → comm-op f h

 is-hom : ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 is-hom h = is-hom-rel h × is-hom-op h

 hom : Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 hom = Σ[ h ∈ ((carrier 𝑨) → (carrier 𝑩)) ] is-hom h

module _ {γ : Level} (𝑨 : structure {α} 𝑅 {ρ₀} 𝐹){𝑩 : structure {β} 𝑅 {ρ₁} 𝐹}(𝑪 : structure {γ} 𝑅 {ρ₂} 𝐹) where

 ∘-is-hom-rel : {f : (carrier 𝑨) → (carrier 𝑩)}{g : (carrier 𝑩) → (carrier 𝑪)}
  →             is-hom-rel 𝑨 𝑩 f → is-hom-rel 𝑩 𝑪 g → is-hom-rel 𝑨 𝑪 (g ∘ f)
 ∘-is-hom-rel {f}{g} fhr ghr R a = λ z → ghr R (λ z₁ → f (a z₁)) (fhr R a z)

 ∘-is-hom-op : {f : (carrier 𝑨) → (carrier 𝑩)}{g : (carrier 𝑩) → (carrier 𝑪)}
  →            is-hom-op 𝑨 𝑩 f → is-hom-op 𝑩 𝑪 g → is-hom-op 𝑨 𝑪 (g ∘ f)
 ∘-is-hom-op {f}{g} fho gho 𝑓 a = cong g (fho 𝑓 a) ∙ gho 𝑓 (f ∘ a)

 ∘-is-hom : {f : (carrier 𝑨) → (carrier 𝑩)}{g : (carrier 𝑩) → (carrier 𝑪)}
  →         is-hom 𝑨 𝑩 f → is-hom 𝑩 𝑪 g → is-hom 𝑨 𝑪 (g ∘ f)
 ∘-is-hom {f} {g} fhro ghro = ihr , iho
  where
  ihr : is-hom-rel 𝑨 𝑪 (g ∘ f)
  ihr = ∘-is-hom-rel {f}{g} (fst fhro) (fst ghro)

  iho : is-hom-op 𝑨 𝑪 (g ∘ f)
  iho = ∘-is-hom-op {f}{g} (snd fhro) (snd ghro)

 ∘-hom : hom 𝑨 𝑩  →  hom 𝑩 𝑪  →  hom 𝑨 𝑪
 ∘-hom (f , fh) (g , gh) = g ∘ f , ∘-is-hom {f}{g} fh gh


𝒾𝒹 : (𝑨 : structure {α} 𝑅 {ρ} 𝐹) → hom 𝑨 𝑨
𝒾𝒹 _ = id , (λ R a z → z)  , (λ f a → refl)  -- (λ R a → refl)

module _ (𝑨 : structure {α} 𝑅 {ρ₀} 𝐹)(𝑩 : structure {β} 𝑅 {ρ₁} 𝐹) where

 is-mon : ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 is-mon g = is-hom 𝑨 𝑩 g × IsInjective g

 mon : Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 mon = Σ[ g ∈ ((carrier 𝑨) → (carrier 𝑩)) ] is-mon g

 mon→hom : mon → hom 𝑨 𝑩
 mon→hom ϕ = (fst ϕ) , fst (snd ϕ )


 is-epi : ((carrier 𝑨) → (carrier 𝑩)) → Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 is-epi g = is-hom 𝑨 𝑩 g × IsSurjective g

 epi : Type (α ⊔ ρ₀ ⊔ β ⊔ ρ₁)
 epi = Σ[ g ∈ ((carrier 𝑨) → (carrier 𝑩)) ] is-epi g

 epi→hom : epi → hom 𝑨 𝑩
 epi→hom ϕ = (fst ϕ) , fst (snd ϕ)

-- mon→hom : (𝑨 : structure {α} 𝑅 {ℓ₀} 𝐹){𝑩 : structure {β} 𝑅 {ℓ₀} 𝐹} → mon 𝑨 𝑩 → hom 𝑨 𝑩
-- mon→hom _ ϕ = (fst ϕ) , fst (snd ϕ )

-- epi→hom : {𝑨 : structure {α} 𝑅 {ℓ₀} 𝐹}(𝑩 : structure {β} 𝑅 {ℓ₀} 𝐹 ) → epi 𝑨 𝑩 → hom 𝑨 𝑩
-- epi→hom _ ϕ = (fst ϕ) , fst (snd ϕ)

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

module _ {wd : swelldef β}{𝑨 : structure {α} 𝑅 {β ⊔ ρ₀} 𝐹}{𝑩 : structure {β} 𝑅 {ρ₁} 𝐹} where

 homker-comp : (h : hom 𝑨 𝑩) → compatible 𝑨 (ker (fst h))
 homker-comp h f {u}{v} kuv = ((fst h) (((op 𝑨)f) u))  ≡⟨(snd (snd h)) f u ⟩
                              ((op 𝑩) f)((fst h) ∘ u) ≡⟨ wd ((op 𝑩)f) ((fst h) ∘ u) ((fst h) ∘ v) kuv ⟩
                              ((op 𝑩) f)((fst h) ∘ v) ≡⟨((snd (snd h)) f v)⁻¹ ⟩
                              (fst h)(((op 𝑨)f) v)   ∎


 kerlift-comp : (h : hom 𝑨 𝑩) → compatible 𝑨 (kerlift (fst h) (α ⊔ ρ₀) )
 kerlift-comp (h , hhom) f {u}{v} kuv = lift goal
  where
  goal : h (op 𝑨 f u) ≡ h (op 𝑨 f v)
  goal = h (op 𝑨 f u)    ≡⟨ snd hhom f u ⟩
         (op 𝑩 f)(h ∘ u) ≡⟨ wd (op 𝑩 f)(h ∘ u)(h ∘ v)(lower ∘ kuv) ⟩
         (op 𝑩 f)(h ∘ v) ≡⟨ (snd hhom f v)⁻¹ ⟩
         h (op 𝑨 f v)    ∎

 kercon : hom 𝑨 𝑩 → con 𝑨
 kercon (h , hhom) = ((λ x y → Lift (α ⊔ ρ₀) (h x ≡ h y)) , goal) , kerlift-comp (h , hhom)
  where
  goal : IsEquivalence (λ x y → Lift (α ⊔ ρ₀) (h x ≡ h y)) -- (ker ∣ h ∣ , ker-IsEquivalence ∣ h ∣) , homker-comp wd {𝑨}{𝑩} h
  goal = record { refl = lift refl ; sym = λ p → lift (≡-sym (lower p)) ; trans = λ p q → lift (≡-trans (lower p) (lower q)) }

 kerquo : hom 𝑨 𝑩 → structure {lsuc (α ⊔ β ⊔ ρ₀)} 𝑅 {β ⊔ ρ₀} 𝐹
 kerquo h = 𝑨 ╱ (kercon h)

-- module _ {𝑨 : structure {ℓ₀} 𝑅 𝐹 {ℓ₀}} where

--  kerquo : {𝑩 : structure {ℓ₀} 𝑅 {ℓ₀} 𝐹} → hom 𝑨 𝑩 → structure {ℓ₀} 𝑅 {ℓ₀} 𝐹 --  {𝓤 ⊔ lsuc 𝓦}
--  kerquo {𝑩 = 𝑩} h = 𝑨 ╱ {!kercon h!} -- (kercon {𝑩 = 𝑩} h)

-- private variable  α β γ ρ ρ₀ ρ₁ ρ₂ : Level

ker[_⇒_] : (𝑨 : structure {α} 𝑅 {β ⊔ ρ₀} 𝐹)(𝑩 : structure {β} 𝑅 {ρ₁} 𝐹){wd : swelldef β} → hom 𝑨 𝑩 → structure 𝑅 𝐹
ker[_⇒_] {ρ₀ = ρ₀} 𝑨 𝑩 {wd} h = kerquo{ρ₀ = ρ₀}{wd = wd}{𝑨}{𝑩 = 𝑩} h


\end{code}

#### <a id="the-canonical-projection">The canonical projection</a>

Given an algebra `𝑨` and a congruence `θ`, the *canonical projection* is a map from `𝑨` onto `𝑨 ╱ θ` that is constructed, and proved epimorphic, as follows.

\begin{code}



module _ {𝑨 : structure {α} 𝑅 {ρ} 𝐹} where
 open Image_∋_
 πepi : (θ : con 𝑨) → epi 𝑨 (𝑨 ╱ θ)
 πepi θ = (λ a → ⟪ a / ∣ θ ∣ ⟫) , (γrel , (λ _ _ → refl)) , cπ-is-epic
  where  -- (λ _ _ → refl)
  γrel : is-hom-rel 𝑨 (𝑨 ╱ θ) (λ a → ⟪ a / ∣ θ ∣ ⟫)
  γrel R a x = x
  cπ-is-epic : IsSurjective (λ a → ⟪ a / ∣ θ ∣ ⟫)
  cπ-is-epic (C , R-block block-u refl) = eq block-u refl

 πhom : (θ : con 𝑨) → hom 𝑨 (𝑨 ╱ θ)
 πhom θ = epi→hom 𝑨 (𝑨 ╱ θ) (πepi θ)

module _ {wd : swelldef β}{𝑨 : structure {α} 𝑅 {β ⊔ ρ₀} 𝐹}{𝑩 : structure {β} 𝑅 {ρ₁} 𝐹} where

 πker : (h : hom 𝑨 𝑩) → epi 𝑨 (ker[_⇒_]{ρ₀ = ρ₀} 𝑨 𝑩 {wd} h)
 πker h = πepi (kercon{ρ₀ = ρ₀} {wd = wd} {𝑨}{𝑩} h)

-- open IsCongruence

 -- /≡-elim : {𝑨 : structure {α} 𝑅 {ρ} 𝐹}( (θ , _ ) : con 𝑨){u v : carrier 𝑨} → ⟪_/_⟫ {α}{ρ} u θ ≡ ⟪ v / θ ⟫ → ∣ θ ∣ u v
 -- /≡-elim θ {u}{v} x =  ⟪⟫≡-elim u v x

 -- ker-in-con : (θ : con 𝑨) → ∀ {x}{y} → ∣ kercon{ρ₀ = ρ₀} {wd = wd} {𝑨}{𝑨 ╱ θ} (πhom θ) ∣ x y →  ∣ θ ∣ x y
 -- ker-in-con θ hyp = /≡-elim θ hyp

\end{code}



#### <a id="product-homomorphisms">Product homomorphisms</a>

Suppose we have an algebra `𝑨`, a type `I : Type 𝓘`, and a family `ℬ : I → Algebra 𝓦 𝑆` of algebras.  We sometimes refer to the inhabitants of `I` as *indices*, and call `ℬ` an *indexed family of algebras*.

If in addition we have a family `𝒽 : (i : I) → hom 𝑨 (ℬ i)` of homomorphisms, then we can construct a homomorphism from `𝑨` to the product `⨅ ℬ` in the natural way.

\begin{code}
module _ {I : Arity}(ℬ : I → structure {β} 𝑅 {ρ₁} 𝐹) where

 ⨅-hom-co : funext ? ? → {α : Level}(𝑨 : structure {α} 𝑅 {ρ₀} 𝐹) → (∀(i : I) → hom 𝑨 (ℬ i)) → hom 𝑨 (⨅ ℬ)
 ⨅-hom-co fe 𝑨 𝒽 = ? -- ((λ a i → ∣ 𝒽 i ∣ a)) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 𝒶)

 -- OLD VERSION
 -- ⨅-hom-co : funext 𝓘 𝓦 → {𝓤 : Level}(𝑨 : Algebra 𝓤 𝑆) → (∀(i : I) → hom 𝑨 (ℬ i)) → hom 𝑨 (⨅ ℬ)
 -- ⨅-hom-co fe 𝑨 𝒽 = ((λ a i → ∣ 𝒽 i ∣ a)) , (λ 𝑓 𝒶 → fe λ i → ∥ 𝒽 i ∥ 𝑓 𝒶)
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

Thus, given `h : hom 𝑨 𝑩`, we can construct the quotient of `𝑨` modulo the kernel of `h`, and the syntax for this quotient in the [carrierersalAlgebra][] library is `𝑨 [ 𝑩 ]/ker h ↾ fe`.



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
 ∘-is-hom-rel : {f : ∣ 𝑨 ∣ → ∣ 𝑩 ∣}{g : ∣ 𝑩 ∣ → ∣ 𝑪 ∣}
  →             is-hom-rel 𝑨 𝑩 f → is-hom-rel 𝑩 𝑪 g → is-hom-rel 𝑨 𝑪 (g ∘ f)
 ∘-is-hom-rel {f}{g} fhr ghr R a = pf
  where
  pf : ((R ʳ 𝑨) a) ≡ (R ʳ 𝑪)(g ∘ f ∘ a)
  pf = (R ʳ 𝑨) a          ≡⟨ fhr R a ⟩
       (R ʳ 𝑩)(f ∘ a)     ≡⟨ ghr R (f ∘ a)⟩
       (R ʳ 𝑪)(g ∘ f ∘ a) ∎

 ∘-is-hom-op : {f : ∣ 𝑨 ∣ → ∣ 𝑩 ∣}{g : ∣ 𝑩 ∣ → ∣ 𝑪 ∣}
  →            is-hom-op 𝑨 𝑩 f → is-hom-op 𝑩 𝑪 g → is-hom-op 𝑨 𝑪 (g ∘ f)
 ∘-is-hom-op {f}{g} fho gho 𝑓 a = pf
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


-- Imports from the Agda carrierersal Algebra Library
open import structures.basic using (Signature; Structure; _ʳ_; _ᵒ_; compatible)
open import overture.preliminaries using (id; _⁻¹; ∣_∣; ∥_∥)
open import overture.inverses using (IsInjective; IsSurjective; Image_∋_; im)
open import relations.discrete using (ker; ker')
open import relations.quotients using (ker-IsEquivalence; ⟪_/_⟫)

