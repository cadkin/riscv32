
int triangular(int a){
	if (a == 1) 
		return a;
	else 
		return a + triangular(a - 1); 
}

int main(void) {
	int a = 3; 
	int tot = triangular(a);
	return 0;
}