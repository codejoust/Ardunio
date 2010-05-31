#!/usr/bin/env python
import sys, serial, readline

#Super-Simple Hello-World for the Arduino LCD.

def prompt_for_input():
    to_say = raw_input("> ")
    if ('.q' in to_say): # Type .q to exit
        print "Exiting"
        sys.exit()
    if len(to_say) > 16: # Only send the first part.
        to_say = to_say[16:]
    ser.write(to_say)    # Give it to the board.
    ser.write("\n")      # End the input
    if ('y' in ser.readline()): # Wait for an affirmitive response
        return True             # Before looping.
    
    
port = '/dev/ttyUSB0'  # Default Port
if (len(sys.argv) > 1):# Change it in the first argument.
    port = sys.argv[1]
ser = serial.Serial(port)

while(prompt_for_input()):
    pass
    
#@author Iain Nash - 2010
