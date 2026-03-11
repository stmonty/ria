#include "ria.h"

LEAN_EXPORT lean_obj_res ria_dgemv(
    uint8_t order, uint8_t trans,
    size_t m, size_t n,
    double alpha,
    b_lean_obj_arg a, size_t lda,
    b_lean_obj_arg x, size_t incx,
    double beta,
    lean_obj_arg y, size_t incy) {
    ensure_exclusive(&y);
    cblas_dgemv(ria_to_cblas_order(order), ria_to_cblas_transpose(trans),
                m, n, alpha,
                lean_float_array_cptr(a), lda,
                lean_float_array_cptr(x), incx,
                beta,
                lean_float_array_cptr(y), incy);
    return y;
}

LEAN_EXPORT lean_obj_res ria_dgemm(
    uint8_t order, uint8_t transA, uint8_t transB,
    size_t m, size_t n, size_t k,
    double alpha,
    b_lean_obj_arg a, size_t lda,
    b_lean_obj_arg b, size_t ldb,
    double beta,
    lean_obj_arg c, size_t ldc) {
    ensure_exclusive(&c);
    cblas_dgemm(ria_to_cblas_order(order), ria_to_cblas_transpose(transA),
                ria_to_cblas_transpose(transB),
                m, n, k, alpha,
                lean_float_array_cptr(a), lda,
                lean_float_array_cptr(b), ldb,
                beta,
                lean_float_array_cptr(c), ldc);
    return c;
}
