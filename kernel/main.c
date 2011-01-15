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
 * but WITHOUT ANY WARRANTY// without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
*/

#include "multiboot.h"
#include "x86.h"
#include "math.h"
#include "video.h"


void kmain(uint32_t magic, multiboot_info_t* mbi) {
  init_fpu();
  clear();

  if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
    puts("Invalid magic code");
    return;
  }

  if (pow(2.0f, 5.0f) == 32.0f) {
    puts("Pow funca");
  } else {
    puts("Todomal");
  }

  puts("Kernel is on!");

  debug();

  /* remove */
  mbi = 0;
}
