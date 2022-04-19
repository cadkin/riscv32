#include "spi.h"
#include "print.h" 

int main(void) {
	char s = 85;
	spi_write(s);
	s = 42;
	spi_write(s);
	s = 55;
	spi_write(s);
	s = 12;
	spi_write(s);

	while(!(spi_poll() & 1));

	s = spi_read(); 
	print(s);

	while(!(spi_poll() & 1));

	s = spi_read(); 
	print(s);

	while(!(spi_poll() & 1));

	s = spi_read(); 
	print(s);

	while(!(spi_poll() & 1));

	s = spi_read(); 
	print(s);
}