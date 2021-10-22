/**************************************************************
* Mark Lee
* C implementation of AES algorithm
* September 11, 2020
*
* This program implements the AES encryption standard in C
* for cipher sizes of 128, 192, and 256 bits in accordance with
* the FIPS specification. It encrypts and decrypts a 128-bit
* plaintext message using the 3 keys, mimicking the output of
* Appendix C within the FIPS specification.
*
***************************************************************/
 
#include "print.h"

//Substitution table for the encryption process
unsigned char Sbox[16][16] = {
	{ 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76 },
	{ 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0 },
	{ 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15 },
	{ 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75 },
	{ 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84 },
	{ 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf },
	{ 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8 },
	{ 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2 },
	{ 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73 },
	{ 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb },
	{ 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79 },
	{ 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08 },
	{ 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a },
	{ 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e },
	{ 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf },
	{ 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16 }
};

//Inverse substitution table for the decryption process
unsigned char invSbox[16][16] = {
	{ 0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb } ,
	{ 0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb } ,
	{ 0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e } ,
	{ 0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25 } ,
	{ 0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92 } ,
	{ 0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84 } ,
	{ 0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06 } ,
	{ 0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b } ,
	{ 0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73 } ,
	{ 0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e } ,
	{ 0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b } ,
	{ 0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4 } ,
	{ 0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f } ,
	{ 0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef } ,
	{ 0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61 } ,
	{ 0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d }
};

//Round constant table
unsigned int Rcon[52] = { 0x00000000,
	0x01000000, 0x02000000, 0x04000000, 0x08000000,
	0x10000000, 0x20000000, 0x40000000, 0x80000000,
	0x1B000000, 0x36000000, 0x6C000000, 0xD8000000,
	0xAB000000, 0x4D000000, 0x9A000000, 0x2F000000,
	0x5E000000, 0xBC000000, 0x63000000, 0xC6000000,
	0x97000000, 0x35000000, 0x6A000000, 0xD4000000,
	0xB3000000, 0x7D000000, 0xFA000000, 0xEF000000,
	0xC5000000, 0x91000000, 0x39000000, 0x72000000,
	0xE4000000, 0xD3000000, 0xBD000000, 0x61000000,
	0xC2000000, 0x9F000000, 0x25000000, 0x4A000000,
	0x94000000, 0x33000000, 0x66000000, 0xCC000000,
	0x83000000, 0x1D000000, 0x3A000000, 0x74000000,
	0xE8000000, 0xCB000000, 0x8D000000};

//Substitutes each byte in the input word with a value from the Sbox
unsigned int subWord(unsigned int w)
{
	unsigned int s0, s1, s2, s3;
	unsigned int r;
	s0 = Sbox[w >> 28][w << 4 >> 28];
	s1 = Sbox[w << 8 >> 28][w << 12 >> 28];
	s2 = Sbox[w << 16 >> 28][w << 20 >> 28];
	s3 = Sbox[w << 24 >> 28][w << 28 >> 28];
	r = (s0 << 24) | (s1 << 16) | (s2 << 8) | s3;
	return r;
}

//Rotate the bytes within the word
unsigned int rotWord(unsigned int w) { return (w >> 24) | (w << 8); }

//Expand the initial cipher key into an array of round keys
void keyExpansion(unsigned char *key, unsigned int *w, unsigned char Nb, unsigned char Nk, unsigned char Nr)
{
	unsigned int temp, num_keys, i, b0, b1, b2, b3;

	num_keys = Nb * (Nr+1);

	//Insert the original cipher key into the array
	for(i = 0; i < Nk; i++) {
		b0 = key[i*4]; b1 = key[i*4+1]; b2 = key[i*4+2]; b3 = key[i*4+3];
		w[i] = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
	}

	//For each round, create a permutation of the cipher that applies
	//to each round, using subWord and rotWord
	for(i = Nk; i < num_keys; i++) {
		temp = w[i-1];

		if(i % Nk == 0)
			temp = subWord(rotWord(temp)) ^ Rcon[i/Nk];
		else if((Nk > 6) & (i % Nk == 4))
			temp = subWord(temp);

		w[i] = w[i-Nk] ^ temp;
	}
}

//Finite Field Addition
unsigned char ffAdd(unsigned char a, unsigned char b) { return a ^ b; }

//Finite Field Multiplication by x = 2
unsigned char xtime(unsigned char a)
{
	unsigned char b = 1 << 7;
	if(a & b) return (a << 1) ^ 0x1b;
	return a << 1;
}

//Finite Field Multiplication by arbitrary x
unsigned char ffMultiply(unsigned char a, unsigned char b)
{
	int i;
	unsigned char r = 0, temp = a;

	if(b & 1) r = a;
	b = b >> 1;
	for(i = 1; i < 8; i++) {
		temp = xtime(temp);
		if(b & 1) r ^= temp;
		b = b >> 1;
	}
	return r;
}

//Substitute bytes in the State with corresponding Sbox values
void subBytes(unsigned char State[4][4])
{
	int r, c;
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			State[r][c] = Sbox[State[r][c] >> 4][State[r][c] & 0x0F];
		}
	}
}

//Shift rows 1, 2, and 3 in the State to produce diffusion
void shiftRows(unsigned char State[4][4])
{
	unsigned int temp;

	temp = State[1][0];
	State[1][0] = State[1][1];
	State[1][1] = State[1][2];
	State[1][2] = State[1][3];
	State[1][3] = temp;

	temp = State[2][0];
	State[2][0] = State[2][2];
	State[2][2] = temp;
	temp = State[2][1];
	State[2][1] = State[2][3];
	State[2][3] = temp;

	temp = State[3][0];
	State[3][0] = State[3][3];
	State[3][3] = State[3][2];
	State[3][2] = State[3][1];
	State[3][1] = temp;
}

//Matrix multiply each value in the State to produce diffusion
void mixColumns(unsigned char State[4][4])
{
	int c;
	unsigned char b0, b1, b2, b3;

	for(c = 0; c < 4; c++) {
		b0 = State[0][c]; b1 = State[1][c]; b2 = State[2][c]; b3 = State[3][c];
		State[0][c] = xtime(b0) ^ ffMultiply(0x03, b1) ^ b2 ^ b3;
		State[1][c] = b0 ^ xtime(b1) ^ ffMultiply(0x03, b2) ^ b3;
		State[2][c] = b0 ^ b1 ^ xtime(b2) ^ ffMultiply(0x03, b3);
		State[3][c] = ffMultiply(0x03, b0) ^ b1 ^ b2 ^ xtime(b3);
	}
}

//Xor each value in the State with its corresponding bytes in the round key
void addRoundKey(unsigned char State[4][4], unsigned int *w, unsigned char start, unsigned char end)
{
	int i, c = 0;
	for(i = start; i <= end; i++) {
		State[0][c] ^= (w[i] >> 24);
		State[1][c] ^= (w[i] >> 16);
		State[2][c] ^= (w[i] >> 8);
		State[3][c] ^= w[i];
		c++;
	}
}

//Printing functions for debugging and output
/*
void printState(unsigned char State[4][4])
{
	int r, c;
	for(c = 0; c < 4; c++) {
		for(r = 0; r < 4; r++) {
			printf("%02x", State[r][c]);
		}
	}
	printf("\n");
}

void printByteArray(unsigned char *arr, int size)
{
	int i;
	for(i = 0; i < size; i++) printf("%02x", arr[i]);
	printf("\n");
}

void printWordArray(unsigned int *arr, unsigned char start, unsigned char end)
{
	int i;
	for(i = start; i <= end; i++) printf("%08x", arr[i]);
	printf("\n");
}
*/

//Main encryption function, following pseudocode in FIPS specification
void Cipher(unsigned char *input, unsigned char *output, unsigned int *w, unsigned char Nb, unsigned char Nr)
{
	int r, c;
	unsigned char i = 0;
	unsigned char State[4][4];

	//Initialize State with input plaintext
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			State[r][c] = input[r + 4*c];
		}
	}

	addRoundKey(State, w, 0, Nb-1);

	//In each round of encryption, implement subBytes, shiftRows,
	//mixColumns, and addRoundKey to properly permute the State
	for(i = 1; i <= Nr-1; i++) {
		subBytes(State);
		shiftRows(State);
		mixColumns(State);
		addRoundKey(State, w, i*Nb, (i+1)*Nb-1);
	}

	//Apply final round of encryption, skipping mixColumns
	subBytes(State);
	shiftRows(State);
	addRoundKey(State, w, Nr*Nb, (Nr+1)*Nb-1);

	//Transfer State to output (ciphertext) array
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			output[r + 4*c] = State[r][c];
		}
	}
}

//Reverses the shiftRows function
void invShiftRows(unsigned char State[4][4])
{
	unsigned int temp;

	temp = State[1][3];
	State[1][3] = State[1][2];
	State[1][2] = State[1][1];
	State[1][1] = State[1][0];
	State[1][0] = temp;

	temp = State[2][0];
	State[2][0] = State[2][2];
	State[2][2] = temp;
	temp = State[2][1];
	State[2][1] = State[2][3];
	State[2][3] = temp;

	temp = State[3][0];
	State[3][0] = State[3][1];
	State[3][1] = State[3][2];
	State[3][2] = State[3][3];
	State[3][3] = temp;
}

//Reverses the subBytes function using the invSbox
void invSubBytes(unsigned char State[4][4])
{
	int r, c;
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			State[r][c] = invSbox[State[r][c] >> 4][State[r][c] & 0x0F];
		}
	}
}

//Reverses the mixColumns function
void invMixColumns(unsigned char State[4][4])
{
	int c;
	unsigned char b0, b1, b2, b3;

	for(c = 0; c < 4; c++) {
		b0 = State[0][c]; b1 = State[1][c]; b2 = State[2][c]; b3 = State[3][c];
		State[0][c] = ffMultiply(0x0e, b0) ^ ffMultiply(0x0b, b1) ^ ffMultiply(0x0d, b2) ^ ffMultiply(0x09, b3);
		State[1][c] = ffMultiply(0x09, b0) ^ ffMultiply(0x0e, b1) ^ ffMultiply(0x0b, b2) ^ ffMultiply(0x0d, b3);
		State[2][c] = ffMultiply(0x0d, b0) ^ ffMultiply(0x09, b1) ^ ffMultiply(0x0e, b2) ^ ffMultiply(0x0b, b3);
		State[3][c] = ffMultiply(0x0b, b0) ^ ffMultiply(0x0d, b1) ^ ffMultiply(0x09, b2) ^ ffMultiply(0x0e, b3);
	}
}

//Primary decryption function, reversing the Cipher function
void invCipher(unsigned char *input, unsigned char *output, unsigned int *w, unsigned char Nb, unsigned char Nr)
{
	int r, c;
	unsigned char i, j = 0;
	unsigned char State[4][4];

	//Load the input encryted message into the State
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			State[r][c] = input[r + 4*c];
		}
	}

	addRoundKey(State, w, Nr*Nb, (Nr+1)*Nb-1);

	//Reverse each round of encryption by repeatedly applying invShiftRows,
	//invSubBytes, addRoundKey, and invMixColumns
	for(i = Nr-1; i > 0; i--) {
		j++;
		invShiftRows(State);
		invSubBytes(State);
		addRoundKey(State, w, i*Nb, (i+1)*Nb-1);
		invMixColumns(State);
	}

	//Apply final round of decryption, skipping invMixColumns
	j++;
	invShiftRows(State);
	invSubBytes(State);
	addRoundKey(State, w, 0, Nb-1);

	//Transfer decryption plaintext message into output array
	for(r = 0; r < 4; r++) {
		for(c = 0; c < 4; c++) {
			output[r + 4*c] = State[r][c];
		}
	}
}

int main()
{
	unsigned char Nb = 4, Nk, Nr;

	//Fixed 128-bit block width (Nb = 4) in the AES standard
	unsigned char plaintext[16] = { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
					0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff };
	unsigned char ciphertext[16];


	//128, 192, and 256 bit ciphers from FIPS Appendix C
	unsigned char key128[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
				    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};

	/*unsigned char key192[24] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
						  0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
						  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17};

	unsigned char key256[32] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
						  0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
						  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
						  0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f};
	*/

	//Key Expansion arrays for 128, 192, and 256 bit ciphers. Size = Nb*(Nr+1)
	unsigned int w128[44];
	unsigned int w192[52];
	unsigned int w256[60];

	//AES TEST CASE 1: 128-bit cipher encryption/decryption
	Nk = 4; Nr = 10;

	keyExpansion(key128, w128, Nb, Nk, Nr);
	Cipher(plaintext, ciphertext, w128, Nb, Nr);
	int i;
	for(i = 0; i < 16; i++) print(ciphertext[i]);
	while(1);

	//invCipher(ciphertext, plaintext, w128, Nb, Nr);

	//AES TEST CASE 2: 192-bit cipher encryption/decryption
	/*Nk = 6; Nr = 12;

	keyExpansion(key192, w192, Nb, Nk, Nr);
	Cipher(plaintext, ciphertext, w192, Nb, Nr);
	invCipher(ciphertext, plaintext, w192, Nb, Nr);

	//AES TEST CASE 3: 256-bit cipher encryption/decryption
	Nk = 8; Nr = 14;

	keyExpansion(key256, w256, Nb, Nk, Nr);
	Cipher(plaintext, ciphertext, w256, Nb, Nr);
	invCipher(ciphertext, plaintext, w256, Nb, Nr);
	*/
	return 0;
}

