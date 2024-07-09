import processing.serial.*;

Serial myPort;
String receivedData = "";

void setup() {
  size(800, 600);
  background(255);

  // Set the port name to COM3
  String portName = "COM5";
  myPort = new Serial(this, portName, 19200);

  textSize(16);
  fill(0);
}

void draw() {
  background(255); // Clear the background each frame

  if (myPort.available() > 0) {
    receivedData = myPort.readStringUntil('\n');
    if (receivedData != null) {
      println("Received: " + receivedData); // Print received data to console
      parseData(receivedData.trim()); // Trim any extra whitespace/newlines
    }
  }
}

void parseData(String data) {
  try {
    if (data.startsWith("MPU6050:")) {
      String[] splitData = data.substring(8).split(" \\| ");
      if (splitData.length != 2) {
        println("Unexpected data format: " + data);
        return;
      }
      String accel = splitData[0].substring(7); // Remove "Accel: "
      String[] accelValues = accel.split(",");
      String gyro = splitData[1].substring(6); // Remove "Gyro: "
      String[] gyroValues = gyro.split(",");

      if (accelValues.length == 3 && gyroValues.length == 3) {
        text("MPU6050 Accelerometer:", 10, 20);
        text("X: " + accelValues[0] + " Y: " + accelValues[1] + " Z: " + accelValues[2], 10, 40);

        text("MPU6050 Gyroscope:", 10, 60);
        text("X: " + gyroValues[0] + " Y: " + gyroValues[1] + " Z: " + gyroValues[2], 10, 80);
      } else {
        println("Unexpected MPU6050 data format: " + data);
      }
    } else if (data.startsWith("HRSpO2:")) {
      String[] splitData = data.substring(7).split(",");
      if (splitData.length == 2) {
        text("Heart Rate: " + splitData[0] + " bpm", 10, 120);
        text("SpO2: " + splitData[1] + " %", 10, 140);
      } else {
        println("Unexpected HRSpO2 data format: " + data);
      }
    } else {
      println("Unknown data format: " + data);
    }
  } catch (Exception e) {
    println("Error parsing data: " + e.getMessage());
  }
}
