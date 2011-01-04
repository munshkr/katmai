==========================================
Trabajo Práctico/Proyecto final para Orga2
==========================================

* Microkernel minimalista basado en la familia L4
* Second-stage bootloader

Microkernel
===========

* Address spaces
* Threads
* IPC

Servidores
==========

* Memory manager
* File system manager
* Scheduler (round robin)
* Drivers

  - FS (fat12/fat16/ext2, ver cual es más sencillo)
  - video (memory-mapped IO)
  - teclado (port-based IO)

Aplicaciones
============

* Shell (ejecuta binarios)
* Binarios que jueguen con video (demos graficas?)

Documento
=========

Introducción
------------

* Kernels monolíticos y microkernels, sus ventajas y desventajas.
* Microkernel basado en MINIX y L4

Desarrollo
----------

* Roadmap
* Bootloader
* Tareas, threads, address spaces
* IPC
* Scheduler
* MM
* FS driver y FSM
* Drivers de video, teclado

Conclusión
----------

Apéndice
--------

* Layout del código fuente
