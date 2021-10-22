#include <stdio.h>
#include "utils.h"

int main(void)
{
	int num1 = 10;
	int num2 = -5;
	printf("%d\n", num1);
	printf("%d\n", num2);
	printf("%d\n", num1 / num2);
	printf("%d\n", divide(num1, num2));
}
