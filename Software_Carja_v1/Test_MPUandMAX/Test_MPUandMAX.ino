#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <MAX30100_PulseOximeter.h>




Adafruit_MPU6050 mpu;
PulseOximeter pox;

uint32_t tsLastReport = 0;

void onBeatDetected() {
    Serial.println("Beat!");
}

void setup() {
    Serial.begin(19200);
    while (!Serial);

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
    Serial.print("Initializing pulse oximeter..");
    if (!pox.begin()) {
        Serial.println("FAILED");
        while (1) {
            delay(10);
        }
    } else {
        Serial.println("SUCCESS");
    }
    pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);
    pox.setOnBeatDetectedCallback(onBeatDetected);
}

void loop() {
    // Read data from MPU6050
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Send MPU6050 gyro data to Serial Monitor
    Serial.print("MPU6050:");
    Serial.print("Accel: ");
    Serial.print(a.acceleration.x);
    Serial.print(",");
    Serial.print(a.acceleration.y);
    Serial.print(",");
    Serial.print(a.acceleration.z);
    Serial.print(" | Gyro: ");
    Serial.print(g.gyro.x);
    Serial.print(",");
    Serial.print(g.gyro.y);
    Serial.print(",");
    Serial.println(g.gyro.z);

    // Read data from MAX30100
    pox.update();

    // Send MAX30100 HR and SpO2 data to Serial Plotter
    if (millis() - tsLastReport > 1000) {
        Serial.print("HRSpO2:");
        Serial.print(pox.getHeartRate());
        Serial.print(",");
        Serial.println(pox.getSpO2());

        tsLastReport = millis();
    }

    delay(10); // Adjust delay as needed
}
