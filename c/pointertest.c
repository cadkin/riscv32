#include"print.h" 

int main(void) {
	int a = 5; 
	int * ptr = &a; 
	print(a);
    a += 5;	
	print(*ptr);
	a += 5; 
	print(a);
	a += 5;
	print(*ptr);
	while(1);	
	return 0;
}
