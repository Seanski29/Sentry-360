#include <Stepper.h>
#define STEPS 2038  // 28BYJ-48 steps per revolution

const int trigPin = A0; //Trigger is at PIN A0
const int echoPin = A1; //Echo is at PIN A1

long duration; //Initializing duration as numerical
int distance; //Initializing distance as numerical
int stepCount = 0; //Initializing stepCount as zero

Stepper stepper(STEPS, 8, 9, 10, 11); // Assigning Driver Module to Pins IN1 = 8 | IN2 = 9 | IN3 = 10 | IN4 = 11

void setup() { // Setting the trigger pin as an output and echo pin as input
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600); //

  stepper.setSpeed(15);  // Maximum stable speed for 28BYJ-48
}

void loop() {
  stepper.step(10);  // bigger step chunk per loop for faster rotation

  distance = calculateDistance();

  float angle = (stepCount * 15 * 360.0) / STEPS;
  Serial.print(angle);
  Serial.print(",");
  Serial.print(distance);
  Serial.println(".");

  stepCount += 15;
  if (stepCount >= STEPS) stepCount = 0;
}

int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 30000);
  int distance = duration * 0.034 / 2;
  return distance;
}