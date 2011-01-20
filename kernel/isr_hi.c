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


/* This gets called from our ASM interrupt handler stub */
void isr_handler(registers_t regs)
{
    print("Received interrupt: "); PRINT_DEC(regs.int_no); putln();
}
