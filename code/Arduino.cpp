#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <DHT.h>
#include <Servo.h>

<<<<<<< HEAD
// --- Pines RFID y LED ---
#define SS_PIN 53
#define RST_PIN 5
#define LED_PIN 7
=======
// --- Pines RFID, LED y BUZZER ---
#define SS_PIN 53
#define RST_PIN 5
#define LED_PIN 7
#define BUZZER_PIN 8
<<<<<<< HEAD
>>>>>>> 202200214
=======
#define MOTOR_PIN 9
#define SERVO_PIN 6
Servo miServo;
>>>>>>> 202200214

// --- Sensores de camilla ---
const int sensor1 = A4;
const int sensor2 = A1;
const int sensor3 = A2;
<<<<<<< HEAD
<<<<<<< HEAD
=======
const int botonCamillaPin = 18;
>>>>>>> 202200214
=======

>>>>>>> 202200214
const int umbral = 100;

// --- DHT11 ---
#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);
float temperatura = 0.0;
float humedad = 0.0;

// --- RFID ---
MFRC522 rfid(SS_PIN, RST_PIN);
MFRC522::MIFARE_Key key;
<<<<<<< HEAD
bool esEntrada = true;
bool tarjetaPresente = false;

=======
bool tarjetaPresente = false;

// Estados individuales por UID (manual)
const int MAX_UIDS = 10;
String uidList[MAX_UIDS];
bool uidStates[MAX_UIDS];
int uidCount = 0;

>>>>>>> 202200214
void setup() {
  Serial.begin(115200);
  SPI.begin();
  rfid.PCD_Init();
  dht.begin();
  pinMode(LED_PIN, OUTPUT);
<<<<<<< HEAD
=======
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
<<<<<<< HEAD
>>>>>>> 202200214
=======
  pinMode(MOTOR_PIN, OUTPUT);
  miServo.attach(SERVO_PIN);
  miServo.write(0);  // Posición inicial
>>>>>>> 202200214

  for (byte i = 0; i < 6; i++) {
    key.keyByte[i] = 0xFF;
  }
}

void loop() {
  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
    tarjetaPresente = true;
    leerTarjeta();
  }

  temperatura = dht.readTemperature();
  humedad = dht.readHumidity();
  enviarDatosJSON();
  gestionarCamillas();
  delay(1000);

<<<<<<< HEAD
<<<<<<< HEAD
void leerTarjeta() {
  String estado = esEntrada ? "entrada" : "salida";
  esEntrada = !esEntrada;
=======
int buscarUID(String uid) {
  for (int i = 0; i < uidCount; i++) {
    if (uidList[i] == uid) return i;
=======
  temperatura = dht.readTemperature();
  humedad = dht.readHumidity();

  if (temperatura >= 25.0) {
    digitalWrite(MOTOR_PIN, HIGH);
  } else {
    digitalWrite(MOTOR_PIN, LOW);
  }

  enviarDatosJSON();
  gestionarCamillas();
  delay(1000);

  // Control del servo desde Serial
  if (Serial.available()) {
    char comando = Serial.read();
    if (comando == '1') {
      miServo.write(90);
      Serial.println("Servo en 90°");
    } else if (comando == '0') {
      miServo.write(0);
      Serial.println("Servo en 0°");
    }
>>>>>>> 202200214
  }
}

void leerTarjeta() {
  String uidStr = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uidStr += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
    uidStr += String(rfid.uid.uidByte[i], HEX);
  }

  String bloque1 = leerBloque(1);

  if (bloque1 != "MSN1" && bloque1 != "LLR2") {
    Serial.println("Tarjeta no autorizada");
    digitalWrite(BUZZER_PIN, HIGH);
    delay(500);
    digitalWrite(BUZZER_PIN, LOW);
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
    tarjetaPresente = false;
    return;
  }

  int index = buscarUID(uidStr);
  if (index == -1 && uidCount < MAX_UIDS) {
    index = uidCount++;
    uidList[index] = uidStr;
    uidStates[index] = false;
  }

  bool estadoActual = uidStates[index];
  String estado = estadoActual ? "salida" : "entrada";
  uidStates[index] = !estadoActual;
>>>>>>> 202200214

  byte buffer[16];
  memset(buffer, 0, 16);
  estado.getBytes(buffer, 16);

  MFRC522::StatusCode status = rfid.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, 6, &key, &(rfid.uid));

  if (status == MFRC522::STATUS_OK) {
    status = rfid.MIFARE_Write(6, buffer, 16);
    if (status == MFRC522::STATUS_OK) {
      Serial.println("Registro RFID actualizado con estado: " + estado);
    } else {
      Serial.println("Error al escribir en RFID: " + String(rfid.GetStatusCodeName(status)));
    }
  } else {
    Serial.println("Error de autenticación RFID: " + String(rfid.GetStatusCodeName(status)));
  }
}

String leerBloque(byte bloque) {
  byte buffer[18];
  byte tamanio = 18;
  MFRC522::StatusCode status;

  status = rfid.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, bloque, &key, &(rfid.uid));
  if (status != MFRC522::STATUS_OK) {
    Serial.print("Error de autenticación en bloque ");
    Serial.print(bloque);
    Serial.print(": ");
    Serial.println(rfid.GetStatusCodeName(status));
    return "";
  }

  status = rfid.MIFARE_Read(bloque, buffer, &tamanio);
  if (status != MFRC522::STATUS_OK) {
    Serial.print("Error al leer bloque ");
    Serial.print(bloque);
    Serial.print(": ");
    Serial.println(rfid.GetStatusCodeName(status));
    return "";
  }

  String contenido = "";
  for (byte i = 0; i < 16; i++) {
    if (buffer[i] >= 32 && buffer[i] <= 126) {
      contenido += (char)buffer[i];
    }
  }
  return contenido;
}

void gestionarCamillas() {
  int valor1 = analogRead(sensor1);
  int valor2 = analogRead(sensor2);
  int valor3 = analogRead(sensor3);

  bool ocupado1 = valor1 < umbral;
  bool ocupado2 = valor2 < umbral;
  bool oscuridad = valor3 < umbral;

  digitalWrite(LED_PIN, oscuridad ? HIGH : LOW);
}

void enviarDatosJSON() {
  int valor1 = analogRead(sensor1);
  int valor2 = analogRead(sensor2);
  int valor3 = analogRead(sensor3);

  bool ocupado1 = valor1 < umbral;
  bool ocupado2 = valor2 < umbral;
  bool luz = valor3 > umbral;

  String json = "{";
<<<<<<< HEAD
<<<<<<< HEAD
  json += "\"Cubiculo1\": \"" + String(ocupado1 ? "ocupado" : "libre") + "\",";
=======
  json += "\"Cubiculi1\": \"" + String(ocupado1 ? "ocupado" : "libre") + "\",";
>>>>>>> 202200214
=======
  json += "\"Cubiculo1\": \"" + String(ocupado1 ? "ocupado" : "libre") + "\",";
>>>>>>> 202200214
  json += "\"Cubiculo2\": \"" + String(ocupado2 ? "ocupado" : "libre") + "\",";
  json += "\"luz\": \"" + String(luz ? "encendido" : "apagado") + "\",";
  json += "\"temperatura\": " + String(temperatura, 1);
  json += ",\"humedad\": " + String(humedad, 1);

  if (tarjetaPresente) {
    String uidStr = "";
    for (byte i = 0; i < rfid.uid.size; i++) {
      uidStr += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
      uidStr += String(rfid.uid.uidByte[i], HEX);
    }

    String bloque1 = leerBloque(1);
    String bloque2 = leerBloque(2);
    String bloque4 = leerBloque(4);
    String bloque5 = leerBloque(5);
    String bloque6 = leerBloque(6);

    json += ",\"uid\": \"" + uidStr + "\"";
    json += ",\"ID\": \"" + bloque1 + "\"";
    json += ",\"Nombre\": \"" + bloque2 + "\"";
    json += ",\"Apellido\": \"" + bloque4 + "\"";
    json += ",\"Ocupacion\": \"" + bloque5 + "\"";
    json += ",\"Estado\": \"" + bloque6 + "\"";

    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
    tarjetaPresente = false;
  }

  json += "}";
  Serial.println(json);
}

int buscarUID(String uid) {
  for (int i = 0; i < uidCount; i++) {
    if (uidList[i] == uid) return i;
  }
  return -1;
}