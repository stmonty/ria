namespace Ria.FFI

@[extern "ria_alloc_zeros"]
opaque allocZeros (n : USize) : FloatArray

@[extern "ria_alloc_fill"]
opaque allocFill (n : USize) (val : Float) : FloatArray

-- FFI contracts: C allocators return arrays with exactly `n` elements.
axiom allocZeros_size (n : USize) : (allocZeros n).size = n.toNat
axiom allocFill_size (n : USize) (val : Float) : (allocFill n val).size = n.toNat

end Ria.FFI
