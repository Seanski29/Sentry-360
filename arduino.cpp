#include <Stepper.h>

#define STEPS 2038

const int trigPin = 6;
const int echoPin = 7;

// UPDATED SETTINGS FOR 70° TILT
const int FLOOR_DISTANCE = 80;    // Ignore floor echoes (80cm and closer)
const int MAX_DETECTION_DISTANCE = 600; // Maximum range

// STEPPER CONFIGURATION
const int DEFAULT_RPM = 5;
const int STEPS_PER_READING = 10;
Stepper stepper(STEPS, 8, 10, 9, 11);

// Variables
long duration;
int distance;
float angle = 0;
bool initializationComplete = false;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
  stepper.setSpeed(DEFAULT_RPM);
  
  // Perform initialization - set current position as 0°
  performInitialization();
}

void performInitialization() {
  // Set current physical position as 0 degrees
  angle = 0; // Whatever direction we're facing becomes 0°
  
  // Wait 2 seconds before starting
  delay(2000);
  
  initializationComplete = true;
}

void loop() {
  // Only start normal operation after initialization is complete
  if (!initializationComplete) {
    return;
  }
  
  static int stepCount = 0;
  
  stepper.step(1);
  stepCount++;
  
  if (stepCount >= STEPS_PER_READING) {
    angle += STEPS_PER_READING * (360.0 / STEPS);
    if (angle >= 360.0) angle = 0;
    
    distance = calculateDistance();
    
    // ONLY send data to Processing if object is within floor distance
    // No Serial Monitor output - cleaner communication
    if (distance > 0 && distance < FLOOR_DISTANCE) {
      Serial.print(angle, 1);
      Serial.print(",");
      Serial.println(distance);
    }
    
    stepCount = 0;
  }
}

int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH, 30000);
  if (duration == 0) return 0;
  
  int dist = duration * 0.034 / 2;
  
  return (dist > MAX_DETECTION_DISTANCE) ? 0 : dist;
}