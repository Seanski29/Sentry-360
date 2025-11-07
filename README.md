# 🛰️ 360° Stepper Motor Radar Scanner

### 📖 Project Overview

I helped develop the code for **GROUP 1 of PHISLCA FAB BSAET 3-2 SY 25-26** This project demonstrates the construction of a **360-degree scanning sonar system** using a **28BYJ-48 stepper motor** for precise rotation and an **HC-SR04 ultrasonic sensor** for distance detection.

An **Arduino Uno** coordinates both components—rotating the motor incrementally and measuring distance at each step. The Arduino transmits these readings as *angle,distance* pairs via a serial connection to a host computer.

A **Processing 4** visualization script receives this data and renders a live **radar-style interface**, complete with a fading green sweep and red echo indicators that represent detected objects.

---

## ⚙️ Hardware Requirements

* Arduino Uno (or compatible board)
* 28BYJ-48 Stepper Motor with ULN2003 Driver Board
* HC-SR04 Ultrasonic Sensor
* Jumper wires (male-male, male-female)
* Mount or holder to attach the ultrasonic sensor to the motor (3D print, cardboard, or glue)

---

## 💻 Software Requirements

* **Arduino IDE** (v1.8.x or v2.x)
* **Processing 4**
* Project files:

  * `stepper_radar_final.ino` – Arduino code
  * `stepper_radar_visualization.pde` – Processing sketch

---

## 🧩 Step-by-Step Setup Guide

### 🪛 Step 1: Hardware Assembly

Connect all components to the Arduino as follows:

**Ultrasonic Sensor (HC-SR04)**

| HC-SR04 Pin | Arduino Pin |
| ----------- | ----------- |
| VCC         | 5V          |
| GND         | GND         |
| TRIG        | A0          |
| ECHO        | A1          |

**Stepper Motor Driver (ULN2003)**

| ULN2003 Pin | Arduino Pin |
| ----------- | ----------- |
| IN1         | 8           |
| IN2         | 9           |
| IN3         | 10          |
| IN4         | 11          |
| Power       | 5V          |
| Ground      | GND         |

> 💡 Mount the HC-SR04 securely on the stepper shaft so it rotates with the motor.

---

### 🧠 Step 2: Upload the Arduino Code

1. Connect your Arduino Uno via USB.
2. Open `stepper_radar_final.ino` in the **Arduino IDE**.
3. Select **Tools → Board → Arduino Uno**.
4. Select the correct **Tools → Port** for your device.
5. Click the **Upload** button (arrow icon).
6. Wait for the “**Done uploading**” message.
7. Close the **Serial Monitor** — only one program can access the serial port.

---

### 💽 Step 3: Configure the Processing Sketch

1. Open `stepper_radar_visualization.pde` in **Processing 4**.
2. Click **Run** ▶️.
3. Check the Processing console — it will list all available COM ports (e.g., `[0] COM1`, `[1] COM5`, `[2] COM7`).
4. Identify which COM port your Arduino uses and note its index number.
5. Stop the sketch ⏹️.
6. Find and edit this line in the code:

   ```java
   String portName = Serial.list()[0]; // Change index if needed
   ```

   Example: If your Arduino is on COM5 and appears as `[1]`, modify it to:

   ```java
   String portName = Serial.list()[1];
   ```

---

### 🧭 Step 4: Run the Radar

1. Ensure the Arduino is connected and powered.
2. Run the Processing sketch again.
3. A radar window will appear showing a **rotating sweep** with live distance readings visualized in real time.

---

## 🧰 Troubleshooting

### ❌ Error: “Error opening port...” in Processing

**Possible Causes & Fixes:**

* The wrong COM port was selected — verify and update the index.
* The Arduino Serial Monitor is still open — close it and restart Processing.
* The Arduino board is not connected — check the USB cable or power.

### 🌀 Radar sweep stuck at 0°

**Fix:** The Processing sketch isn’t receiving serial data. Re-upload the Arduino code and ensure the correct port is specified.

---

## 🧪 Summary

This project combines **Arduino-based sensor control** and **Processing-based visualization** to simulate a real-time radar scanning system. It demonstrates data acquisition, serial communication, and graphical representation of sensor input — an ideal foundation for robotics, automation, or surveillance applications.

---
