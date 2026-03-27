import Ria.FFI.Bytes
import Ria.FFI.Blas1
import Ria.FFI.Blas3
import Ria.Layout

namespace Ria

@[reducible] def shapeProd : List Nat → Nat
  | [] => 1
  | x :: xs => x * shapeProd xs

inductive DType where
  | float32 | float64
  deriving DecidableEq, BEq

namespace DType

@[reducible] def bytesNat : DType → Nat
  | .float32 => 4
  | .float64 => 8

def bytesUSize : DType → USize
  | .float32 => 4
  | .float64 => 8

end DType

structure Array (shape : List Nat) (dtype : DType := .float64) where
  data : ByteArray
  h_size : data.size = shapeProd shape * dtype.bytesNat

abbrev Vector (n : Nat) (dtype : DType := .float64) := Array [n] dtype
abbrev Matrix (m n : Nat) (dtype : DType := .float64) := Array [m, n] dtype

namespace Array

@[reducible] def numel (_ : Array shape dtype) : Nat := shapeProd shape

def readElem (a : Array shape dtype) (i : USize) : Float :=
  match dtype with
  | .float64 => Ria.FFI.readF64 a.data i
  | .float32 => Ria.FFI.readF32 a.data i

def writeElem (a : Array shape dtype) (i : USize) (val : Float) : Array shape dtype :=
  match dtype with
  | .float64 => ⟨Ria.FFI.writeF64 a.data i val, by sorry⟩
  | .float32 => ⟨Ria.FFI.writeF32 a.data i val, by sorry⟩

def zeros (shape : List Nat) (dtype : DType := .float64)
    (h : shapeProd shape * dtype.bytesNat < USize.size) : Array shape dtype :=
  ⟨Ria.FFI.allocBytesZeros (USize.ofNatLT (shapeProd shape * dtype.bytesNat) h), by sorry⟩

def fill (shape : List Nat) (val : Float) (dtype : DType := .float64)
    (h : shapeProd shape < USize.size) : Array shape dtype :=
  match dtype with
  | .float64 => ⟨Ria.FFI.allocFillF64 (USize.ofNatLT (shapeProd shape) h) val, by sorry⟩
  | .float32 => ⟨Ria.FFI.allocFillF32 (USize.ofNatLT (shapeProd shape) h) val, by sorry⟩

def ones (shape : List Nat) (dtype : DType := .float64)
    (h : shapeProd shape < USize.size) : Array shape dtype :=
  fill shape 1.0 dtype h

def get (a : Array [n] dtype) (i : Fin n) : Float :=
  a.readElem i.val.toUSize

def set (a : Array [n] dtype) (i : Fin n) (val : Float) : Array [n] dtype :=
  a.writeElem i.val.toUSize val

def get2d (a : Array [m, n] dtype) (i : Fin m) (j : Fin n) : Float :=
  a.readElem (i.val * n + j.val).toUSize

def set2d (a : Array [m, n] dtype) (i : Fin m) (j : Fin n) (val : Float) : Array [m, n] dtype :=
  a.writeElem (i.val * n + j.val).toUSize val

def getFlat (a : Array shape dtype) (i : Fin (shapeProd shape)) : Float :=
  a.readElem i.val.toUSize

def setFlat (a : Array shape dtype) (i : Fin (shapeProd shape)) (val : Float) : Array shape dtype :=
  a.writeElem i.val.toUSize val

def nElem (_ : Array shape dtype) : USize := (shapeProd shape).toUSize

def scale (alpha : Float) (a : Array shape dtype) : Array shape dtype :=
  match dtype with
  | .float64 => ⟨Ria.FFI.dscal a.nElem alpha a.data 1, by sorry⟩
  | .float32 => ⟨Ria.FFI.sscal a.nElem alpha a.data 1, by sorry⟩

def add (x y : Array shape dtype) : Array shape dtype :=
  match dtype with
  | .float64 => ⟨Ria.FFI.daxpy x.nElem 1.0 x.data 1 y.data 1, by sorry⟩
  | .float32 => ⟨Ria.FFI.saxpy x.nElem 1.0 x.data 1 y.data 1, by sorry⟩

def sub (x y : Array shape dtype) : Array shape dtype :=
  match dtype with
  | .float64 => ⟨Ria.FFI.daxpy x.nElem (-1.0) y.data 1 x.data 1, by sorry⟩
  | .float32 => ⟨Ria.FFI.saxpy x.nElem (-1.0) y.data 1 x.data 1, by sorry⟩

def dot (x y : Array [n] dtype) : Float :=
  match dtype with
  | .float64 => Ria.FFI.ddot x.nElem x.data 1 y.data 1
  | .float32 => Ria.FFI.sdot x.nElem x.data 1 y.data 1

def matmul (a : Array [m, k] dtype) (b : Array [k, n] dtype)
    (h : m * n * dtype.bytesNat < USize.size) : Array [m, n] dtype :=
  match dtype with
  | .float64 =>
    let c := Ria.FFI.allocBytesZeros (USize.ofNatLT (m * n * DType.float64.bytesNat) h)
    ⟨Ria.FFI.dgemm
      (Layout.toUInt8 .RowMajor) 0 0
      m.toUSize n.toUSize k.toUSize
      1.0 a.data k.toUSize b.data n.toUSize
      0.0 c n.toUSize, by sorry⟩
  | .float32 =>
    let c := Ria.FFI.allocBytesZeros (USize.ofNatLT (m * n * DType.float32.bytesNat) h)
    ⟨Ria.FFI.sgemm
      (Layout.toUInt8 .RowMajor) 0 0
      m.toUSize n.toUSize k.toUSize
      1.0 a.data k.toUSize b.data n.toUSize
      0.0 c n.toUSize, by sorry⟩

def matvec (a : Array [m, n] dtype) (x : Array [n] dtype)
    (h : m * dtype.bytesNat < USize.size) : Array [m] dtype :=
  match dtype with
  | .float64 =>
    let y := Ria.FFI.allocBytesZeros (USize.ofNatLT (m * DType.float64.bytesNat) h)
    ⟨Ria.FFI.dgemv
      (Layout.toUInt8 .RowMajor) 0
      m.toUSize n.toUSize
      1.0 a.data n.toUSize x.data 1
      0.0 y 1, by sorry⟩
  | .float32 =>
    let y := Ria.FFI.allocBytesZeros (USize.ofNatLT (m * DType.float32.bytesNat) h)
    ⟨Ria.FFI.sgemv
      (Layout.toUInt8 .RowMajor) 0
      m.toUSize n.toUSize
      1.0 a.data n.toUSize x.data 1
      0.0 y 1, by sorry⟩

instance : Add (Array shape dtype) where add := Array.add
instance : Sub (Array shape dtype) where sub := Array.sub
instance : Neg (Array shape dtype) where neg a := Array.scale (-1.0) a
instance : HMul Float (Array shape dtype) (Array shape dtype) where hMul := Array.scale

instance {n : Nat} : ToString (Array [n] dtype) where
  toString a :=
    let elems := (List.finRange n).map (fun i => toString (a.get i))
    s!"[{String.intercalate ", " elems}]"

instance {m n : Nat} : ToString (Array [m, n] dtype) where
  toString a :=
    let rows := (List.finRange m).map fun i =>
      let elems := (List.finRange n).map fun j => toString (a.get2d i j)
      s!"[{String.intercalate ", " elems}]"
    s!"[{String.intercalate ",\n " rows}]"

instance {n : Nat} : Repr (Array [n] dtype) where
  reprPrec a _ := toString a

instance {m n : Nat} : Repr (Array [m, n] dtype) where
  reprPrec a _ := toString a

end Array
end Ria
