/*
 * multiboot.h ~ Multiboot header macros for kernel
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

/*
 * Source from example code of GNU Multiboot specification version 0.6.96
 * and adapted to NASM syntax.
 *
 * http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
*/

#ifndef __MULTIBOOT_H__
#define __MULTIBOOT_H__


#include "common.h"


// How many bytes from the start of the file we search for the header
#define MULTIBOOT_SEARCH                        8192

// The magic field should contain this
#define MULTIBOOT_HEADER_MAGIC                  0x1badb002

// This should be in %eax
#define MULTIBOOT_BOOTLOADER_MAGIC              0x2badb002

// The bits in the required part of flags field we don't support
#define MULTIBOOT_UNSUPPORTED                   0x0000fffc

// Alignment of multiboot modules
#define MULTIBOOT_MOD_ALIGN                     0x00001000

// Alignment of the multiboot info structure
#define MULTIBOOT_INFO_ALIGN                    0x00000004

// Flags set in the 'flags' member of the multiboot header

// Align all boot modules on i386 page (4KB) boundaries
#define MULTIBOOT_PAGE_ALIGN                    0x00000001

// Must pass memory information to OS
#define MULTIBOOT_MEMORY_INFO                   0x00000002

// Must pass video information to OS
#define MULTIBOOT_VIDEO_MODE                    0x00000004

// This flag indicates the use of the address fields in the header
#define MULTIBOOT_AOUT_KLUDGE                   0x00010000

// Flags to be set in the 'flags' member of the multiboot info structure

// is there basic lower/upper memory information?
#define MULTIBOOT_INFO_MEMORY                   0x00000001
// is there a boot device set?
#define MULTIBOOT_INFO_BOOTDEV                  0x00000002
// is the command-line defined?
#define MULTIBOOT_INFO_CMDLINE                  0x00000004
// are there modules to do something with?
#define MULTIBOOT_INFO_MODS                     0x00000008

// These next two are mutually exclusive

// is there a symbol table loaded?
#define MULTIBOOT_INFO_AOUT_SYMS                0x00000010
// is there an ELF section header table?
#define MULTIBOOT_INFO_ELF_SHDR                 0x00000020

// is there a full memory map?
#define MULTIBOOT_INFO_MEM_MAP                  0x00000040

// Is there drive info?
#define MULTIBOOT_INFO_DRIVE_INFO               0x00000080

// Is there a config table?
#define MULTIBOOT_INFO_CONFIG_TABLE             0x00000100

// Is there a boot loader name?
#define MULTIBOOT_INFO_BOOT_LOADER_NAME         0x00000200

// Is there a APM table?
#define MULTIBOOT_INFO_APM_TABLE                0x00000400

// Is there video information?
#define MULTIBOOT_INFO_VIDEO_INFO               0x00000800


struct multiboot_header
{
    // Must be MULTIBOOT_MAGIC - see above
    uint32_t magic;

    // Feature flags
    uint32_t flags;

    // The above fields plus this one must equal 0 mod 2^32
    uint32_t checksum;

    // These are only valid if MULTIBOOT_AOUT_KLUDGE is set
    uint32_t header_addr;
    uint32_t load_addr;
    uint32_t load_end_addr;
    uint32_t bss_end_addr;
    uint32_t entry_addr;

    // These are only valid if MULTIBOOT_VIDEO_MODE is set
    uint32_t mode_type;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
};

// The symbol table for a.out
struct multiboot_aout_symbol_table
{
    uint32_t tabsize;
    uint32_t strsize;
    uint32_t addr;
    uint32_t reserved;
};
typedef struct multiboot_aout_symbol_table multiboot_aout_symbol_table_t;

// The section header table for ELF
struct multiboot_elf_section_header_table
{
    uint32_t num;
    uint32_t size;
    uint32_t addr;
    uint32_t shndx;
};
typedef struct multiboot_elf_section_header_table multiboot_elf_section_header_table_t;

struct multiboot_info
{
    // Multiboot info version number
    uint32_t flags;

    // Available memory from BIOS
    uint32_t mem_lower;
    uint32_t mem_upper;

    // "root" partition
    uint32_t boot_device;

    // Kernel command line
    uint32_t cmdline;

    // Boot-Module list
    uint32_t mods_count;
    uint32_t mods_addr;

    union
    {
      multiboot_aout_symbol_table_t aout_sym;
      multiboot_elf_section_header_table_t elf_sec;
    } u;

    // Memory Mapping buffer
    uint32_t mmap_length;
    uint32_t mmap_addr;

    // Drive Info buffer
    uint32_t drives_length;
    uint32_t drives_addr;

    // ROM configuration table
    uint32_t config_table;

    // Boot Loader Name
    uint32_t boot_loader_name;

    // APM table
    uint32_t apm_table;

    // Video
    uint32_t vbe_control_info;
    uint32_t vbe_mode_info;
    uint16_t vbe_mode;
    uint16_t vbe_interface_seg;
    uint16_t vbe_interface_off;
    uint16_t vbe_interface_len;
};
typedef struct multiboot_info multiboot_info_t;

struct multiboot_mmap_entry
{
    uint64_t addr;
    uint64_t len;
#define MULTIBOOT_MEMORY_AVAILABLE              1
#define MULTIBOOT_MEMORY_RESERVED               2
    uint32_t type;
    uint32_t acpi;
} __attribute__((packed));
typedef struct multiboot_mmap_entry multiboot_memory_map_t;

struct multiboot_mod_list
{
    // the memory used goes from bytes 'mod_start' to 'mod_end-1' inclusive
    uint32_t mod_start;
    uint32_t mod_end;

    // Module command line
    uint32_t cmdline;

    // padding to take it to 16 bytes (must be zero)
    uint32_t pad;
};
typedef struct multiboot_mod_list multiboot_module_t;


#endif /* __MULTIBOOT_H__ */
