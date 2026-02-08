namespace Ria.FFI

@[extern "ria_ddot"]
opaque ddot (n : USize) (x : @& FloatArray) (incx : USize)
    (y : @& FloatArray) (incy : USize) : Float

@[extern "ria_dscal"]
opaque dscal (n : USize) (alpha : Float)
    (x : FloatArray) (incx : USize) : FloatArray

@[extern "ria_daxpy"]
opaque daxpy (n : USize) (alpha : Float)
    (x : @& FloatArray) (incx : USize)
    (y : FloatArray) (incy : USize) : FloatArray

-- FFI contracts: BLAS1 operations preserve destination vector length.
axiom dscal_size (n : USize) (alpha : Float) (x : FloatArray) (incx : USize) :
  (dscal n alpha x incx).size = x.size

axiom daxpy_size (n : USize) (alpha : Float)
    (x : @& FloatArray) (incx : USize)
    (y : FloatArray) (incy : USize) :
  (daxpy n alpha x incx y incy).size = y.size

end Ria.FFI
