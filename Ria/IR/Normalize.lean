import Ria.IR.Expr
import Ria.IR.Fusion

namespace Ria.IR

abbrev NormV (_ : Ty) := String

private instance : Inhabited (Expr V a) := by
  cases a with
  | float => exact ⟨.litF 0.0⟩
  | array shape => exact ⟨.literal ⟨ByteArray.emptyWithCapacity 0, by sorry⟩⟩

partial def inline : Expr (fun a => Expr NormV a) a → Expr NormV a
  | .var x         => x
  | .lett e body   => inline (body (inline e))
  | .litF x        => .litF x
  | .literal a     => .literal a
  | .addf e1 e2    => .addf (inline e1) (inline e2)
  | .mulf e1 e2    => .mulf (inline e1) (inline e2)
  | .subf e1 e2    => .subf (inline e1) (inline e2)
  | .map f e       => .map f (inline e)
  | .zipWith f e1 e2 => .zipWith f (inline e1) (inline e2)
  | .reduce f init e => .reduce f init (inline e)
  | .scale e1 e2   => .scale (inline e1) (inline e2)
  | .dot e1 e2     => .dot (inline e1) (inline e2)
  | .matmul e1 e2  => .matmul (inline e1) (inline e2)

partial def toAnyV : Expr NormV a → Expr V a
  | .litF x        => .litF x
  | .literal a     => .literal a
  | .addf e1 e2    => .addf (toAnyV e1) (toAnyV e2)
  | .mulf e1 e2    => .mulf (toAnyV e1) (toAnyV e2)
  | .subf e1 e2    => .subf (toAnyV e1) (toAnyV e2)
  | .map f e       => .map f (toAnyV e)
  | .zipWith f e1 e2 => .zipWith f (toAnyV e1) (toAnyV e2)
  | .reduce f init e => .reduce f init (toAnyV e)
  | .scale e1 e2   => .scale (toAnyV e1) (toAnyV e2)
  | .dot e1 e2     => .dot (toAnyV e1) (toAnyV e2)
  | .matmul e1 e2  => .matmul (toAnyV e1) (toAnyV e2)
  | .var _         => panic! "unexpected variable after normalization"
  | .lett _ _      => panic! "unexpected let after normalization"

def normalize (e : ClosedExpr a) : ClosedExpr a :=
  fun _ => toAnyV (fuse (inline (e (fun a => Expr NormV a))))

end Ria.IR
