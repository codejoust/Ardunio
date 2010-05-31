#include <LiquidCrystal.h>
#include <string.h>

#define lcdsize 16

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

char text[16], accept[3];

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.print("...");
  lcd.cursor();
}

int inbyte, line = 0, charindx = 0;
char inbuf[lcdsize], lbuf[lcdsize];

void loop()
{
  char *pinbuf = inbuf, *plbuf = lbuf;
  strncpy(lbuf, inbuf, lcdsize);
  if (Serial.available()) {
    delay(100);
    while(Serial.available() > 0){
      inbyte = Serial.read();
      if ((char)inbyte == '\n'){
        Serial.println('y');
      } else {
        *pinbuf++ = inbyte;
      }
    }
    *pinbuf = '\0';
    updateDisplay();
  }
}

void showText(int line, int wait, char *text){
  lcd.setCursor(0, line);
  int i = lcdsize;
  while(*text){
    lcd.write(*text++);
    i--;
    if (wait > 0) delay(wait);
  } while (i-- > 0){
    lcd.write(' ');
  }
}

void updateDisplay(){
  showText(0, 10, inbuf);
  showText(1, 0, lbuf);
}
