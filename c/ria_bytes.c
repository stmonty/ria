#include "ria.h"
#include <string.h>

/* ── Allocation ── */

/* Allocate a zeroed ByteArray of n_bytes bytes. */
LEAN_EXPORT lean_obj_res ria_alloc_bytes_zeros(size_t n_bytes) {
    lean_obj_res r = lean_alloc_sarray(1, n_bytes, n_bytes);
    memset(lean_sarray_cptr(r), 0, n_bytes);
    return r;
}

/* Allocate a ByteArray filled with n copies of a float64 value. */
LEAN_EXPORT lean_obj_res ria_alloc_fill_f64(size_t n, double val) {
    size_t n_bytes = n * sizeof(double);
    lean_obj_res r = lean_alloc_sarray(1, n_bytes, n_bytes);
    double *ptr = (double *)lean_sarray_cptr(r);
    for (size_t i = 0; i < n; i++) {
        ptr[i] = val;
    }
    return r;
}

/* Allocate a ByteArray filled with n copies of a float32 value. */
LEAN_EXPORT lean_obj_res ria_alloc_fill_f32(size_t n, double val) {
    size_t n_bytes = n * sizeof(float);
    lean_obj_res r = lean_alloc_sarray(1, n_bytes, n_bytes);
    float *ptr = (float *)lean_sarray_cptr(r);
    float fval = (float)val;
    for (size_t i = 0; i < n; i++) {
        ptr[i] = fval;
    }
    return r;
}

/* ── Element access ── */

/* Read a float64 at element index i from a ByteArray. */
LEAN_EXPORT double ria_read_f64(b_lean_obj_arg bytes, size_t i) {
    double *ptr = (double *)lean_sarray_cptr(bytes);
    return ptr[i];
}

/* Write a float64 at element index i into a ByteArray. */
LEAN_EXPORT lean_obj_res ria_write_f64(lean_obj_arg bytes, size_t i, double val) {
    if (!lean_is_exclusive(bytes)) {
        size_t sz = lean_sarray_size(bytes);
        lean_obj_res copy = lean_alloc_sarray(1, sz, sz);
        memcpy(lean_sarray_cptr(copy), lean_sarray_cptr(bytes), sz);
        lean_dec_ref(bytes);
        bytes = copy;
    }
    double *ptr = (double *)lean_sarray_cptr(bytes);
    ptr[i] = val;
    return bytes;
}

/* Read a float32 at element index i, return as float64. */
LEAN_EXPORT double ria_read_f32(b_lean_obj_arg bytes, size_t i) {
    float *ptr = (float *)lean_sarray_cptr(bytes);
    return (double)ptr[i];
}

/* Write a float32 at element index i (val comes in as float64, narrowed). */
LEAN_EXPORT lean_obj_res ria_write_f32(lean_obj_arg bytes, size_t i, double val) {
    if (!lean_is_exclusive(bytes)) {
        size_t sz = lean_sarray_size(bytes);
        lean_obj_res copy = lean_alloc_sarray(1, sz, sz);
        memcpy(lean_sarray_cptr(copy), lean_sarray_cptr(bytes), sz);
        lean_dec_ref(bytes);
        bytes = copy;
    }
    float *ptr = (float *)lean_sarray_cptr(bytes);
    ptr[i] = (float)val;
    return bytes;
}
