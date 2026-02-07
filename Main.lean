import Ria

def main : IO Unit := do
  let v := Ria.FFI.allocZeros 5
  IO.println s!"Size {v.size}"
