#include "string.h"


void memset(uint32_t* addr, const uint32_t value, const uint32_t size) {
  for (uint32_t i = 0; i < size; ++i) {
    *addr++ = value;
  }
}
