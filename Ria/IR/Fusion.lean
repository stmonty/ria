import Ria.IR.Expr

namespace Ria.IR

partial def fuse : Expr V a → Expr V a
  | .var x     => .var x
  | .litF x    => .litF x
  | .literal a => .literal a
  | .lett e f => .lett (fuse e) (fun x => fuse (f x))
  | .addf e1 e2 => .addf (fuse e1) (fuse e2)
  | .mulf e1 e2 => .mulf (fuse e1) (fuse e2)
  | .subf e1 e2 => .subf (fuse e1) (fuse e2)
  | .map f (.map g x) => fuse (.map (f ∘ g) (fuse x))
  | .reduce op init (.map f x) =>
    .reduce (fun a b => op a (f b)) init (fuse x)
  | .zipWith f (.map g x) y =>
    fuse (.zipWith (fun a b => f (g a) b) (fuse x) (fuse y))
  | .zipWith f x (.map g y) =>
    fuse (.zipWith (fun a b => f a (g b)) (fuse x) (fuse y))
  | .map f x         => .map f (fuse x)
  | .zipWith f x y   => .zipWith f (fuse x) (fuse y)
  | .reduce op init x => .reduce op init (fuse x)
  | .scale e1 e2   => .scale (fuse e1) (fuse e2)
  | .dot e1 e2     => .dot (fuse e1) (fuse e2)
  | .matmul e1 e2  => .matmul (fuse e1) (fuse e2)

end Ria.IR
