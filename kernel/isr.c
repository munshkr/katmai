//
// isr.c -- High level interrupt service routines and interrupt request handlers.
// Part of this code is modified from Bran's kernel development tutorials.
// Rewritten for JamesM's kernel development tutorials.
//

#include "descriptor_tables.h"
#include "video.h"

// This gets called from our ASM interrupt handler stub.
void isr_handler(registers_t regs)
{
  print("Received interrupt: "); PRINT_DEC(regs.int_no); putln();
} 
