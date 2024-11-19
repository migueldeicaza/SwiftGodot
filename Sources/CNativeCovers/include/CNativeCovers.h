#ifndef CNativeCovers_h
#define CNativeCovers_h

#include <stdint.h>

/// - returns: `f`, cast to `int32_t`.
static inline int32_t int32_for_float(float f) { return f; }

/// - returns: `n / d`.
static inline int32_t int32_divide(int32_t n, int32_t d) { return n / d; }

/// - returns: `n % d`.
static inline int32_t int32_remainder(int32_t n, int32_t d) { return n % d; }

#endif // CNativeCovers_h
