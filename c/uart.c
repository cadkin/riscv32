#include "uart.h"

#define INT_OFFSET 48

// Initialize UART
char uart_init() {
    volatile char * base_ptr = (char *)UART_BASE_ADDR;  // 0xaaaaa400
    // Set Line Control Register (LCR)
    // I/O port: base + 3
    // 8 data bits
    // 1 stop bit
    // No parity
    // Break signal disabled
    // DLAB: DLL and DLM accessible
    *(base_ptr + 3) = (1 << 7) | (3);
    // Baud Rate Divisor
    // Divisor = 54
    // Speed = 2133.33 bps
    char baud_lower = 54;
    // Set Divisor Latch LSB (DLL) = 0x36
    *(base_ptr) = baud_lower;
    // Set Divisor Latch MSB (DLM) = 0x00
    *(base_ptr + 1) = 0;
    // Reset Line Control (LCR)
    // I/O port: base + 3
    // DLAB: RBR, THR and IER accessible
    *(base_ptr + 3) = 3; 
    // Set FIFO Control (FCR)
    // Enable FIFOs
    // Select DMA mode 0
    // 1 byte
    *(base_ptr + 2) = 1;
    // Set Interrupt Enable (IER) = 0x01
    // An interrupt may take place
    *(base_ptr + 1) = 1; 
    return 1; 
}

// Write a byte to UART
void uart_put(char c) {
    // Write a byte to the Transmitter Holding Register (THR)
    volatile char * p = (char *)UART_BASE_ADDR; 
    *p = c; 
}

// Poll until ready and write a byte to UART
void uart_put_blocking(char c) {
    char s;
    // Check Line Status Register (LSR) for state of Transmitter Holding Register (THR)
    do {
        s = uart_poll() & 96;  // Check THR empty state
    } while (s == 0);          // Once THR is empty... (either bit 5 or 6 is high)

    // Write data to the THR
    uart_put(c);
}

// Read a byte from UART
char uart_get() {
    // Read a byte from the Receiver Buffer Register (RBR)
    volatile char *p = (char *)UART_BASE_ADDR;
    return *p; 
}

// Poll UART status
char uart_poll() {
    // Check the Line Status Register (LSR)
    volatile char * base_ptr = (char *)UART_BASE_ADDR; 
    return *(base_ptr + 5);
}

// Poll until ready and read a byte from UART
char uart_read_blocking()
{
    char s;
    // Check Line Status Register (LSR) for state of Receiver Buffer Register (RBR)
    do
    {
        s = uart_poll() & 1;  // Check if data available
    } while (s == 0);         // Once data is available... (bit 0 is high)

    // Read data from the RBR
    return uart_get();
}

// Write a line to UART
void uart_print(char c[])
{
    char *ptr = &c[0];  // Get data to be written
    int offset = 0;
    while(*(ptr + offset) != '\0') {  // Write data until reaching null character
        if (offset == 0)                         // Initially before writing first char...
            uart_put_blocking(*(ptr + offset));  // Wait for THR to be empty before writing
        else
            uart_put(*(ptr + offset));           // Write the rest of the bytes
        offset++;
    }
}

// Read a line from UART
void readline(char c[], int len)
{
    for (int i = 0; i < len; i++)  // Read [len] bytes from UART
    {
        char tmp;
        tmp = uart_read_blocking();  // Poll RBR until data is available
        if (tmp == 13) {  // If byte received is carriage return (\r)...
            for (int j = i; j < len; j++) c[j] = 0;  // Zero out the rest of the string
            uart_put('\r');                          // Write CR+LF to the THR
            uart_put('\n');
            return;                                  // Finish
        }
        uart_put(tmp);  // Write read byte back to THR
        c[i] = tmp;     // Add byte to string
    }
}

// Get length of a string
int strlen(char c[])
{
    char *ptr = &c[0];

    int offset = 0;
    while (*(ptr + offset) != '\0')
    {
        offset++;
    }

    return offset;
}

// Convert string to integer
int atoi(char *c)
{
    int len = strlen(c);
    int i;
    int sum = 0;
    int mult = 1;

    for (i = (len - 1); i >= 0; i--)
    {
        int tmp = c[i] - INT_OFFSET;

        if (tmp == -3)
        {
            return (0 - sum);
        }
        else if ((tmp >= 0) && (tmp <= 9))
        {
            sum += tmp * mult;
            mult *= 10;
        }
        else
            return -1;
    }

    return sum;
}

// Convert integer to string
void itoa(int a, char *c)
{
    int p1, p2;
    int idx = 0;

    if (a < 0)
    {
        c[idx] = '-';
        a = 0 - a;
        idx++;
    }

    // get placing
    if (a < 10)
    {
        c[idx] = a + INT_OFFSET;
        c[idx + 1] = '\0';

        return;
    }

    p1 = 1;

    while (a / p1 > 0)
        p1 = p1 * 10;

    p2 = p1 / 10;

    while (1)
    {
        int tmp = (a % p1) / p2;
        c[idx] = tmp + INT_OFFSET;
        idx++;

        if ((p2 == 1) || (idx == 12))
        {
            c[idx] = '\0';
            return;
        }

        p2 = p2 / 10;
        p1 = p1 / 10;
    }
}