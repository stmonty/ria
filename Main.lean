import Ria

open Ria

def main : IO Unit := do
  have h3 : (3 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega

  -- 1D Arrays (Vectors)
  IO.println "=== Vectors ==="
  let v1 := Array.fill [3] 2.0 h3
  let v2 := Array.fill [3] 3.0 h3
  IO.println s!"v1 = {v1}"
  IO.println s!"v2 = {v2}"
  IO.println s!"dot(v1, v2) = {Array.dot v1 v2}"
  IO.println s!"v1 + v2 = {v1 + v2}"
  IO.println s!"v1 - v2 = {v1 - v2}"
  IO.println s!"3.0 * v1 = {3.0 * v1}"
  IO.println s!"v1[0] = {v1.get ⟨0, by omega⟩}"
  IO.println s!"v1[2] = {v1.get ⟨2, by omega⟩}"

  -- 2D Arrays (Matrices)
  IO.println "\n=== Matrices ==="
  have h6 : (6 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega
  have h4 : (4 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega
  have h2 : (2 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega

  -- A is 2x3, B is 3x2
  let a := Array.fill [2, 3] 1.0 h6
  let b := Array.fill [3, 2] 2.0 h6
  IO.println s!"A (2x3) =\n{a}"
  IO.println s!"B (3x2) =\n{b}"

  -- Matrix multiply: C = A * B should be 2x2, all 6.0
  let c := Array.matmul a b h4
  IO.println s!"A * B (2x2) =\n{c}"

  -- Matrix-vector multiply: A * v should be [6, 6]
  let v := Array.fill [3] 2.0 h3
  let mv := Array.matvec a v h2
  IO.println s!"A * v = {mv}"

  -- Matrix arithmetic (elementwise, same shape)
  IO.println s!"A + A =\n{a + a}"
  IO.println s!"2.0 * A =\n{2.0 * a}"
