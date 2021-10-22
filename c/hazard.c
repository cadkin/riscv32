int nothing()
{
    return 1;
}

void print(int a)
{
    volatile int *p = (int *)0xaaaaa008;
    *p = a;
}

int main(void)
{
    int num = 1;
    int i = 0;

    int temp = nothing();

    for (i = 0; i < 1; i++)
    {
        num = 2;
    }

    print(num);

    while (1)
        ;
}