#include "x86.h"
#include "video.h"

void kmain(void) {
  clear();
	puts("Kernel loaded! :)");
  puts("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwyz0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwyz0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwyz0123456789... testing long lines...");
  for (int i = 0; i < 128; ++i) {
    char n[6] = {'n', 'u', 'm', ' ', i};
    puts(n);
  }
  puts("testing scrolling...");
}
