#ifndef RIA_H
#define RIA_H

#include <lean/lean.h>
#include <cblas.h>

// Check or Copy FloatArray if not owned
static inline void ensure_exclusive(lean_object **obj) {
    if (!lean_is_exclusive(*obj)) {
      *obj = lean_copy_float_array(*obj);
    }
}

static inline CBLAS_ORDER ria_to_cblas_order(uint8_t layout) {
    return layout == 0 ? CblasRowMajor : CblasColMajor;
}

static inline CBLAS_TRANSPOSE ria_to_cblas_transpose(uint8_t t) {
    return t == 0 ? CblasNoTrans : CblasTrans;
}

#endif
