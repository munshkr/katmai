/*
* descriptor_tables.h ~ Interface and structures for the GDT and IDT
*
* Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
*                Patricio Reboratti <darthpolly@gmail.com>
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

#ifndef __DESCRIPTOR_TABLES_H__
#define __DESCRIPTOR_TABLES_H__


#include "common.h"
#include "isr_hi.h"
#include "string.h"


#define CODE_SEGMENT    0x08
#define INT_GATE_FLAGS  0x8E
#define TRAP_GATE_FLAGS 0x8F



void init_idt(void);


// A struct describing an interrupt gate
struct idt_entry_struct
{
     uint16_t offset_lo;      // The lower 16 bits of the address to jump to when this interrupt fires
     uint16_t selector;       // Kernel segment selector
     uint8_t  reserved;       // This must always be zero
     uint8_t  flags;          // More flags. See documentation
     uint16_t offset_hi;      // The upper 16 bits of the address to jump to
} __attribute__((packed));
typedef struct idt_entry_struct idt_entry_t;


// A struct describing a pointer to an array of interrupt handlers
// This is in a format suitable for giving to 'lidt'
struct idt_ptr_struct
{
     uint16_t limit;
     uint32_t base;           // The address of the first element in our idt_entry_t array
} __attribute__((packed));
typedef struct idt_ptr_struct idt_ptr_t;


// These extern directives let us access the addresses of our ASM ISR handlers
extern void isr0(void);
extern void isr1(void);
extern void isr2(void);
extern void isr3(void);
extern void isr4(void);
extern void isr5(void);
extern void isr6(void);
extern void isr7(void);
extern void isr8(void);
extern void isr9(void);
extern void isr10(void);
extern void isr11(void);
extern void isr12(void);
extern void isr13(void);
extern void isr14(void);
extern void isr15(void);
extern void isr16(void);
extern void isr17(void);
extern void isr18(void);
extern void isr19(void);
extern void isr20(void);
extern void isr21(void);
extern void isr22(void);
extern void isr23(void);
extern void isr24(void);
extern void isr25(void);
extern void isr26(void);
extern void isr27(void);
extern void isr28(void);
extern void isr29(void);
extern void isr30(void);
extern void isr31(void);

extern void irq0(void);
extern void irq1(void);
extern void irq2(void);
extern void irq3(void);
extern void irq4(void);
extern void irq5(void);
extern void irq6(void);
extern void irq7(void);
extern void irq8(void);
extern void irq9(void);
extern void irq10(void);
extern void irq11(void);
extern void irq12(void);
extern void irq13(void);
extern void irq14(void);
extern void irq15(void);


#endif /* __DESCRIPTOR_TABLES_H__ */
