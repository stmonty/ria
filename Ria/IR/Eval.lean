import Ria.IR.Expr
import Ria.Combinators

namespace Ria.IR

partial def eval : Expr Ty.denote a → Ty.denote a
  | .var x            => x
  | .lett e f         => eval (f (eval e))
  | .litF x           => x
  | .addf e1 e2       => eval e1 + eval e2
  | .mulf e1 e2       => eval e1 * eval e2
  | .subf e1 e2       => eval e1 - eval e2
  | .literal a        => a
  | .map fn e         => Ria.Array.map fn (eval e)
  | .zipWith fn e1 e2 => Ria.Array.zipWith fn (eval e1) (eval e2)
  | .reduce fn init e => Ria.Array.reduce fn init (eval e)
  | .scale e1 e2      => Ria.Array.scale (eval e1) (eval e2)
  | .dot e1 e2        => Ria.Array.dot (eval e1) (eval e2)
  | .matmul e1 e2     => Ria.Array.matmul (eval e1) (eval e2) (by sorry)
  | .negf e           => - (eval e)
  | .divf e1 e2       => eval e1 / eval e2
  | .emul e1 e2       => Ria.Array.zipWith (· * ·) (eval e1) (eval e2)
  | .bcast (s := s) e => Ria.Array.fill s (eval e) .float64 (by sorry)
  | .tpose (m := m) (n := n) e =>
    let a := eval e
    Ria.Array.tabulate [n, m] .float64 fun idx =>
      let outRow := idx.val / m
      let outCol := idx.val % m
      a.get2d ⟨outCol, by sorry⟩ ⟨outRow, by sorry⟩

def run (e : ClosedExpr a) : Ty.denote a :=
  eval (e Ty.denote)

end Ria.IR
