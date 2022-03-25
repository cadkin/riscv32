#ifndef UART_H
#define UART_H

#define UART_BASE_ADDR 0xaaaaa400

char uart_init(); 

void uart_put(char c);
void uart_put_blocking(char c);
char uart_get();
char uart_poll();
char uart_read_blocking();

void uart_print(char c[]);

void readline(char c[], int len);
int strlen(char c[]);

int atoi(char *c);
void itoa(int a, char *c);
#endif