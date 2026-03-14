import Ria.Array

namespace Ria.IR

/-- Types in the Ria IR. Just floats and shaped arrays. -/
inductive Ty where
  | float : Ty
  | array : List Nat → Ty
  deriving DecidableEq, BEq

/-- Map IR types to Lean types. -/
@[reducible] def Ty.denote : Ty → Type
  | .float => Float
  | .array shape => Ria.Array shape

instance : Inhabited (Ty.denote t) := by
  cases t with
  | float => exact ⟨0.0⟩
  | array shape => exact ⟨⟨FloatArray.emptyWithCapacity 0, by sorry⟩⟩

/-- PHOAS expression type. `V` is the variable representation —
    instantiate with `Ty.denote` for evaluation, or other types
    for printing/transformation. -/
inductive Expr (V : Ty → Type) : Ty → Type where
  -- Variables and let-binding
  | var     : V a → Expr V a
  | lett    : Expr V a → (V a → Expr V b) → Expr V b

  -- Scalar literals and operations
  | litF    : Float → Expr V .float
  | addf    : Expr V .float → Expr V .float → Expr V .float
  | mulf    : Expr V .float → Expr V .float → Expr V .float
  | subf    : Expr V .float → Expr V .float → Expr V .float

  -- Embed a concrete array
  | literal : Ria.Array shape → Expr V (.array shape)

  -- Fusible combinators
  | map     : (Float → Float) → Expr V (.array s) → Expr V (.array s)
  | zipWith : (Float → Float → Float) → Expr V (.array s)
              → Expr V (.array s) → Expr V (.array s)
  | reduce  : (Float → Float → Float) → Float
              → Expr V (.array [n]) → Expr V .float

  -- BLAS primitives (opaque to fusion — already optimal)
  | scale   : Expr V .float → Expr V (.array s) → Expr V (.array s)
  | dot     : Expr V (.array [n]) → Expr V (.array [n]) → Expr V .float
  | matmul  : Expr V (.array [m, k]) → Expr V (.array [k, n])
              → Expr V (.array [m, n])

/-- A closed expression works for any variable representation. -/
def ClosedExpr (a : Ty) := ∀ V, Expr V a

end Ria.IR
