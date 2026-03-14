import Ria.IR.Expr

namespace Ria.IR

/-- Bottom-up fusion pass. Rewrites the expression tree to eliminate
    intermediate arrays by composing combinators.

    Fusion rules:
    - map f (map g x)           → map (f ∘ g) x
    - reduce op init (map f x)  → reduce (fun a b => op a (f b)) init x
    - zipWith f (map g x) y     → zipWith (fun a b => f (g a) b) x y
    - zipWith f x (map g y)     → zipWith (fun a b => f a (g b)) x y

    Limitation: only fires on directly nested constructors,
    not through lett bindings. -/
partial def fuse : Expr V a → Expr V a
  -- Core: pass through
  | .var x     => .var x
  | .litF x    => .litF x
  | .literal a => .literal a

  -- Let-binding: fuse both sides
  | .lett e f => .lett (fuse e) (fun x => fuse (f x))

  -- Scalar ops: fuse children
  | .addf e1 e2 => .addf (fuse e1) (fuse e2)
  | .mulf e1 e2 => .mulf (fuse e1) (fuse e2)
  | .subf e1 e2 => .subf (fuse e1) (fuse e2)

  -- MAP-MAP FUSION: map f (map g x) → map (f ∘ g) x
  | .map f (.map g x) => fuse (.map (f ∘ g) (fuse x))

  -- REDUCE-MAP FUSION: reduce op init (map f x) → reduce (λ a b => op a (f b)) init x
  | .reduce op init (.map f x) =>
    .reduce (fun a b => op a (f b)) init (fuse x)

  -- ZIPWITH-MAP FUSION (left): zipWith f (map g x) y → zipWith (λ a b => f (g a) b) x y
  | .zipWith f (.map g x) y =>
    fuse (.zipWith (fun a b => f (g a) b) (fuse x) (fuse y))

  -- ZIPWITH-MAP FUSION (right): zipWith f x (map g y) → zipWith (λ a b => f a (g b)) x y
  | .zipWith f x (.map g y) =>
    fuse (.zipWith (fun a b => f a (g b)) (fuse x) (fuse y))

  -- Default: fuse children
  | .map f x         => .map f (fuse x)
  | .zipWith f x y   => .zipWith f (fuse x) (fuse y)
  | .reduce op init x => .reduce op init (fuse x)

  -- BLAS primitives: fuse children, but don't decompose
  | .scale e1 e2   => .scale (fuse e1) (fuse e2)
  | .dot e1 e2     => .dot (fuse e1) (fuse e2)
  | .matmul e1 e2  => .matmul (fuse e1) (fuse e2)

end Ria.IR
