#include "ria.h"

/* ── float64 (double) BLAS2/3 ── */

LEAN_EXPORT lean_obj_res ria_dgemv(
    uint8_t order, uint8_t trans,
    size_t m, size_t n,
    double alpha,
    b_lean_obj_arg a, size_t lda,
    b_lean_obj_arg x, size_t incx,
    double beta,
    lean_obj_arg y, size_t incy) {
    ensure_exclusive_bytes(&y);
    cblas_dgemv(ria_to_cblas_order(order), ria_to_cblas_transpose(trans),
                m, n, alpha,
                ria_f64_ptr(a), lda,
                ria_f64_ptr(x), incx,
                beta,
                ria_f64_ptr(y), incy);
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
    ensure_exclusive_bytes(&c);
    cblas_dgemm(ria_to_cblas_order(order), ria_to_cblas_transpose(transA),
                ria_to_cblas_transpose(transB),
                m, n, k, alpha,
                ria_f64_ptr(a), lda,
                ria_f64_ptr(b), ldb,
                beta,
                ria_f64_ptr(c), ldc);
    return c;
}

/* ── float32 (single) BLAS2/3 ── */

LEAN_EXPORT lean_obj_res ria_sgemv(
    uint8_t order, uint8_t trans,
    size_t m, size_t n,
    double alpha,
    b_lean_obj_arg a, size_t lda,
    b_lean_obj_arg x, size_t incx,
    double beta,
    lean_obj_arg y, size_t incy) {
    ensure_exclusive_bytes(&y);
    cblas_sgemv(ria_to_cblas_order(order), ria_to_cblas_transpose(trans),
                m, n, (float)alpha,
                ria_f32_ptr(a), lda,
                ria_f32_ptr(x), incx,
                (float)beta,
                ria_f32_ptr(y), incy);
    return y;
}

LEAN_EXPORT lean_obj_res ria_sgemm(
    uint8_t order, uint8_t transA, uint8_t transB,
    size_t m, size_t n, size_t k,
    double alpha,
    b_lean_obj_arg a, size_t lda,
    b_lean_obj_arg b, size_t ldb,
    double beta,
    lean_obj_arg c, size_t ldc) {
    ensure_exclusive_bytes(&c);
    cblas_sgemm(ria_to_cblas_order(order), ria_to_cblas_transpose(transA),
                ria_to_cblas_transpose(transB),
                m, n, k, (float)alpha,
                ria_f32_ptr(a), lda,
                ria_f32_ptr(b), ldb,
                (float)beta,
                ria_f32_ptr(c), ldc);
    return c;
}
