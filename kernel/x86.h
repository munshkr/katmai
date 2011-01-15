#ifndef __X86_H__
#define __X86_H__

typedef unsigned long long uint64_t;
typedef unsigned int       uint32_t;
typedef unsigned short     uint16_t;
typedef unsigned char      uint8_t;

typedef long long int64_t;
typedef int       int32_t;
typedef short     int16_t;
typedef char      int8_t;


static inline void halt(void) {
	__asm __volatile("hlt");
}

/* Bochs magic breakpoint */
static inline void debug(void) {
  __asm __volatile("xchg %bx, %bx");
}

static inline void init_fpu(void) {
	__asm __volatile("finit");
}

#endif /* __X86_H__ */
