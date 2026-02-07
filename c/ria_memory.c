#include "ria.h"
#include <string.h>

LEAN_EXPORT lean_obj_res ria_alloc_zeros(size_t n) {
    lean_obj_res r = lean_alloc_sarray(sizeof(double), n, n);
    memset(lean_float_array_cptr(r), 0, n * sizeof(double));
    return r;
}

LEAN_EXPORT lean_object* ria_alloc_fill(size_t n, double val) {
    lean_obj_res r = lean_alloc_sarray(sizeof(double), n, n);
    double* array = lean_float_array_cptr(r);
    for (int i = 0; i < n; i++) {
        array[i] = val;
    }
    return r;
}
