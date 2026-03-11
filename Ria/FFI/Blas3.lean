namespace Ria.FFI

@[extern "ria_dgemv"]
opaque dgemv (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize)
    (alpha : Float)
    (a : @& FloatArray) (lda : USize)
    (x : @& FloatArray) (incx : USize)
    (beta : Float)
    (y : FloatArray) (incy : USize) : FloatArray

@[extern "ria_dgemm"]
opaque dgemm (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize)
    (alpha : Float)
    (a : @& FloatArray) (lda : USize)
    (b : @& FloatArray) (ldb : USize)
    (beta : Float)
    (c : FloatArray) (ldc : USize) : FloatArray

axiom dgemv_size (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize)
    (alpha : Float)
    (a : @& FloatArray) (lda : USize)
    (x : @& FloatArray) (incx : USize)
    (beta : Float)
    (y : FloatArray) (incy : USize) :
  (dgemv order trans m n alpha a lda x incx beta y incy).size = y.size

axiom dgemm_size (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize)
    (alpha : Float)
    (a : @& FloatArray) (lda : USize)
    (b : @& FloatArray) (ldb : USize)
    (beta : Float)
    (c : FloatArray) (ldc : USize) :
  (dgemm order transA transB m n k alpha a lda b ldb beta c ldc).size = c.size

end Ria.FFI
