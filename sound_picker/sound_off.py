#!/usr/bin/env python

## Requires: mplayer (-nogui)
## Run when the Arduino code is running, and uploaded first.
## The Pot. for input 4 should be a 10k pot connected to the +5v input,
###  that way, the averaging code works. If not, adjust accordingly.
## Iain Nash - 2010

import subprocess, os, sys, serial, time, random

class MusicPlayer:
    def read_input(self):
        txt = self.ser.readline()[:-1]
        if (txt == "bv-h"):
            self.play_song()
        elif (txt[:3] == "sv-"):
            try: self.val = int(txt[3:])
            except: pass
            if self.val: self.update_screen(self.val)
        return True
    def play_song(self):
        if (not hasattr(self, 'selected')): return;
        self.write("  Playing:")
        self.write("\n")
        self.write(self.selected[0])
        p = subprocess.Popen(['mplayer', self.selected[1], '-really-quiet'])
        time.sleep(1)
        self.ser.flushInput()
        self.ser.timeout = 2
        while (p.returncode is None):
            txt = self.ser.readline()
            if txt[:4] == "bv-h":
                os.kill(p.pid, 2)
            p.poll()
        self.ser.timeout = 0
        self.update_screen(self.val)
    def find_song(self, index):
        return self.songlist.get_song(int(index / 4))
    def update_screen(self, index):
        self.selected = self.find_song(int(index))
        song_name = self.selected[0]
        self.write(song_name[:15]+'.')
        self.write('\n')
        self.write(str(self.selected[2])+' of '+str(self.songlist.songcount)+' songs')
    def write(self, text):
        self.ser.write(text)
    def connect(self):
        port = '/dev/ttyUSB0'
        if (len(sys.argv) > 1):
            port = sys.argv[1]
        self.ser = serial.Serial(port, 9600)
    def run(self):
        while(self.read_input()):
            pass
    def __init__(self):
        self.connect()
        self.songlist = SongList()   


class SongList:
    def __init__(self):
        self.get_basedir()
        self.load_songs()
    def get_basedir(self):
        cdir = '~/Music'
        if(os.path.isdir(cdir)):
            self.basedir = os.path.abspath(cdir)
    def load_songs(self):
        count = 0
        rawf = []
        for (path, dirs, files) in os.walk(self.basedir):
            for raw_file in files:
                if (len(rawf) > 50): break
                if raw_file[-3:] in ['wav', 'oga', 'mp3']:
                    rawf.append([raw_file, os.path.join(path, raw_file)])
        random.shuffle(rawf)
        self.sfiles = rawf[:25]
        self.songcount = len(self.sfiles)
        for index, item in enumerate(self.sfiles):
            self.sfiles[index].append(index)
    def get_song(self, num):
        return self.sfiles[num]


music_player = MusicPlayer()
music_player.run()
#Run it!
