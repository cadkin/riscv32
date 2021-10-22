#include<stdlib.h>
#include"print.h" 

struct test {
	int val;
	int val2;
};

struct test t1; //= {15, 20};
struct test t2; 
int main(void) {
	// struct test t1;
	// struct test t2; 
	t1.val = 10;
	print(t1.val); 
	t2.val = 99;
	t1.val2 = 11;
	t1.val = 16;
	print(t1.val); 
	return 0;
}