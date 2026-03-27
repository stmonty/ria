import Ria.Array

namespace Ria.Array

def tabulate (shape : List Nat) (dtype : DType := .float64)
    (f : Fin (shapeProd shape) → Float) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize (f ⟨i, by sorry⟩)
    | .float32 => Ria.FFI.writeF32 acc i.toUSize (f ⟨i, by sorry⟩)
  ⟨data, by sorry⟩

def map (f : Float → Float) (a : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    let val := f (a.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

def zipWith (f : Float → Float → Float) (a b : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    let val := f (a.readElem i.toUSize) (b.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

def reduce (f : Float → Float → Float) (init : Float) (a : Array [n] dtype) : Float :=
  (List.range n).foldl (init := init) fun acc i =>
    f acc (a.readElem i.toUSize)

end Ria.Array
