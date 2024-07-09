#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <MAX30100_PulseOximeter.h>

Adafruit_MPU6050 mpu;
PulseOximeter pox;

void setup() {
  Serial.begin(19200);
  while (!Serial) delay(10); // Wait for serial port to open

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  Serial.println("MPU6050 Found!");

  // Initialize MAX30100
  if (!pox.begin()) {
    Serial.println("Failed to initialize pulse oximeter");
    while (1) {
      delay(10);
    }
  }

  Serial.println("MAX30100 Found!");
}

void loop() {
  // Update MAX30100
  pox.update();

  // Read data from MPU6050
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // Send MPU6050 data every 100 ms
  String dataString = String(g.gyro.x, 2) + "," + String(g.gyro.y, 2) + "," + String(g.gyro.z, 2);
  Serial.println(dataString);

  // Send MAX30100 data every second
  static uint32_t lastReportTime = 0;
  if (millis() - lastReportTime > 1000) {
    float heartRate = pox.getHeartRate();
    float spo2 = pox.getSpO2();
    String heartRateSpO2 = String(heartRate, 2) + "," + String(spo2, 2);
    Serial.println("HRSpO2:" + heartRateSpO2);
    lastReportTime = millis();
  }

  delay(100); // Adjust the delay as needed
}
