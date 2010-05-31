const int ledPins[] = {6, 7, 8, 9, 10, 11, 12};
// 7-Segement LCD Display
// 1  _
// 2 | | 3
// 4 ---
// 5 | | 6
// 7 ---
// Pins are mapped from 1 - 7 in above array, 
//  connected to digital out.

//Callback to the computer when it gets dark? 
// (for debugging and pranks)
#define report TRUE


const int numbers[10][7] = {
  {1, 2, 3, 5, 6, 7},   //0
  {3, 6},               //1
  {1, 3, 4, 5, 6, 7},   //2
  {1, 3, 4, 6, 7},      //3
  {2, 3, 4, 6},         //4
  {1, 2, 4, 6, 7},      //5
  {1, 2, 4, 5, 6, 7},   //6
  {1, 3, 6},            //7
  {1, 2, 3, 4, 5, 6, 7},//8
  {1, 2, 3, 4, 6, 7}    //9
};

const int letters[][7] = {
  {2, 3, 4, 5, 6},     //H
  {1, 2, 3, 4, 5, 6},  //A
  {1, 2, 5, 7},        //C
  {1, 3, 4, 6, 7},     //Z
  {1, 2, 4, 5, 7},     //F
  {2, 3, 4, 6, 7}      //Y
};
const char letters_index[] = {'H', 'A', 'C', 'Z', 'F', 'Y'};

const int totalPins = 7, buttonPin = 2, led1Pin = 5, led2Pin = 3, sensorPin = 0;
//LEDS are for effect -- set to pin 5 and 3, optional. The totalPins is count of lcd pins
// Input 2 is the toggle input for the counter.

int x = 0, runState = 0, buttonState, num = 0, runCount = 0;
// For the Counter
int sensorValue, sensorMin = 1023, sensorMax = 0;
// For the Light Sensor

void setup(){
  #ifdef report
  Serial.begin(9600); // Debugging
  #ifdef report
  for (x = 0; x<sizeof(ledPins); x++){
    pinMode(ledPins[x], OUTPUT); // Setup Output Pins
  }
  int outPins[] = {13, 5, 3};
  for (x = 0; x<sizeof(outPins);x++){
    pinMode(outPins[x], OUTPUT);
  }
  pinMode(buttonPin, INPUT); // Set Button 1
  calibrate_light();
}

//To define usage, either uncomment counter or light meter.
void loop(){
  //counter();
  light_meter();
}

//Run Light Meter
void light_meter(){
  int num = 0;
  delay(150);
  sensorValue = analogRead(sensorPin);
  clearDisplay();
  if (sensorValue >= sensorMax){
    num = 9;
  } else if (sensorValue <= sensorMin){
    num = 0; }
  else {
    num = constrain(map(sensorValue, sensorMin, sensorMax, 0, 90), 0, 90) / 10;
  }
  setNumbers(num, HIGH);
  #ifdef report
  if (num < 4){
    Serial.print("!!!\n");
  }
  #endif
}

//Run Counter
void counter(){
  if (digitalRead(buttonPin) == HIGH){
    digitalWrite(13, HIGH);
    clearDisplay();
    setNumbers(num, HIGH);
    runState ? num-- : num++;
    if (num == 0)  runState = 0;
    if (num == 9)  runState = 1;
    int fadeValue = (num * 20) + 75;
    int fade2 = abs(fadeValue-255);
    for(;fadeValue <= 255;fadeValue+=20,fade2-=20){
      if (num <= 5){  
        analogWrite(led1Pin, fadeValue);
        analogWrite(led2Pin, fade2);
      } else {
        analogWrite(led1Pin, fade2);
        analogWrite(led2Pin, fadeValue);
      }
      delay(20); 
    }
    delay(500);
  } else { digitalWrite(13, LOW); }
}

void clearDisplay(void){
  for (x = 0; x<sizeof(ledPins); x++){
    digitalWrite(ledPins[x], LOW);
  }
}

void setNumbers(int number, int state){
  int pin;
  for (x = 0; x < totalPins; x++){
    pin = numbers[number][x];
    if(pin > 0){
      digitalWrite(ledPins[pin - 1], state);
    }
  }
}

//Calibrate Light Meter
void calibrate_light(){
 showLetter('C');
 while(millis() < 5000){
    sensorValue = analogRead(sensorPin);
      if (sensorValue > sensorMax){
        sensorMax = sensorValue;
      }
      if (sensorValue < sensorMin){
        sensorMin = sensorValue;
      }
      if (((int) (millis() / 100)) == 30){
        clearDisplay();
      }
  }
}

//To find a letter
int findLetter(char letter){
  for (x = 0; x < sizeof(letters_index); x++){
    if (letters_index[x] == letter){
      return x;
    }
  }
  return -1;
}

//To show a letter
void showLetter(char letter){
  int letter_index, pin;
  if (!(letter_index = findLetter(letter))){ return; }
  for (x = 0; x < totalPins; x++){
    pin = letters[letter_index][x];
    if (pin > 0 && pin < sizeof(ledPins)){
      digitalWrite(ledPins[pin - 1], HIGH);
    }
  }
}

