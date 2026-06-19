namespace Ria.FFI

@[extern "ria_ddot"]
opaque ddot (n : USize) (x : @& ByteArray) (incx : USize)
    (y : @& ByteArray) (incy : USize) : Float

@[extern "ria_dscal"]
opaque dscal (n : USize) (alpha : Float)
    (x : ByteArray) (incx : USize) : ByteArray

@[extern "ria_daxpy"]
opaque daxpy (n : USize) (alpha : Float)
    (x : @& ByteArray) (incx : USize)
    (y : ByteArray) (incy : USize) : ByteArray

@[extern "ria_sdot"]
opaque sdot (n : USize) (x : @& ByteArray) (incx : USize)
    (y : @& ByteArray) (incy : USize) : Float

@[extern "ria_sscal"]
opaque sscal (n : USize) (alpha : Float)
    (x : ByteArray) (incx : USize) : ByteArray

@[extern "ria_saxpy"]
opaque saxpy (n : USize) (alpha : Float)
    (x : @& ByteArray) (incx : USize)
    (y : ByteArray) (incy : USize) : ByteArray

axiom dscal_size (n : USize) (alpha : Float) (x : ByteArray) (incx : USize) :
  (dscal n alpha x incx).size = x.size
axiom daxpy_size (n : USize) (alpha : Float)
    (x : @& ByteArray) (incx : USize) (y : ByteArray) (incy : USize) :
  (daxpy n alpha x incx y incy).size = y.size
axiom sscal_size (n : USize) (alpha : Float) (x : ByteArray) (incx : USize) :
  (sscal n alpha x incx).size = x.size
axiom saxpy_size (n : USize) (alpha : Float)
    (x : @& ByteArray) (incx : USize) (y : ByteArray) (incy : USize) :
  (saxpy n alpha x incx y incy).size = y.size

end Ria.FFI
