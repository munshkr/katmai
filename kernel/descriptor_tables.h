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


#include "x86.h"
#include "string.h"


void init_idt();


/* A struct describing an interrupt gate */
struct idt_entry_struct
{
     uint16_t offset_lo;      /* The lower 16 bits of the address to jump to when this interrupt fires */
     uint16_t selector;       /* Kernel segment selector */
     uint8_t  reserved;       /* This must always be zero */
     uint8_t  flags;          /* More flags. See documentation */
     uint16_t offset_hi;      /* The upper 16 bits of the address to jump to */
} __attribute__((packed));
typedef struct idt_entry_struct idt_entry_t;


/* A struct describing a pointer to an array of interrupt handlers */
/* This is in a format suitable for giving to 'lidt' */
struct idt_ptr_struct
{
     uint16_t limit;
     uint32_t base;           /* The address of the first element in our idt_entry_t array */
} __attribute__((packed));
typedef struct idt_ptr_struct idt_ptr_t;


/* These extern directives let us access the addresses of our ASM ISR handlers */
extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr16();
extern void isr17();
extern void isr18();
extern void isr19();
extern void isr20();
extern void isr21();
extern void isr22();
extern void isr23();
extern void isr24();
extern void isr25();
extern void isr26();
extern void isr27();
extern void isr28();
extern void isr29();
extern void isr30();
extern void isr31();


#endif /* __DESCRIPTOR_TABLES_H__ */
