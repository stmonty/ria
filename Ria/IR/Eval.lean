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

def run (e : ClosedExpr a) : Ty.denote a :=
  eval (e Ty.denote)

end Ria.IR
