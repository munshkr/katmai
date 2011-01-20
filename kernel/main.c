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

#include "x86.h"
#include "multiboot.h"
#include "descriptor_tables.h"
#include "video.h"


void print_mbi(multiboot_info_t* mbi) {
    println("## Multiboot Info ##");

    print(".flags: "); PRINT_HEX(mbi->flags); putln();

    print(".mem_lower: "); PRINT_HEX(mbi->mem_lower); putln();
    print(".mem_upper: "); PRINT_HEX(mbi->mem_upper); putln();

    print(".boot_device: "); PRINT_HEX(mbi->boot_device); putln();

    print(".cmdline: "); PRINT_HEX(mbi->cmdline); putln();

    print(".mods_count: "); PRINT_DEC(mbi->mods_count); putln();
    print(".mods_addr: "); PRINT_HEX(mbi->mods_addr); putln();
}

void kmain(uint32_t magic, multiboot_info_t* mbi) {
    clear();
    println("Kernel is on!"); putln();

    if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
        print("Invalid magic code: "); PRINT_HEX(magic); putln();
        return;
    }

    /* Init the floating point unit */
    init_fpu();

    /* Initialize the Interrupt Descriptor Table and
       Interrupt Service Routines */
    init_idt();

    /* Print Multiboot information structure */
    print_mbi(mbi); putln();

    /* Print (if available) memory map */
    if (mbi->flags && MULTIBOOT_INFO_MEM_MAP) {
        uint32_t mmap_entries = mbi->mmap_length / 24;

        println("## Memory map ##");
        print("Entries: "); PRINT_DEC(mmap_entries); putln();

        multiboot_memory_map_t* mmap_entry = (multiboot_memory_map_t *)
            mbi->mmap_addr;
        for (uint32_t i = 0; i < mmap_entries; ++i, ++mmap_entry) {
            print("Entry "); PRINT_DEC(i); putln();
            print("  .addr: "); PRINT_HEX(mmap_entry->addr); putln();
            print("  .len: "); PRINT_DEC(mmap_entry->len); putln();
            print("  .type: ");
            if (mmap_entry->type == MULTIBOOT_MEMORY_AVAILABLE) {
                println("available");
            } else {
                println("reserved");
            }
        }
    }

    /* Test breakpoint interrupt */
    __asm __volatile("int $0x3");
}
