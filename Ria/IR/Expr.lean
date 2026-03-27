import Ria.Array

namespace Ria.IR

inductive Ty where
  | float : Ty
  | array : List Nat → Ty
  deriving DecidableEq, BEq

@[reducible] def Ty.denote : Ty → Type
  | .float => Float
  | .array shape => Ria.Array shape

instance : Inhabited (Ty.denote t) := by
  cases t with
  | float => exact ⟨0.0⟩
  | array shape => exact ⟨⟨ByteArray.emptyWithCapacity 0, by sorry⟩⟩

inductive Expr (V : Ty → Type) : Ty → Type where
  | var     : V a → Expr V a
  | lett    : Expr V a → (V a → Expr V b) → Expr V b
  | litF    : Float → Expr V .float
  | addf    : Expr V .float → Expr V .float → Expr V .float
  | mulf    : Expr V .float → Expr V .float → Expr V .float
  | subf    : Expr V .float → Expr V .float → Expr V .float
  | literal : Ria.Array shape → Expr V (.array shape)
  | map     : (Float → Float) → Expr V (.array s) → Expr V (.array s)
  | zipWith : (Float → Float → Float) → Expr V (.array s)
              → Expr V (.array s) → Expr V (.array s)
  | reduce  : (Float → Float → Float) → Float
              → Expr V (.array [n]) → Expr V .float
  | scale   : Expr V .float → Expr V (.array s) → Expr V (.array s)
  | dot     : Expr V (.array [n]) → Expr V (.array [n]) → Expr V .float
  | matmul  : Expr V (.array [m, k]) → Expr V (.array [k, n])
              → Expr V (.array [m, n])

def ClosedExpr (a : Ty) := ∀ V, Expr V a

end Ria.IR
