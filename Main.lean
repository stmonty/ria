import Ria

open Ria
open Ria.IR

def main : IO Unit := do
  IO.println "=== Eager BLAS Operations ==="

  have h3 : (3 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega

  let v1 := Array.fill [3] 2.0 h3
  let v2 := Array.fill [3] 3.0 h3
  IO.println s!"v1 = {v1}"
  IO.println s!"v2 = {v2}"
  IO.println s!"dot(v1, v2) = {Array.dot v1 v2}"
  IO.println s!"v1 + v2 = {v1 + v2}"

  IO.println "\n=== Array Combinators ==="

  let doubled := Ria.Array.map (· * 2.0) v1
  IO.println s!"map (*2) v1 = {doubled}"

  let summed := Ria.Array.reduce (· + ·) 0.0 v1
  IO.println s!"reduce (+) 0 v1 = {summed}"

  let zipped := Ria.Array.zipWith (· * ·) v1 v2
  IO.println s!"zipWith (*) v1 v2 = {zipped}"

  IO.println "\n=== IR: Pretty-Printing + Direct Fusion ==="

  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.map (· * 2.0) (.literal v1))

  IO.println s!"before: {pretty expr}  ({passes expr} passes)"
  let exprFused := normalize expr
  IO.println s!"after:  {pretty exprFused}  ({passes exprFused} pass)"
  IO.println s!"result: {run exprFused}"

  IO.println "\n=== IR: Fusion Through Let-Bindings ==="

  -- Previously, the let hid the nesting and fusion couldn't fire
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

  IO.println "\n=== IR: Triple Map Through Lets ==="

  let exprTriple : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· - 1.0) (.literal v1)) (fun a =>
      .lett (.map (· * 3.0) (.var a)) (fun b =>
        .map (· + 10.0) (.var b)))

  IO.println s!"before: {pretty exprTriple}  ({passes exprTriple} passes)"
  let normTriple := normalize exprTriple
  IO.println s!"after:  {pretty normTriple}  ({passes normTriple} pass)"

  let resultTriple := run exprTriple
  let resultNormTriple := run normTriple
  IO.println s!"unfused = {resultTriple}"
  IO.println s!"fused   = {resultNormTriple}"

  IO.println "\n=== IR: Reduce-Map Through Let ==="

  let exprRedLet : ClosedExpr .float := fun V =>
    .lett (.map (fun x => x * x) (.literal v1)) (fun a =>
      .reduce (· + ·) 0.0 (.var a))

  IO.println s!"before: {pretty exprRedLet}  ({passes exprRedLet} passes)"
  let normRed := normalize exprRedLet
  IO.println s!"after:  {pretty normRed}  ({passes normRed} pass)"

  let resultRedLet := run exprRedLet
  let resultNormRed := run normRed
  IO.println s!"unfused = {resultRedLet}"
  IO.println s!"fused   = {resultNormRed}"
