import Ria.Array

namespace Ria.Array

def tabulate (shape : List Nat) (f : Fin (shapeProd shape) → Float) : Array shape :=
  let n := shapeProd shape
  let data := (List.range n).foldl (init := FloatArray.emptyWithCapacity n) fun acc i =>
    acc.push (f ⟨i, by sorry⟩)
  ⟨data, by sorry⟩

def map (f : Float → Float) (a : Array shape) : Array shape :=
  let n := shapeProd shape
  let data := (List.range n).foldl (init := FloatArray.emptyWithCapacity n) fun acc i =>
    acc.push (f (a.data.get i (by sorry)))
  ⟨data, by sorry⟩

def zipWith (f : Float → Float → Float) (a b : Array shape) : Array shape :=
  let n := shapeProd shape
  let data := (List.range n).foldl (init := FloatArray.emptyWithCapacity n) fun acc i =>
    acc.push (f (a.data.get i (by sorry)) (b.data.get i (by sorry)))
  ⟨data, by sorry⟩

def reduce (f : Float → Float → Float) (init : Float) (a : Array [n]) : Float :=
  (List.range n).foldl (init := init) fun acc i =>
    f acc (a.data.get i (by sorry))

end Ria.Array
