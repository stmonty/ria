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

 end Ria.FFI
