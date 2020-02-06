#include <SPI.h>
#include <Adafruit_FRAM_SPI.h>
#include <Adafruit_MAX31865.h>
#include <Wire.h>
//#include <Adafruit_LiquidCrystal.h>

#define RREF      430.0
#define RNOMINAL  100.0

uint8_t MAX3185E_CS = 3;
uint8_t MAX3185E_MOSI = 6;
uint8_t MAX3185E_MISO = 7;
uint8_t MAX3185E_SCK = 8;

Adafruit_MAX31865 maxe = Adafruit_MAX31865(MAX3185E_CS, MAX3185E_MOSI, MAX3185E_MISO, MAX3185E_SCK);

uint8_t MAX3185S_CS = 4;
uint8_t MAX3185S_MOSI = 6;
uint8_t MAX3185S_MISO = 7;
uint8_t MAX3185S_SCK = 8;

Adafruit_MAX31865 maxs = Adafruit_MAX31865(MAX3185S_CS, MAX3185S_MOSI, MAX3185S_MISO, MAX3185S_SCK);

uint8_t FRAM_CS = 5;
uint8_t FRAM_MOSI = 6;
uint8_t FRAM_MISO = 7;
uint8_t FRAM_SCK= 8;

Adafruit_FRAM_SPI fram = Adafruit_FRAM_SPI(FRAM_SCK, FRAM_MISO, FRAM_MOSI, FRAM_CS);

//Adafruit_LiquidCrystal lcd(0);

int bytesleidos;
uint8_t entrada[4];
uint8_t llamada[4];
uint8_t alarma[4];
uint8_t salida[95];
uint16_t crc;

void setup(void) {
  //#ifndef ESP8266
  //  while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
  //#endif

  Serial.begin(9600);

  //lcd.begin(20, 4);
  
  maxe.begin(MAX31865_2WIRE);  // set to 2WIRE or 4WIRE as necessary
  
  if (fram.begin()) {
      //lcd.setCursor(16,0);
      //lcd.print("fram"); 
  }
  llamada[0] = 5; //fram.read8(0)
  llamada[1] = 6; //fram.read8(1);
  llamada[2] = 7;
  llamada[3] = 8;
  Serial.write(llamada[0]);
  Serial.write(llamada[1]);
  Serial.write(llamada[2]);
  Serial.write(llamada[3]);
  alarma[0] = 15; //fram.read8(4)
  alarma[1] = 6; //fram.read8(5);
  alarma[2] = fram.read8(6);
  alarma[3] = fram.read8(7);  
  crc = calccrc(llamada,2);
  if ( lo(crc) != llamada[2] ) {
    if ( hi(crc) != llamada[3] ) {
      //llamada[0] = 5;
      //llamada[1] = 6; //fram.read8(1);
      //llamada[2] = lo(crc);
      //llamada[3] = hi(crc);
      alarma[0]=15;
      alarma[1]=llamada[1];
      crc=calccrc(alarma,2);
      alarma[2]=lo(crc);
      alarma[3]=hi(crc);
      fram.writeEnable(true);
      fram.write8(0, llamada[0]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(1, llamada[1]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(2, llamada[2]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(3, llamada[3]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(4, alarma[0]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(5, alarma[1]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(6, alarma[2]);
      fram.writeEnable(false);
      fram.writeEnable(true);
      fram.write8(7, alarma[3]);
      fram.writeEnable(false);
      //lcd.setCursor(16,1);
      //lcd.print("save"); 
      delay(100);
    }
  }
}

void loop(void) {
  delay(250);
  llamada[0] = fram.read8(0);
  llamada[1] = fram.read8(1);
  llamada[2] = fram.read8(2);
  llamada[3] = fram.read8(3);
  char buf[3];
  //lcd.setCursor(0,0);
  //sprintf(buf,"%3d",llamada[0]);
  //lcd.print(buf);
  //lcd.setCursor(4,0);
  //sprintf(buf,"%3d",llamada[1]);
  //lcd.print(buf);
  //lcd.setCursor(8,0);
  //sprintf(buf,"%3d",llamada[2]);
  //lcd.print(buf);
  //lcd.setCursor(12,0);
  //sprintf(buf,"%3d",llamada[3]);
  //lcd.print(buf);
  bytesleidos= Serial.readBytes(entrada,4);
  if (bytesleidos >= 4 ){
    char buf[3];
    //lcd.setCursor(0,1);
    //sprintf(buf,"%3d",entrada[0]);
    //lcd.print(buf);
    //lcd.setCursor(4,1);
    //sprintf(buf,"%3d",entrada[1]);
    //lcd.print(buf);
    //lcd.setCursor(8,1);
    //sprintf(buf,"%3d",entrada[2]);
    //lcd.print(buf);
    //lcd.setCursor(12,1);
    //sprintf(buf,"%3d",entrada[3]);
    //lcd.print(buf);    
    if ( entrada[0] != 0 ) {
      if ( entrada[1] != 0 ) {
        if ( entrada[2] != 0 ) {
          if ( entrada[3] != 0 ) {
            //lcd.setCursor(16,2);  
            //lcd.print("call");
            salida[0]=0;
            salida[1]=llamada[1];
            salida[2]=0;
            salida[3]=100;
            salida[4]=0;
            salida[5]=120;
            salida[6]=1;
            salida[7]=1;
            salida[92]=1;
            salida[93]=4;
            crc=calccrc(salida,94);
            salida[94]=lo(crc);
            salida[95]=hi(crc);
            digitalWrite(2,HIGH);
            for (int i=0; i <= 95; i++) {
              Serial.write(salida[i]);
            }
            delay(5);
            digitalWrite(2,LOW);
            //lcd.setCursor(16,2);  
            //lcd.print("send");
          }
        }
      }
    }    
  }
}

uint8_t lo(int val) {
  return (val & 0xff); 
}

uint8_t hi(int val) {
  return (val >> 8); 
}

uint16_t calccrc(char *ptr, int count) {
  uint16_t  crc = 0xffff;
  for (int pos = 0; pos < count; pos++) {
    crc ^= (uint16_t)ptr[pos];
    for (int i = 8; i !=0; i--) {
      if ((crc & 0x0001) != 0) {
        crc >>= 1;
        crc ^= 0xa001;
      }else{
        crc >>= 1;
      }
    }
  }
  return (crc);
}
