#include "ria.h"

LEAN_EXPORT void ria_dgemv(uint8_t layout, uint8_t trans, size_t m, size_t n, size_t, double alpha, b_lean_obj_arg a, size_t lda, b_lean_obj_arg x, size_t incx, double beta, lean_obj_arg y, size_t incy) {
    ensure_exclusive(&y);
    cblas_dgemv(ria_to_cblas_order(order), ria_to_cblas_transpose(trans), m, n, alpha, a, lda, x, incx, beta, y, incy);
    return y;
}

LEAN_EXPORT lean_obj_res ria_dgemm(uint8_t order, uint8_t transA, uint8_t transB, size_t m, size_t n, size_t k, double alpha, double beta, size_t lda, b_lean_obj_arg a, size_t ldb, b_lean_obj_arg b, size_t ldc, lean_obj_arg c) {
    ensure_exclusive(&c);
    cblas_dgemm(ria_to_cblas_order(order), ria_to_cblas_transpose(transA), ria_to_cblas_transpose(transB), m, n, k, alpha, a, lda, b, ldb, beta, c, ldc);
    return c;
}
