/*
* descriptor_tables.c ~ GDT and IDT initialization routines
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

#include "descriptor_tables.h"


static void idt_set_gate(uint8_t index, uint32_t offset, uint16_t selector, uint8_t flags);


const uint32_t CODE_SEGMENT    = 0x08;
const uint32_t INT_GATE_FLAGS  = 0x8E;
const uint32_t TRAP_GATE_FLAGS = 0x8F;


idt_entry_t idt_entries[256] __attribute__ ((aligned (8)));
idt_ptr_t   idt_ptr;


void init_idt()
{
   idt_ptr.limit = sizeof(idt_entry_t) * 256 - 1;
   idt_ptr.base  = (uint32_t) &idt_entries;

   memset((uint32_t*) &idt_entries, 0, sizeof(idt_entry_t) * 256);

   /* TODO ? Put ISR functions inside an array and make this a for loop */
   idt_set_gate( 0, (uint32_t) isr0 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 1, (uint32_t) isr1 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 2, (uint32_t) isr2 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 3, (uint32_t) isr3 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 4, (uint32_t) isr4 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 5, (uint32_t) isr5 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 6, (uint32_t) isr6 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 7, (uint32_t) isr7 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 8, (uint32_t) isr8 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate( 9, (uint32_t) isr9 , CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(10, (uint32_t) isr10, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(11, (uint32_t) isr11, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(12, (uint32_t) isr12, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(13, (uint32_t) isr13, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(14, (uint32_t) isr14, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(15, (uint32_t) isr15, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(16, (uint32_t) isr16, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(17, (uint32_t) isr17, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(18, (uint32_t) isr18, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(19, (uint32_t) isr19, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(20, (uint32_t) isr20, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(21, (uint32_t) isr21, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(22, (uint32_t) isr22, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(23, (uint32_t) isr23, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(24, (uint32_t) isr24, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(25, (uint32_t) isr25, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(26, (uint32_t) isr26, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(27, (uint32_t) isr27, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(28, (uint32_t) isr28, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(29, (uint32_t) isr29, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(30, (uint32_t) isr30, CODE_SEGMENT, INT_GATE_FLAGS);
   idt_set_gate(31, (uint32_t) isr31, CODE_SEGMENT, INT_GATE_FLAGS);

   load_idt((void *) &idt_ptr);
}

static void idt_set_gate(uint8_t index, uint32_t offset, uint16_t selector, uint8_t flags)
{
   idt_entries[index].offset_lo = offset & 0xFFFF;
   idt_entries[index].offset_hi = (offset >> 16) & 0xFFFF;

   idt_entries[index].selector = selector;
   idt_entries[index].reserved = 0;
   /* We must uncomment the OR below when we get to using user-mode.
      It sets the interrupt gate's privilege level to 3. */
   idt_entries[index].flags = flags /* | 0x60 */;
}
