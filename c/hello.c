#include"print.h"

char hi[] = {'h', 'e', 'l', 'l', 'o'} ;
int charlen = 5; 

int main(void) {
	int i = 0; 
	for (i = 0; i < charlen; i++)
		print(hi[i]);

	while(1);
}
