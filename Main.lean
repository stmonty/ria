import Ria

open Ria

def main : IO Unit := do
  have h3 : (3 : Nat) < USize.size := by
    rcases USize.size_eq with h32 | h64 <;> omega

  -- Vector construction
  let v1 := Vector.fill 3 2.0 h3
  let v2 := Vector.fill 3 3.0 h3
  IO.println s!"v1 = {v1}"
  IO.println s!"v2 = {v2}"

  -- Dot product (should be 2*3 + 2*3 + 2*3 = 18)
  IO.println s!"dot(v1, v2) = {Vector.dot v1 v2}"

  -- Arithmetic
  IO.println s!"v1 + v2 = {v1 + v2}"
  IO.println s!"v1 - v2 = {v1 - v2}"
  IO.println s!"3.0 * v1 = {3.0 * v1}"

  -- Element access via Fin
  IO.println s!"v1[0] = {v1.get ⟨0, by omega⟩}"
  IO.println s!"v1[2] = {v1.get ⟨2, by omega⟩}"

  -- Type safety: this would be a compile error:
  -- let bad := Vector.dot (Vector.zeros 3 h3) (Vector.zeros 4 ?h4)
