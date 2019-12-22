#include <OneWire.h> 
#include <DallasTemperature.h>
#define Pin_Buz 4 //son sensors digitals 
#define Pin_PH A2 //sensor analògic
#define ECPin A0
#define ECGround A1
#define ECPower A4
#define Pin_Temp 7 // sensor temperatura

//SENSOR DE SALINITAT//////////////////////////////////////////////////
#define Pin_Temp2 11     //DATA WIRE MIDDLE
#define Ra 25
int R1= 1000;
float PPMconversion=0.64;
float K=1.76;
float TemperatureCoef = 0.019; //Compensamos la temperatura
OneWire oneWire2(Pin_Temp2);// Setup a oneWire instance to communicate with any OneWire devices
DallasTemperature sensors(&oneWire2);

OneWire oneWire(Pin_Temp);// Setup a oneWire instance to communicate with any OneWire devices
DallasTemperature tempe(&oneWire);

float Temperature=10;
float Ec=0.0;
float EC25 =0.0;
int ppm =0;
float raw= 0.0;
float Vin= 5.0;
float Vdrop= 0.0;
float Rc= 0.0;
float buffer=0.0;
////////////////////////////////////////////////////////////////////////
//Variables para los otros sensores
float temp=0.0;
float phllegit=0.0;
float pH=0.0;
float sal=0.0;
///////////////////////////////////////////////////////////////////////
//Vector que contendrá los datos de los 3 sensores:
float data[3]; //empieza en indice 0

//////////////////////////////////////////////////////////////////////
// setup routine runs once when you press reset
void setup() {
  Serial.begin(9600);
  pinMode(ECPin,INPUT);
  pinMode(ECPower,OUTPUT);//Setting pin for sourcing current
  pinMode(ECGround,OUTPUT);//setting pin for sinking current
  digitalWrite(ECGround,LOW);//We can leave the ground connected permanantly
  R1=(R1+Ra);
  
}

void loop() {
  //Temperatura
    temp = temperatura();
    buzz();
    data[0] = temp;
  
  //pH
    pH = ph();
    buzz();
    data[1]= pH;
    delay(500);
    
  //Salinidad
    sal = GetEc();
    data[2]=sal;          //Calls Code to Go into GetEC() Loop [Below Main Loop] dont call this more that 1/5 hhz [once every five seconds] or you will polarise the water
    delay(500);

    
String data0=String(int(data[0]))+ "." + String(getDecimal(data[0]));//datos temperatura
String data1=String(int(data[1]))+ "." + String(getDecimal(data[1]));//datos pH
String data2=String(int(data[2]))+ "." + String(getDecimal(data[2]));//datos salinidad
    String Datos = data0 + ';' + data1 + ';' + data2;
    Serial.println(Datos);
  
}

//FUNCIONES

float temperatura(){
  tempe.begin();//inicialitzem sensor de temperatura (les especificacions ho indiquen)
  tempe.requestTemperatures(); //demana la temperatura al sensor
  return tempe.getTempCByIndex(0); 
}

float ph(){
  phllegit = analogRead(Pin_PH); //el pin es llegeix en analògic
  float pHVol=(float)phllegit*5.0/1024/6;
  float phValue = -5.70 * pHVol + 21.34;
  return phValue; 
}

void buzz(){
  if(temp<13 or temp>32) tone(Pin_Buz,440); //tone A4 
  else if((int)pH<5 or (int)pH>8) tone(Pin_Buz,392); //tone(pin,frequency)
  else if (sal<0 or sal>3) tone(Pin_Buz,329.63); 
  else noTone(Pin_Buz);
}

float GetEc(){
   sensors.begin();//inicialitzem sensor de temperatura (les especificacions ho indiquen)
   sensors.requestTemperatures(); //demana la temperatura al sensor
   temp=sensors.getTempCByIndex(0);
   digitalWrite(ECPower,HIGH);
   raw= analogRead(ECPin);
   raw= analogRead(ECPin);// FIRST READING TOO LOW 
   digitalWrite(ECPower,LOW);
   Vdrop= (Vin*raw)/1024.0;
   Rc=(Vdrop*R1)/(Vin-Vdrop);
   Rc=Rc-Ra; //acounting for Digital Pin Restance
   Ec = 1000/(Rc*K);
   EC25  =  Ec/ (1+ TemperatureCoef*(temp-25.0));
   ppm=(EC25)*(PPMconversion*1000);
   return (EC25-12);
  }

 long getDecimal(float val)
 {
 int intPart = int(val);
 long decPart = 10 *(val-intPart); //I am multiplying by 1000 assuming that the foat values will have a maximum of 3 decimal places
                                   //Change to match the number of decimal places you need
 if(decPart>0)return(decPart);           //return the decimal part of float number if it is available 
 else if(decPart<0)return((-1)*decPart); //if negative, multiply by -1
 else if(decPart=0)return(00);           //return 0 if decimal part of float number is not available
}
