#include <LiquidCrystal.h>

#define lcdsize 16

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(7, 8, 9, 10, 11, 12);
const int sensorPin = 0, outputs[] = {4,5,6};
int sensorValue, intxt, state = 0, num = 0;

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.print("...");
  lcd.cursor();
  for (int num = 0; num < sizeof(outputs); num++){
    pinMode(outputs[num], OUTPUT);
  }
  pinMode(2, INPUT);
  digitalWrite(2, HIGH);
  
}

void turnOff(){
  for (int num = 0; num < sizeof(outputs); num++){
    digitalWrite(outputs[num], LOW);
  }
}

void loop(){
  update_pot_sensor();
  update_screen();
  broadcast_button();
}

void broadcast_button(){
  if (digitalRead(2) == HIGH){
    digitalWrite(6, HIGH);
    Serial.write("bv-h\n");
    delay(120);
    if (Serial.available() > 0){
      if ((char)Serial.read() == 'y'){
        for (int x = 0; x < 1025; x+=50){
          digitalWrite(6, LOW);
          analogWrite(5, x);
          delay(1000);
        }
      }
      Serial.read(); //Clear Newline
    }
  }
}

void update_screen(){
  if (Serial.available() > 0){
    lcd.clear();
    lcd.setCursor(0, 0);
    while (Serial.available() > 0){
      intxt = Serial.read();
      if (intxt == 12 || intxt == 13 || intxt == 10){
        lcd.setCursor(0, 1);
      } else {
      lcd.write(intxt);
      }
    }
  }
}

void update_pot_sensor(){
  delay(150);
  sensorValue = (constrain(analogRead(4), 0, 1000) / 10);
  //lcd.setCursor(0, 0);
  if (num != sensorValue){
    Serial.print("sv-");
    Serial.println(num);
  }
  num = sensorValue;
  //lcd.print("Sensor: ");
  //lcd.print(num);
  //lcd.print("% ");  
}

