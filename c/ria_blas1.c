#include "ria.h"

LEAN_EXPORT double ria_ddot(size_t n,
                            b_lean_obj_arg x, size_t incx,
                            b_lean_obj_arg y, size_t incy) {
    return cblas_ddot(n, lean_get_float_cptr(x), incx, lean_get_float_cptr(y), incy);
}

LEAN_EXPORT lean_obj_res ria_dscal(size_t n, double alpha,
                                   lean_obj_arg x, size_t incx) {
    ensure_exclusive(&x);
    cblas_dscal(n, alpha, lean_get_float_cptr(x), incx);
    return x;
}

LEAN_EXPORT lean_obj_res ria_daxpy(size_t n, double alpha,
                                   b_lean_obj_arg x, size_t incx,
                                   lean_obj_arg y, size_t incy) {
    ensure_exclusive(&y);
    cblas_daxpy(n, alpha, lean_get_float_cptr(x), incx, lean_get_float_cptr(y), incy);
    return y;
}
