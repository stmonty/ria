#include "ria.h"

/* ── float64 (double) BLAS1 ── */

LEAN_EXPORT double ria_ddot(size_t n,
                            b_lean_obj_arg x, size_t incx,
                            b_lean_obj_arg y, size_t incy) {
    return cblas_ddot(n, ria_f64_ptr(x), incx, ria_f64_ptr(y), incy);
}

LEAN_EXPORT lean_obj_res ria_dscal(size_t n, double alpha,
                                   lean_obj_arg x, size_t incx) {
    ensure_exclusive_bytes(&x);
    cblas_dscal(n, alpha, ria_f64_ptr(x), incx);
    return x;
}

LEAN_EXPORT lean_obj_res ria_daxpy(size_t n, double alpha,
                                   b_lean_obj_arg x, size_t incx,
                                   lean_obj_arg y, size_t incy) {
    ensure_exclusive_bytes(&y);
    cblas_daxpy(n, alpha, ria_f64_ptr(x), incx, ria_f64_ptr(y), incy);
    return y;
}

/* ── float32 (single) BLAS1 ── */

LEAN_EXPORT double ria_sdot(size_t n,
                            b_lean_obj_arg x, size_t incx,
                            b_lean_obj_arg y, size_t incy) {
    return (double)cblas_sdot(n, ria_f32_ptr(x), incx, ria_f32_ptr(y), incy);
}

LEAN_EXPORT lean_obj_res ria_sscal(size_t n, double alpha,
                                   lean_obj_arg x, size_t incx) {
    ensure_exclusive_bytes(&x);
    cblas_sscal(n, (float)alpha, ria_f32_ptr(x), incx);
    return x;
}

LEAN_EXPORT lean_obj_res ria_saxpy(size_t n, double alpha,
                                   b_lean_obj_arg x, size_t incx,
                                   lean_obj_arg y, size_t incy) {
    ensure_exclusive_bytes(&y);
    cblas_saxpy(n, (float)alpha, ria_f32_ptr(x), incx, ria_f32_ptr(y), incy);
    return y;
}
