---
layout: default
title : sturctures.products module (cubical-structures library)
date : 2021-05-11
author: William DeMeo
---

### Product structures

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-} -- cubical #-}

module structures.products  where

open import agda-imports
open import structures.base
open import overture.preliminaries
open import relations.continuous


module _ {α ρ τ ι : Level}{𝑅 𝐹 : Signature} where

 ⨅ : (ℑ : Type ι)(𝒜 : ℑ → Structure α 𝑅 ρ 𝐹) → Structure (α ⊔ ι) 𝑅 (ρ ⊔ ι) 𝐹
 ⨅ ℑ 𝒜 = Π[ 𝔦 ∈ ℑ ] ∣ 𝒜 𝔦 ∣ ,                     -- domain of the product structure
          ( λ r a → ∀ 𝔦 → (r ʳ 𝒜 𝔦) λ x → a x 𝔦 ) , -- interpretations of relations
          ( λ 𝑓 a 𝔦 → (𝑓 ᵒ 𝒜 𝔦) λ x → a x 𝔦 )        -- interpretations of  operations

module _ {α ρ τ : Level}{𝑅 𝐹 : Signature}{𝒦 : Pred (Structure α 𝑅 ρ 𝐹) τ} where

 ℑ : Type (lsuc α ⊔ lsuc ρ ⊔ τ) -- (lsuc (α ⊔ ρ)) -- (lsuc α ⊔ lsuc ρ ⊔ ρ)
 ℑ = Σ[ 𝑨 ∈ Structure α 𝑅 ρ 𝐹 ] (𝑨 ∈ 𝒦)

 𝔄 : ℑ → Structure α 𝑅 ρ 𝐹
 𝔄 𝔦 = ∣ 𝔦 ∣

 class-prod : Structure  (τ ⊔ lsuc (α ⊔ ρ)) 𝑅 (τ ⊔ lsuc (α ⊔ ρ)) 𝐹
 class-prod = ⨅ ℑ 𝔄

\end{code}

If `p : 𝑨 ∈ 𝒦`, we view the pair `(𝑨 , p) ∈ ℑ` as an *index* over the class, so we can think of `𝔄 (𝑨 , p)` (which is simply `𝑨`) as the projection of the product `⨅ 𝔄` onto the `(𝑨 , p)`-th component.


#### Representing structures with record types

\begin{code}

module _ {α ρ ι : Level}{𝑅 𝐹 : signature} where
 open structure

 ⨅' : (ℑ : Type ι)(𝒜 : ℑ → structure α 𝑅 ρ 𝐹) → structure (α ⊔ ι) 𝑅 (ρ ⊔ ι) 𝐹
 ⨅' ℑ ℬ = record
           { univ = Π[ 𝔦 ∈ ℑ ] univ (ℬ 𝔦)                      -- domain of the product structure
           ; srel = λ r a → ∀ i → (srel (ℬ i) r)(λ x → a x i) -- interpretations of relations
           ; sop  = λ f a i → (sop (ℬ i) f) (λ x → a x i)     -- interpretations of operations
           }

module _ {α ρ ι : Level}{𝑅 𝐹 : signature} {𝒦 : Pred (structure α 𝑅 ρ 𝐹) (lsuc ?)} where

  ℑ' : Type ?
  ℑ' = Σ[ 𝑨 ∈ structure α 𝑅 ρ 𝐹 ] 𝑨 ∈ 𝒦

  𝔄' : ℑ' → structure α 𝑅 ρ 𝐹
  𝔄' 𝔦 = ∣ 𝔦 ∣

  class-prod' : structure α 𝑅 ρ 𝐹
  class-prod' = ⨅' ℑ' 𝔄'

\end{code}

-------------------------------------------------------------------
--                        THE END                                --
-------------------------------------------------------------------

















-- Imports from the Agda (Builtin) and the Agda Standard Library
-- open import Level renaming (suc to lsuc; zero to lzero)
-- open import Data.Product using (_,_; Σ; _×_)
-- open import Relation.Unary using (Pred; _∈_)

-- Imports from the Agda Universal Algebra Library
-- open import Overture.Preliminaries using (Type; 𝓘; 𝓞; 𝓤; 𝓥; 𝓦; Π; -Π; -Σ; _≡⟨_⟩_; _∎; _⁻¹; 𝑖𝑑; ∣_∣; ∥_∥)
-- open import Algebras.Basic


-- open import Relation.Binary using (Rel; IsEquivalence)
-- open import Relation.Binary.PropositionalEquality.Core using (trans)

-- open import Agda.Primitive using (_⊔_; lsuc)
-- open import Relation.Unary using (Pred; _∈_)

-- open import Cubical.Core.Primitives using (_≡_; Type; Level; Σ-syntax;  i0; i1; fst; snd; _,_)
-- open import Cubical.Foundations.Prelude using (refl; sym; _∙_; funExt; cong; _∎; _≡⟨_⟩_)
-- open import Cubical.Foundations.Function using (_∘_)
-- open import Cubical.Data.Sigma.Base using (_×_)

-- -- Imports from the Agda Universal Algebra Library
-- open import overture.preliminaries using (Π; Π-syntax; _⁻¹; id; ∣_∣)
-- open import structures.basic using (Signature; Structure; _ʳ_; _ᵒ_; signature; structure)
-- open import overture.inverses using (IsInjective; IsSurjective)
-- open import relations.discrete using (ker)


