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

  IO.println "\n=== IR: Expression Tree + Fusion ==="

  -- Build an expression: take v1, double each element, then add 1
  -- Without fusion this is TWO passes over the array
  let expr : ClosedExpr (.array [3]) := fun V =>
    .map (· + 1.0) (.map (· * 2.0) (.literal v1))

  -- Evaluate WITHOUT fusion (two passes)
  let unfused := eval (expr Ty.denote)
  IO.println s!"unfused: map (+1) (map (*2) v1) = {unfused}"

  -- Fuse: map (+1) ∘ map (*2) → map (fun x => x*2 + 1)
  -- Now it's ONE pass
  let fused := eval (fuse (expr Ty.denote))
  IO.println s!"fused:   map (x => x*2+1) v1  = {fused}"

  IO.println "\n=== IR: Reduce-Map Fusion ==="

  -- sum(map square x) → reduce (fun a b => a + b*b) 0 x
  let expr2 : ClosedExpr .float := fun V =>
    .reduce (· + ·) 0.0 (.map (fun x => x * x) (.literal v1))

  let unfused2 := eval (expr2 Ty.denote)
  IO.println s!"unfused: reduce (+) 0 (map (x=>x*x) v1) = {unfused2}"

  let fused2 := eval (fuse (expr2 Ty.denote))
  IO.println s!"fused:   reduce (a b => a+b*b) 0 v1    = {fused2}"

  IO.println "\n=== IR: Triple Map Fusion ==="

  -- map h (map g (map f x)) → map (h ∘ g ∘ f) x — three passes to one
  let expr3 : ClosedExpr (.array [3]) := fun V =>
    .map (· + 10.0) (.map (· * 3.0) (.map (· - 1.0) (.literal v1)))

  let unfused3 := eval (expr3 Ty.denote)
  IO.println s!"unfused: map (+10) (map (*3) (map (-1) v1)) = {unfused3}"

  let fused3 := eval (fuse (expr3 Ty.denote))
  IO.println s!"fused:   map (x => (x-1)*3+10) v1         = {fused3}"
