namespace Ria.FFI

@[extern "ria_alloc_bytes_zeros"]
opaque allocBytesZeros (nBytes : USize) : ByteArray

@[extern "ria_alloc_fill_f64"]
opaque allocFillF64 (n : USize) (val : Float) : ByteArray

@[extern "ria_alloc_fill_f32"]
opaque allocFillF32 (n : USize) (val : Float) : ByteArray

@[extern "ria_read_f64"]
opaque readF64 (bytes : @& ByteArray) (i : USize) : Float

@[extern "ria_write_f64"]
opaque writeF64 (bytes : ByteArray) (i : USize) (val : Float) : ByteArray

@[extern "ria_read_f32"]
opaque readF32 (bytes : @& ByteArray) (i : USize) : Float

@[extern "ria_write_f32"]
opaque writeF32 (bytes : ByteArray) (i : USize) (val : Float) : ByteArray

axiom allocBytesZeros_size (n : USize) : (allocBytesZeros n).size = n.toNat
axiom allocFillF64_size (n : USize) (val : Float) :
  (allocFillF64 n val).size = n.toNat * 8
axiom allocFillF32_size (n : USize) (val : Float) :
  (allocFillF32 n val).size = n.toNat * 4
axiom writeF64_size (bytes : ByteArray) (i : USize) (val : Float) :
  (writeF64 bytes i val).size = bytes.size
axiom writeF32_size (bytes : ByteArray) (i : USize) (val : Float) :
  (writeF32 bytes i val).size = bytes.size

end Ria.FFI
