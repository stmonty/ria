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

#endif
