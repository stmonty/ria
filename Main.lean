import Ria

def main : IO Unit := do
  let x := Ria.FFI.allocFill 3 2.0   -- [2, 2, 2]
  IO.println s!"{x}"
  let y := Ria.FFI.allocFill 3 3.0   -- [3, 3, 3]
  let d := Ria.FFI.ddot 3 x 1 y 1    -- 2*3 + 2*3 + 2*3 = 18
  IO.println s!"dot = {d}"
