/*
* common.h ~ Common x86 kernel procedures and functions
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

#ifndef __COMMON_H__
#define __COMMON_H__


typedef unsigned long long uint64_t;
typedef unsigned int       uint32_t;
typedef unsigned short     uint16_t;
typedef unsigned char      uint8_t;
typedef uint32_t bool;

typedef long long int64_t;
typedef int       int32_t;
typedef short     int16_t;
typedef char      int8_t;

extern bool check_cpuid(void);
extern bool check_apic(void);

static inline void halt(void) {
    __asm __volatile("hlt");
}

// Bochs magic breakpoint
static inline void debug(void) {
    __asm __volatile("xchg %bx, %bx");
}

static inline void init_fpu(void) {
    __asm __volatile("finit");
}

static inline void load_idt(void* base_addr) {
    __asm __volatile("lidt (%0)" : : "r" (base_addr));
}

// Read a byte in the specified port
static inline uint8_t inb(uint16_t port) {
   uint8_t ret;
   __asm __volatile("inb %1, %0" : "=a" (ret) : "dN" (port));
   return ret;
}

// Write a byte out to the specified port
static inline void outb(uint16_t port, uint8_t value) {
    __asm __volatile("outb %1, %0" : : "dN" (port), "a" (value));
}


#endif /* __COMMON_H__ */
