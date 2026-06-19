import Ria

open Ria
open Ria.IR

def main : IO Unit := do
  IO.println "=== float64 (default) ==="

  have h3 : (3 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega

  let v1 := Array.fill [3] 2.0 .float64 h3
  let v2 := Array.fill [3] 3.0 .float64 h3
  IO.println s!"v1 = {v1}"
  IO.println s!"v2 = {v2}"
  IO.println s!"dot(v1, v2) = {Array.dot v1 v2}"
  IO.println s!"v1 + v2 = {v1 + v2}"

  IO.println "\n=== float32 ==="

  let v1f32 := Array.fill [3] 2.0 .float32 h3
  let v2f32 := Array.fill [3] 3.0 .float32 h3
  IO.println s!"v1 (f32) = {v1f32}"
  IO.println s!"v2 (f32) = {v2f32}"
  IO.println s!"dot(v1, v2) f32 = {Array.dot v1f32 v2f32}"
  IO.println s!"v1 + v2 (f32) = {v1f32 + v2f32}"

  IO.println "\n=== BLAS3: matmul ==="

  let a := Array.fromList [2, 3] [1, 2, 3, 4, 5, 6] .float64 (by native_decide)
  let b := Array.fromList [3, 2] [7, 8, 9, 10, 11, 12] .float64 (by native_decide)
  IO.println s!"A = {a}"
  IO.println s!"B = {b}"
  have h_mm : 2 * 2 * DType.float64.bytesNat < USize.size := by
    simp [DType.bytesNat]; rcases USize.size_eq with h32 | h64 <;> omega
  let c := Array.matmul a b h_mm
  IO.println s!"A * B = {c}"

  let x := Array.fromList [3] [1, 2, 3] .float64 (by native_decide)
  have h_mv : 2 * DType.float64.bytesNat < USize.size := by
    simp [DType.bytesNat]; rcases USize.size_eq with h32 | h64 <;> omega
  let mv := Array.matvec a x h_mv
  IO.println s!"A * x = {mv}"

  IO.println "\n=== Combinators ==="

  let doubled := Ria.Array.map (· * 2.0) v1
  IO.println s!"map (*2) v1 = {doubled}"

  let summed := Ria.Array.reduce (· + ·) 0.0 v1
  IO.println s!"reduce (+) 0 v1 = {summed}"

  IO.println "\n=== IR: Normalize + Fusion ==="

  let exprLet : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· * 2.0) (.literal v1)) (fun a =>
      .map (· + 1.0) (.var a))

  IO.println s!"before: {pretty exprLet}  ({passes exprLet} passes)"
  let normLet := normalize exprLet
  IO.println s!"after:  {pretty normLet}  ({passes normLet} pass)"

  let resultLet := run exprLet
  let resultNorm := run normLet
  IO.println s!"unfused = {resultLet}"
  IO.println s!"fused   = {resultNorm}"
