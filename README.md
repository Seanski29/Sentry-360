360° Stepper Motor Radar Scanner

Project Goal

This project details how to build a 360-degree "scanning sonar" system. It uses a 28BYJ-48 stepper motor for precise, continuous 360-degree rotation and an ultrasonic sensor to detect objects in the surrounding environment.

An Arduino microcontroller coordinates the motor and sensor. At each small step of the motor, it takes a distance reading. It then formats this data as an "angle,distance" pair and sends it to a host computer via a USB serial connection.

A Processing 4 sketch running on the computer listens for this data, parses it, and renders a live, 360-degree radar display. This visualization includes a fading green "sweep" line and solid red sectors that show the proximity and angle of detected objects, as seen in the image above.

Hardware Required

Arduino Uno (or any compatible board)

28BYJ-48 Stepper Motor & ULN2003 Driver Board

HC-SR04 Ultrasonic Sensor

Jumper Wires (Male-Male, Male-Female)

A physical mount to attach the ultrasonic sensor to the stepper motor (e.g., 3D print, cardboard, hot glue).

Software Required

Arduino IDE (Version 1.8.x or 2.x)

Processing 4

The two project files:

stepper_radar_final.ino (for the Arduino)

stepper_radar_visualization.pde (for the Processing sketch)

Step-by-Step Running Guide

Follow these steps in order to get the project running.

Step 1: Hardware Assembly

Wire your components to the Arduino as follows.

Ultrasonic Sensor (HC-SR04):

VCC -> Arduino 5V

GND -> Arduino GND

TRIG -> Arduino A0

ECHO -> Arduino A1

Stepper Motor Driver (ULN2003):

IN1 -> Arduino Digital 8

IN2 -> Arduino Digital 9

IN3 -> Arduino Digital 10

IN4 -> Arduino Digital 11

+ (Power) -> Arduino 5V

- (Ground) -> Arduino GND

Finally, mount your HC-SR04 sensor to the shaft of the stepper motor so that it spins along with the motor.

Step 2: Upload the Arduino Code

Connect your Arduino Uno to your computer via USB.

Open the stepper_radar_final.ino file in your Arduino IDE.

Go to Tools > Board and select "Arduino Uno".

Go to Tools > Port and select the COM port that your Arduino is connected to.

Click the Upload button (the arrow icon).

Wait for the message "Done uploading."

Crucial: Close the Arduino IDE's Serial Monitor if it is open. Only one program can use the serial port at a time.

Step 3: Configure the Processing Sketch

Open the stepper_radar_visualization.pde file in Processing 4.

Click the Run button (the play icon).

The sketch will run, and you must look at the console (the black area at the bottom of the Processing window). It will print a list of all your available COM ports.

[0] COM1
[1] COM5  <-- This might be your Arduino
[2] COM7


Identify which port is your Arduino. Note the number in the brackets (e.g., [1]).

Stop the sketch (click the stop icon).

Find this line of code near the top of the sketch:

String portName = Serial.list()[0]; // <-- CHANGE THE [0] IF NEEDED


Change the [0] to the number you found in step 4. For example, if your Arduino was on COM5 and it was item [1], you would change the line to:

String portName = Serial.list()[1];


Step 4: Run the Radar!

Make sure your Arduino is plugged in (and running the code from Step 2).

Click the Run button in Processing 4.

The radar visualization window will open, connect to the Arduino, and the sweep line will begin to move and display any detected objects.

Troubleshooting

Error: "Error opening port..." in Processing:

Fix 1: You did not select the correct port number in Step 3. Double-check the port list and try again.

Fix 2: The Arduino IDE's Serial Monitor is still open. Close it and restart the Processing sketch.

Fix 3: Your Arduino is not plugged in.

The radar sweep is stuck at 0°:

Fix: Processing is not receiving data. This means the Arduino code is not running or the wrong port is selected. Re-upload the code from Step 2 and ensure the port in Step 3 is correct.
