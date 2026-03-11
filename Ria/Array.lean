import Ria.FFI.Memory
import Ria.FFI.Blas1
import Ria.FFI.Blas3
import Ria.Layout

namespace Ria

@[reducible] def shapeProd : List Nat → Nat
  | [] => 1
  | x :: xs => x * shapeProd xs

structure Array (shape : List Nat) where
  data : FloatArray
  h_size : data.size = shapeProd shape

abbrev Vector (n : Nat) := Array [n]
abbrev Matrix (m n : Nat) := Array [m, n]

namespace Array

def zeros (shape : List Nat) (h : shapeProd shape < USize.size) : Array shape :=
  ⟨Ria.FFI.allocZeros (USize.ofNatLT (shapeProd shape) h), by sorry⟩

def fill (shape : List Nat) (val : Float) (h : shapeProd shape < USize.size) : Array shape :=
  ⟨Ria.FFI.allocFill (USize.ofNatLT (shapeProd shape) h) val, by sorry⟩

def ones (shape : List Nat) (h : shapeProd shape < USize.size) : Array shape :=
  fill shape 1.0 h

def getFlat (a : Array shape) (i : Fin (shapeProd shape)) : Float :=
  a.data.get i.val (by sorry)

def setFlat (a : Array shape) (i : Fin (shapeProd shape)) (val : Float) : Array shape :=
  ⟨a.data.set i.val val (by sorry), by sorry⟩

def get (a : Array [n]) (i : Fin n) : Float :=
  a.data.get i.val (by sorry)

def set (a : Array [n]) (i : Fin n) (val : Float) : Array [n] :=
  ⟨a.data.set i.val val (by sorry), by sorry⟩

def get2d (a : Array [m, n]) (i : Fin m) (j : Fin n) : Float :=
  a.data.get (i.val * n + j.val) (by sorry)

def set2d (a : Array [m, n]) (i : Fin m) (j : Fin n) (val : Float) : Array [m, n] :=
  ⟨a.data.set (i.val * n + j.val) val (by sorry), by sorry⟩

def scale (alpha : Float) (a : Array shape) : Array shape :=
  ⟨Ria.FFI.dscal a.data.usize alpha a.data 1, by sorry⟩

def add (x y : Array shape) : Array shape :=
  ⟨Ria.FFI.daxpy x.data.usize 1.0 x.data 1 y.data 1, by sorry⟩

def sub (x y : Array shape) : Array shape :=
  ⟨Ria.FFI.daxpy x.data.usize (-1.0) y.data 1 x.data 1, by sorry⟩

def dot (x y : Array [n]) : Float :=
  Ria.FFI.ddot x.data.usize x.data 1 y.data 1

def matmul (a : Array [m, k]) (b : Array [k, n])
    (h : m * n < USize.size) : Array [m, n] :=
  let c := Ria.FFI.allocZeros (USize.ofNatLT (m * n) h)
  ⟨Ria.FFI.dgemm
    (Layout.toUInt8 .RowMajor) 0 0
    m.toUSize n.toUSize k.toUSize
    1.0
    a.data k.toUSize
    b.data n.toUSize
    0.0
    c n.toUSize, by sorry⟩

def matvec (a : Array [m, n]) (x : Array [n])
    (h : m < USize.size) : Array [m] :=
  let y := Ria.FFI.allocZeros (USize.ofNatLT m h)
  ⟨Ria.FFI.dgemv
    (Layout.toUInt8 .RowMajor) 0
    m.toUSize n.toUSize
    1.0
    a.data n.toUSize
    x.data 1
    0.0
    y 1, by sorry⟩

instance : Add (Array shape) where add := Array.add
instance : Sub (Array shape) where sub := Array.sub
instance : Neg (Array shape) where neg a := Array.scale (-1.0) a
instance : HMul Float (Array shape) (Array shape) where hMul := Array.scale

instance {n : Nat} : ToString (Array [n]) where
  toString a :=
    let elems := (List.finRange n).map (fun i => toString (a.get i))
    s!"[{String.intercalate ", " elems}]"

instance {m n : Nat} : ToString (Array [m, n]) where
  toString a :=
    let rows := (List.finRange m).map fun i =>
      let elems := (List.finRange n).map fun j => toString (a.get2d i j)
      s!"[{String.intercalate ", " elems}]"
    s!"[{String.intercalate ",\n " rows}]"

instance {n : Nat} : Repr (Array [n]) where
  reprPrec a _ := toString a

instance {m n : Nat} : Repr (Array [m, n]) where
  reprPrec a _ := toString a

end Array
end Ria
