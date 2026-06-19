import Ria.Array

namespace Ria.Array

-- Reference implementations (pure, for proofs)

private def tabulateRef (shape : List Nat) (dtype : DType := .float64)
    (f : Fin (shapeProd shape) → Float) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize (f ⟨i, by sorry⟩)
    | .float32 => Ria.FFI.writeF32 acc i.toUSize (f ⟨i, by sorry⟩)
  ⟨data, by sorry⟩

private def mapRef (f : Float → Float) (a : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    let val := f (a.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

private def zipWithRef (f : Float → Float → Float) (a b : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := (List.range n).foldl (init := init) fun acc i =>
    let val := f (a.readElem i.toUSize) (b.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

private def reduceRef (f : Float → Float → Float) (init : Float) (a : Array [n] dtype) : Float :=
  (List.range n).foldl (init := init) fun acc i =>
    f acc (a.readElem i.toUSize)

-- Fast implementations (Nat.fold, no List allocation)

private def tabulateFast (shape : List Nat) (dtype : DType := .float64)
    (f : Fin (shapeProd shape) → Float) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := Nat.fold (init := init) (n := n) fun i _ acc =>
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize (f ⟨i, by omega⟩)
    | .float32 => Ria.FFI.writeF32 acc i.toUSize (f ⟨i, by omega⟩)
  ⟨data, by sorry⟩

private def mapFast (f : Float → Float) (a : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := Nat.fold (init := init) (n := n) fun i _ acc =>
    let val := f (a.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

private def zipWithFast (f : Float → Float → Float) (a b : Array shape dtype) : Array shape dtype :=
  let n := shapeProd shape
  let init := Ria.FFI.allocBytesZeros (n * dtype.bytesNat).toUSize
  let data := Nat.fold (init := init) (n := n) fun i _ acc =>
    let val := f (a.readElem i.toUSize) (b.readElem i.toUSize)
    match dtype with
    | .float64 => Ria.FFI.writeF64 acc i.toUSize val
    | .float32 => Ria.FFI.writeF32 acc i.toUSize val
  ⟨data, by sorry⟩

private def reduceFast (f : Float → Float → Float) (init : Float) (a : Array [n] dtype) : Float :=
  Nat.fold (init := init) (n := n) fun i _ acc =>
    f acc (a.readElem i.toUSize)

-- Public API: reference definitions, fast execution

@[implemented_by tabulateFast]
def tabulate (shape : List Nat) (dtype : DType := .float64)
    (f : Fin (shapeProd shape) → Float) : Array shape dtype :=
  tabulateRef shape dtype f

@[implemented_by mapFast]
def map (f : Float → Float) (a : Array shape dtype) : Array shape dtype :=
  mapRef f a

@[implemented_by zipWithFast]
def zipWith (f : Float → Float → Float) (a b : Array shape dtype) : Array shape dtype :=
  zipWithRef f a b

@[implemented_by reduceFast]
def reduce (f : Float → Float → Float) (init : Float) (a : Array [n] dtype) : Float :=
  reduceRef f init a

end Ria.Array
