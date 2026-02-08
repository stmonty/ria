import Ria.FFI.Memory
import Ria.FFI.Blas1
import Ria.Layout

namespace Ria

structure Vector (n : Nat) where
  data : FloatArray
  h_size : data.size = n

namespace Vector

def zeros (n : Nat) (h : n < USize.size) : Vector n := by
  let u : USize := USize.ofNatLT n h
  let data := Ria.FFI.allocZeros u
  have hs : data.size = n := by
    calc
      data.size = u.toNat := by
        simpa [data] using Ria.FFI.allocZeros_size u
      _ = n := by
        simpa [u] using (USize.toNat_ofNatLT (n := n) (h := h))
  exact ⟨data, hs⟩

def fill (n : Nat) (val : Float) (h : n < USize.size) : Vector n := by
  let u : USize := USize.ofNatLT n h
  let data := Ria.FFI.allocFill u val
  have hs : data.size = n := by
    calc
      data.size = u.toNat := by
        simpa [data] using Ria.FFI.allocFill_size u val
      _ = n := by
        simpa [u] using (USize.toNat_ofNatLT (n := n) (h := h))
  exact ⟨data, hs⟩

def ones (n : Nat) (h : n < USize.size) : Vector n :=
  fill n 1.0 h

def get (v : Vector n) (i : Fin n) : Float :=
  let hi : i.val < v.data.size := by simpa [v.h_size] using i.isLt
  v.data.get i.val hi

def set (v : Vector n) (i : Fin n) (val : Float) : Vector n := by
  let hi : i.val < v.data.size := by simpa [v.h_size] using i.isLt
  let data := v.data.set i.val val hi
  have hs : data.size = n := by
    calc
      data.size = v.data.size := by
        simp [data, FloatArray.set, FloatArray.size]
      _ = n := v.h_size
  exact ⟨data, hs⟩

def dot (x : Vector n) (y : Vector n) : Float :=
  Ria.FFI.ddot x.data.usize x.data 1 y.data 1

def scale (alpha : Float) (v : Vector n) : Vector n := by
  let result := Ria.FFI.dscal v.data.usize alpha v.data 1
  have hs : result.size = n := by
    calc
      result.size = v.data.size := by
        simpa [result] using Ria.FFI.dscal_size v.data.usize alpha v.data 1
      _ = n := v.h_size
  exact ⟨result, hs⟩

def add (x : Vector n) (y : Vector n) : Vector n := by
  let result := Ria.FFI.daxpy x.data.usize 1.0 x.data 1 y.data 1
  have hs : result.size = n := by
    calc
      result.size = y.data.size := by
        simpa [result] using Ria.FFI.daxpy_size x.data.usize 1.0 x.data 1 y.data 1
      _ = n := y.h_size
  exact ⟨result, hs⟩

def sub (x : Vector n) (y : Vector n) : Vector n := by
  let result := Ria.FFI.daxpy x.data.usize (-1.0) y.data 1 x.data 1
  have hs : result.size = n := by
    calc
      result.size = x.data.size := by
        simpa [result] using Ria.FFI.daxpy_size x.data.usize (-1.0) y.data 1 x.data 1
      _ = n := x.h_size
  exact ⟨result, hs⟩

instance : Add (Vector n) where add := Vector.add
instance : Sub (Vector n) where sub := Vector.sub
instance : Neg (Vector n) where neg v := Vector.scale (-1.0) v
instance : HMul Float (Vector n) (Vector n) where hMul := Vector.scale

instance : ToString (Vector n) where
  toString v :=
    let elems := (List.finRange n).map (fun i => toString (v.get i))
    s!"[{String.intercalate ", " elems}]"

instance : Repr (Vector n) where
  reprPrec v _ := toString v

end Vector
end Ria
