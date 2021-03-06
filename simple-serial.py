import serial
ser = serial.Serial('/dev/ttyUSB9', baudrate=115200)
for i in range(10):
	ser.write(chr(i))
	d = ser.read()
	print ord(d) 
