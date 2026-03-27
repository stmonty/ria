#ifndef RIA_H
#define RIA_H

#include <lean/lean.h>
#include <cblas.h>
#include <string.h>

/* Get raw byte pointer from a ByteArray (sarray with elem_size=1). */
static inline uint8_t *ria_bytes_ptr(lean_object *o) {
    return lean_sarray_cptr(o);
}

/* Get double* from ByteArray (reinterpret bytes as float64). */
static inline double *ria_f64_ptr(lean_object *o) {
    return (double *)lean_sarray_cptr(o);
}

/* Get float* from ByteArray (reinterpret bytes as float32). */
static inline float *ria_f32_ptr(lean_object *o) {
    return (float *)lean_sarray_cptr(o);
}

/* Ensure exclusive ownership of a ByteArray, copying if shared. */
static inline void ensure_exclusive_bytes(lean_object **obj) {
    if (!lean_is_exclusive(*obj)) {
        size_t sz = lean_sarray_size(*obj);
        lean_obj_res copy = lean_alloc_sarray(1, sz, sz);
        memcpy(lean_sarray_cptr(copy), lean_sarray_cptr(*obj), sz);
        lean_dec_ref(*obj);
        *obj = copy;
    }
}

static inline CBLAS_ORDER ria_to_cblas_order(uint8_t layout) {
    return layout == 0 ? CblasRowMajor : CblasColMajor;
}

static inline CBLAS_TRANSPOSE ria_to_cblas_transpose(uint8_t t) {
    return t == 0 ? CblasNoTrans : CblasTrans;
}

#endif
