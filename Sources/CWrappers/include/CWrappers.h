#ifndef CWrappers_h
#define CWrappers_h

#include <stdint.h>

/// - returns: `f`, cast to `int32_t`.
static inline int32_t int32_for_float(float f) { return f; }

/// - returns: `d`, cast to `int32_t`.
static inline int32_t int32_for_double(double d) { return d; }

/// - returns: `d`, cast to `int64_t`.
static inline int64_t int64_for_double(double d) { return d; }

/// - returns: `n / d`.
static inline int32_t int32_divide(int32_t n, int32_t d) { return n / d; }

/// - returns: `n % d`.
static inline int32_t int32_remainder(int32_t n, int32_t d) { return n % d; }

#endif // CWrappers_h
