/*
* isr_hi.c ~ High level interrupt service routines and interrupt request handlers.
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

#include "isr_hi.h"
#include "video.h"


static void send_EOI(uint8_t irq);


isr_t interrupt_handlers[256];


// This gets called from our ASM interrupt handler stub
void isr_handler(registers_t regs) {
    printf("Received interrupt: %u\n", regs.int_no);
}

// This gets called from our ASM interrupt handler stub
void irq_handler(registers_t regs)
{
    // Send an EOI (end of interrupt) signal to the PICs
    send_EOI(regs.u.irq);

    if (interrupt_handlers[regs.int_no] != 0) {
        isr_t handler = interrupt_handlers[regs.int_no];
        handler(regs);
    }
}

void register_interrupt_handler(uint8_t n, isr_t handler) {
    interrupt_handlers[n] = handler;
}


static void send_EOI(uint8_t irq)
{
    // If this interrupt involved the slave, send reset signal
    if (irq >= 8)
        outb(PIC2_COMMAND, PIC_EOI);

    // Send reset signal to master
    outb(PIC1_COMMAND, PIC_EOI);
}
