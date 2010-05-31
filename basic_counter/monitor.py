import os, serial, subprocess
running = True
ser = serial.Serial('/dev/ttyUSB2')
while(running):
    data = ser.readline()
    print "Data: "+data
    if (data[2] == '!'):
        p = subprocess.call(['mplayer', 'song', '-ss', '200'])
        ser.flushInput()
