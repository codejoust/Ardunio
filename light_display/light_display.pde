#include <LiquidCrystal.h>

#define lcdsize 16

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

const int sensorPin = 0, outputs[] = {
  2, 3, 4}; //For effect -- Use a tricolored led in these slots for status lights.
int sensorValue, sensorMin = 1023, sensorMax = 0, runs = 0, state = 0;

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.print("...");
  lcd.cursor();
  for (int num = 0; num < sizeof(outputs); num++){
    pinMode(outputs[num], OUTPUT);
  }
  digitalWrite(2, HIGH);
  calibrate_light();
}

void turnOff(){
  for (int num = 0; num < sizeof(outputs); num++){
    digitalWrite(outputs[num], LOW);
  }
}

void loop(){
  update_light_sensor();
  show_running();
}

void show_running(){
  lcd.setCursor(0, 1);
  lcd.print("Running: ");
  lcd.print(millis() / 1000);
  lcd.print("s");
}

void update_light_sensor(){
  int num = 0;
  delay(150);
  sensorValue = analogRead(sensorPin);
  lcd.setCursor(0, 0);
  num = constrain(map(sensorValue, sensorMin, sensorMax, 0, 100), 0, 100);
  lcd.print("Light: ");
  lcd.print(num);
  lcd.print("%  ");
  if (num < 10){
    lcd.setCursor(0, 15);
    lcd.print("!");
  }
  if (num < 50){
    turnOff();
    digitalWrite(4, HIGH);
  } 
  else {
    turnOff();
    digitalWrite(3, HIGH);
  }
  if (num < 30 && state == 0){
    Serial.print("!!!\n");
    state = 1;
  } 
  else {
    state = 0;
  }
}

void calibrate_light(){
  lcd.clear();
  lcd.print("Calibrating...");
  while(millis() < 5000){
    sensorValue = analogRead(sensorPin);
    if (sensorValue > sensorMax){
      sensorMax = sensorValue;
    }
    if (sensorValue < sensorMin){
      sensorMin = sensorValue;
    }
    if (((int) (millis() / 100)) == 45){
      lcd.setCursor(0, 1);
      lcd.print("......");
    }
  }
  lcd.clear();
}

