

void setup() {
  // put your setup code here, to run once:

}
void loop (){
  Serial.begin(9600);
  
  unsigned long startTime = millis();  // millis () Returns the number of milliseconds passed since the Arduino board began running the current program.
  Serial.println("Starting measurement..."); //terminal mostra per pantalla 'Starting measurement'
  unsigned long elapsedTime=0; // creem variable elapsed time
  int outValue = 0;
  while (elapsedTime <= 120000 && Serial.read() != 'P') {
    outValue = analogRead(A0);
    Serial.println(outValue);
    delay(200);
    unsigned long CurrentTime = millis();
    elapsedTime = CurrentTime - startTime;
  }

}
