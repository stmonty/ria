namespace Ria.FFI

@[extern "ria_dgemv"]
opaque dgemv (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize)
    (x : @& ByteArray) (incx : USize)
    (beta : Float) (y : ByteArray) (incy : USize) : ByteArray

@[extern "ria_dgemm"]
opaque dgemm (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize)
    (b : @& ByteArray) (ldb : USize)
    (beta : Float) (c : ByteArray) (ldc : USize) : ByteArray

@[extern "ria_sgemv"]
opaque sgemv (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize)
    (x : @& ByteArray) (incx : USize)
    (beta : Float) (y : ByteArray) (incy : USize) : ByteArray

@[extern "ria_sgemm"]
opaque sgemm (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize)
    (b : @& ByteArray) (ldb : USize)
    (beta : Float) (c : ByteArray) (ldc : USize) : ByteArray

axiom dgemv_size (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize) (x : @& ByteArray) (incx : USize)
    (beta : Float) (y : ByteArray) (incy : USize) :
  (dgemv order trans m n alpha a lda x incx beta y incy).size = y.size

axiom dgemm_size (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize) (b : @& ByteArray) (ldb : USize)
    (beta : Float) (c : ByteArray) (ldc : USize) :
  (dgemm order transA transB m n k alpha a lda b ldb beta c ldc).size = c.size

axiom sgemv_size (order : UInt8) (trans : UInt8)
    (m : USize) (n : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize) (x : @& ByteArray) (incx : USize)
    (beta : Float) (y : ByteArray) (incy : USize) :
  (sgemv order trans m n alpha a lda x incx beta y incy).size = y.size

axiom sgemm_size (order : UInt8) (transA : UInt8) (transB : UInt8)
    (m : USize) (n : USize) (k : USize) (alpha : Float)
    (a : @& ByteArray) (lda : USize) (b : @& ByteArray) (ldb : USize)
    (beta : Float) (c : ByteArray) (ldc : USize) :
  (sgemm order transA transB m n k alpha a lda b ldb beta c ldc).size = c.size

end Ria.FFI
