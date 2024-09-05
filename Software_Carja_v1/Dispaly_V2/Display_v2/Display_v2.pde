import processing.serial.*;

Serial myPort;
String receivedData = "";

// Off-screen buffer for double buffering
PGraphics buffer;

// Data storage for plotting
float[] heartRateData;
float[] spo2Data;
int dataSize = 300; // Number of data points to display
int dataIndex = 0;
boolean bufferFull = false;

void setup() {
  size(800, 600);
  background(255);

  // Set the port name to COM5
  String portName = "COM5";
  myPort = new Serial(this, portName, 19200);

  textSize(16);
  fill(0);

  // Initialize the off-screen buffer
  buffer = createGraphics(width, height);

  // Initialize data storage arrays
  heartRateData = new float[dataSize];
  spo2Data = new float[dataSize];
}

void draw() {
  if (myPort.available() > 0) {
    receivedData = myPort.readStringUntil('\n');
    if (receivedData != null) {
      println("Received: " + receivedData); // Print received data to console
      parseData(receivedData.trim()); // Trim any extra whitespace/newlines
    }
  }

  // Display the buffer
  image(buffer, 0, 0);

  // Draw the plots
  drawPlots();

  // Draw the GPS coordinates
  drawGPSCoordinates();
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
        drawSensorData("MPU6050 Accelerometer", accelValues, 20, color(200, 200, 255));
        drawSensorData("MPU6050 Gyroscope", gyroValues, 120, color(200, 255, 200));
      } else {
        println("Unexpected MPU6050 data format: " + data);
      }
    } else if (data.startsWith("HRSpO2:")) {
      String[] splitData = data.substring(7).split(",");
      if (splitData.length == 2) {
        float heartRate = float(splitData[0]);
        float spo2 = float(splitData[1]);

        // Store the data
        if (dataIndex >= dataSize) {
          dataIndex = 0;
          bufferFull = true;
        }
        heartRateData[dataIndex] = heartRate;
        spo2Data[dataIndex] = spo2;
        dataIndex++;

        drawHRSpO2Data(new String[]{splitData[0], splitData[1]}, 220, color(255, 200, 200));
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

void drawSensorData(String title, String[] values, float yOffset, int bgColor) {
  buffer.beginDraw();
  buffer.fill(bgColor);
  buffer.noStroke();
  buffer.rect(10, yOffset - 20, width - 20, 80, 10);

  buffer.fill(0);
  buffer.text(title, 20, yOffset);

  buffer.text("X: " + values[0], 20, yOffset + 20);
  buffer.text("Y: " + values[1], 20, yOffset + 40);
  buffer.text("Z: " + values[2], 20, yOffset + 60);
  buffer.endDraw();
}

void drawHRSpO2Data(String[] values, float yOffset, int bgColor) {
  buffer.beginDraw();
  buffer.fill(bgColor);
  buffer.noStroke();
  buffer.rect(10, yOffset - 20, width - 20, 60, 10);

  buffer.fill(0);
  buffer.text("Heart Rate: " + values[0] + " bpm", 20, yOffset);
  buffer.text("SpO2: " + values[1] + " %", 20, yOffset + 20);
  buffer.endDraw();
}

void drawPlots() {
  int plotHeight = 100;
  int hrYOffset = 320;
  int spo2YOffset = 440;

  // Draw Heart Rate plot
  stroke(0);
  noFill();
  rect(10, hrYOffset - 10, width - 20, plotHeight + 20);
  beginShape();
  for (int i = 0; i < (bufferFull ? dataSize : dataIndex); i++) {
    float x = map(i, 0, dataSize - 1, 20, width - 20);
    float y = map(heartRateData[i], 40, 180, hrYOffset + plotHeight, hrYOffset);
    vertex(x, y);
  }
  endShape();

  // Draw SpO2 plot
  stroke(0);
  noFill();
  rect(10, spo2YOffset - 10, width - 20, plotHeight + 20);
  beginShape();
  for (int i = 0; i < (bufferFull ? dataSize : dataIndex); i++) {
    float x = map(i, 0, dataSize - 1, 20, width - 20);
    float y = map(spo2Data[i], 70, 100, spo2YOffset + plotHeight, spo2YOffset);
    vertex(x, y);
  }
  endShape();
}

// Function to draw GPS coordinates at the top of the window
void drawGPSCoordinates() {
  String gpsText = "GPS coordinates: 46.76840840468147, 23.63717461831791";
  
  buffer.beginDraw();
  buffer.fill(255); // White background
  buffer.noStroke();
  buffer.rect(10, 10, width - 20, 40, 10); // Rectangle for the text box
  
  buffer.fill(0); // Black text
  buffer.textSize(16);
  buffer.textFont(createFont("Arial", 16, true)); // Use Arial font with bold style
  buffer.text(gpsText, 20, 35); // Display the text within the rectangle
  buffer.endDraw();
}
