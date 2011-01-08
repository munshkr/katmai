Bootloader
==========

Memory map
----------

Conventional memory
* 0x7c00-0x7dff --> bootstrap loader
* 0x7e00-?      --> second stage

Upper memory area (UMA)
* 0x70000-0x7fe00 --> 64kb buffer for loading kernel to HMA

High memory area (HMA)
* 0x100000 --> kernel
