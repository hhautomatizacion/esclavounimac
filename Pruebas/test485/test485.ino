int dato = 0;
int recv = 0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  while(true){
    
    dato = dato +1;
    digitalWrite(2,HIGH);
    Serial.write(recv);
    Serial.write(dato);
    delay(5);
    digitalWrite(2,LOW);
    recv = Serial.read();
    delay(1000);
    if (dato > 130 ){
      dato =30;
    }
  }
}
