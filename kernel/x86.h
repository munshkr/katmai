#ifndef __X86_H__
#define __X86_H__

static inline void halt(void) {
	__asm __volatile("hlt");
}

/* Bochs magic breakpoint */
static inline void debug(void) {
  __asm __volatile("xchg %bx, %bx");
}

#endif
