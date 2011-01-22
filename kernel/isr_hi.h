/*
* isr_hi.h ~ Interface and structures for high level interrupt service routines.
*
* Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
*                Patricio Reboratti <darthpolly@gmail.com>
*
* Part of this code is modified from Bran's kernel development tutorials
* and JamesM's kernel development tutorials.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*/

#ifndef __ISR_HI_H__
#define __ISR_HI_H__


#include "common.h"


// Commands for the 8259 PIC
#define PIC1            0x20      // IO base address for master PIC
#define PIC2            0xA0      // IO base address for slave PIC
#define PIC1_COMMAND    PIC1
#define PIC1_DATA       (PIC1+1)
#define PIC2_COMMAND    PIC2
#define PIC2_DATA       (PIC2+1)

// Instruction Command Words for 8259 PIC (flags for initialization)
#define ICW1_ICW4       0x01    // ICW4 (not) needed
#define ICW1_SINGLE     0x02    // Single (cascade) mode
#define ICW1_INTERVAL4  0x04    // Call address interval 4 (8)
#define ICW1_LEVEL      0x08    // Level triggered (edge) mode
#define ICW1_INIT       0x10    // Initialization - required!

#define ICW4_8086       0x01    // 8086/88 (MCS-80/85) mode
#define ICW4_AUTO       0x02    // Auto (normal) EOI
#define ICW4_BUF_SLAVE  0x08    // Buffered mode/slave
#define ICW4_BUF_MASTER 0x0C    // Buffered mode/master
#define ICW4_SFNM       0x10    // Special fully nested (not)

// End-of-interrupt command code
#define PIC_EOI         0x20

// PIC vector offsets set _just above_ IA-32 exceptions
#define PIC1_OFFSET     0x20
#define PIC2_OFFSET     0x28

// IRQs mapping is defined here
#define IRQ0  (PIC1_OFFSET+0)
#define IRQ1  (PIC1_OFFSET+1)
#define IRQ2  (PIC1_OFFSET+2)
#define IRQ3  (PIC1_OFFSET+3)
#define IRQ4  (PIC1_OFFSET+4)
#define IRQ5  (PIC1_OFFSET+5)
#define IRQ6  (PIC1_OFFSET+6)
#define IRQ7  (PIC1_OFFSET+7)

#define IRQ8  (PIC2_OFFSET+0)
#define IRQ9  (PIC2_OFFSET+1)
#define IRQ10 (PIC2_OFFSET+2)
#define IRQ11 (PIC2_OFFSET+3)
#define IRQ12 (PIC2_OFFSET+4)
#define IRQ13 (PIC2_OFFSET+5)
#define IRQ14 (PIC2_OFFSET+6)
#define IRQ15 (PIC2_OFFSET+7)


struct registers
{
    uint32_t ds;                  // Data segment selector
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha
    uint32_t int_no;              // Interrupt number
    union {
      uint32_t err_code;          // Error code (if applicable)
      uint32_t irq;               // IRQ number (if we are in a IRQ handler)
    } u;
    uint32_t eip, cs, eflags, useresp, ss; // Pushed by the processor automatically
} __attribute__((packed));
typedef struct registers registers_t;

typedef void (*isr_t)(registers_t);


// Enables registration of callbacks for interrupts or IRQs.
// For IRQs, to ease confusion, use the #defines above as the
// first parameter.
void register_interrupt_handler(uint8_t n, isr_t handler);


#endif /* __ISR_HI_H__ */
