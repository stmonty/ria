namespace Ria.FFI

@[extern "ria_alloc_zeros"]
opaque allocZeros (n: USize) : FloatArray

@[extern "ria_alloc_fill"]
opaque allocFill (n: USize) (val: Float) : FloatArray

end Ria.FFI
