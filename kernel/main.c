/*
 * main.c ~ Kernel main procedure
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

#include "common.h"
#include "multiboot.h"
#include "descriptor_tables.h"
#include "video.h"
#include "timer.h"


void kmain(uint32_t magic, multiboot_info_t* mbi) {
    clear();
    printf("Kernel is on!\n");

    if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
        printf("Invalid magic code: %x", magic);
        return;
    }

    // Check if the cpuid instruction is available
    if (check_cpuid()) {
        printf("CPUID available\n");
        if (check_apic()) {
            printf("APIC available\n");
        } else {
            printf("APIC not available\n");
        }
    } else {
        printf("CPUID not available\n");
    }

    // Init the floating point unit
    init_fpu();

    // Initialize the Interrupt Descriptor Table and Interrupt Service Routines
    init_idt();

    // Print (if available) memory map
    if (mbi->flags && MULTIBOOT_INFO_MEM_MAP) {
        uint32_t mmap_entries = mbi->mmap_length / 24;

        printf("## Memory map ##\n");
        printf("Entries: %u\n", mmap_entries);

        multiboot_memory_map_t* mmap_entry = (multiboot_memory_map_t *)
            mbi->mmap_addr;
        for (uint32_t i = 0; i < mmap_entries; ++i, ++mmap_entry) {
            printf("Entry %u\n", i);
            printf("\t.addr: %x\n", mmap_entry->addr);
            printf("\t.len: %u\n", mmap_entry->len);
            printf("\t.type: ");
            if (mmap_entry->type == MULTIBOOT_MEMORY_AVAILABLE) {
                printf("available\n");
            } else {
                printf("reserved\n");
            }
        }
    }

    // Test breakpoint interrupt
    __asm __volatile("int $0x3");

    init_timer(50); // Initialise timer to 50Hz
}
