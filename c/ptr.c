int square(int d){
	int e;
	e=d+d;
	return e;}

void ptr_test(int* c,int d){
	int b[2];
	b[0]=500;
	b[1]=600;
	b[2]=700;
	b[3]=800;
	b[4]=1000;
	b[5]=1200;
	b[6]=1400;
	*c=square(b[2]);
	}


int a=9;

int main(){
	int *p;
	int b=42;
	p=&a;
	ptr_test(p,b);
	return 0;
		
}
