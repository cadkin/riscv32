import serial
import binascii

port = serial.Serial("/dev/ttyUSB1", baudrate=115200)

#rcv=port.read(32)
#print(rcv)
#print(rcv.decode())

print("type characters:")
while(1):
	char=input()
	char=bytes(char,'utf-8')
	port.write(char)
	rcv=port.read()
	print(rcv.decode())

port.close()


