;
; multiboot.s ~ Multiboot information structure
;
; Copyright 2010 Damián Emiliano Silvani <dsilvani@gmail.com>,
;                Patricio Reboratti <darthpolly@gmail.com>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

MULTIBOOT_INFO_MEM_MAP            equ 0x00000040

MULTIBOOT_INFO_FLAGS    equ MULTIBOOT_INFO_MEM_MAP


multiboot_info:
    dd MULTIBOOT_INFO_FLAGS

    times 10 dd 0

    mmap_length dd 0
    dd MMAP_ADDRESS
