import processing.serial.*;

Serial myPort;
float currentAngle = 0;
float currentDistance = 0;
int radarRadius;

// Floor distance for display
int FLOOR_DISTANCE = 80;

// Sweep system - MATCHES 5 RPM STEPPER
float sweepAngle = 0;
float sweepSpeed = 0.5; // degrees per frame (matches 5 RPM at 60 FPS)
boolean initializationComplete = false;
int initializationStartTime = 0;

// Object management
class RadarObject {
  float angle;
  float distance;
  int detectionTime;
  float alpha;
  boolean revealed;
  
  RadarObject(float a, float d) {
    angle = a;
    distance = d;
    detectionTime = millis();
    alpha = 0;
    revealed = false;
  }
}

ArrayList<RadarObject> objects = new ArrayList<RadarObject>();

void setup() {
  size(800, 600);
  
  // Safe serial connection
  try {
    String[] ports = Serial.list();
    if (ports.length > 0) {
      myPort = new Serial(this, ports[0], 9600);
      myPort.bufferUntil('\n');
      println("Connected to: " + ports[0]);
    }
  } catch (Exception e) {
    println("No Arduino found");
  }
  
  radarRadius = min(width, height) / 2 - 50;
  initializationStartTime = millis();
  
  println("System starting...");
}

void draw() {
  background(0);
  drawRadar();
  
  if (initializationComplete) {
    // Normal operation
    updateSweep();
    drawSweepTrail();
    drawSweepLine();
    updateObjects();
    drawObjects();
  } else {
    // Auto-start after 3 seconds (Arduino is already running)
    if (millis() - initializationStartTime > 3000) {
      initializationComplete = true;
      println("Radar sweep started");
    }
    drawInitializationMessage();
  }
  
  drawText();
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height/2);
  noFill();
  stroke(98, 245, 31, 100);
  strokeWeight(1);
  
  // Radar circles
  for (int i = 1; i <= 5; i++) {
    ellipse(0, 0, radarRadius * i * 2/5, radarRadius * i * 2/5);
  }
  
  // Floor boundary (red)
  stroke(255, 0, 0, 80);
  float floorRadius = radarRadius * FLOOR_DISTANCE / 100;
  ellipse(0, 0, floorRadius * 2, floorRadius * 2);
  
  // Angle lines
  stroke(98, 245, 31, 80);
  for (int a = 0; a < 360; a += 30) {
    float x = radarRadius * cos(radians(a));
    float y = radarRadius * sin(radians(a));
    line(0, 0, x, y);
  }
  
  popMatrix();
}

void drawInitializationMessage() {
  pushMatrix();
  translate(width/2, height/2);
  
  fill(255, 255, 0);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("INITIALIZING...", 0, -20);
  
  textSize(16);
  int elapsed = (millis() - initializationStartTime) / 1000;
  int countdown = max(0, 3 - elapsed);
  text("Starting in: " + countdown + "s", 0, 10);
  
  popMatrix();
}

void updateSweep() {
  sweepAngle += sweepSpeed;
  if (sweepAngle >= 360) sweepAngle = 0;
}

void drawSweepTrail() {
  pushMatrix();
  translate(width/2, height/2);
  
  for (int i = 0; i < 45; i++) {
    float trailAngle = sweepAngle - i;
    if (trailAngle < 0) trailAngle += 360;
    
    float alpha = map(i, 0, 45, 255, 0);
    stroke(0, 200, 0, alpha);
    strokeWeight(1);
    line(0, 0, radarRadius * cos(radians(trailAngle)), radarRadius * sin(radians(trailAngle)));
  }
  
  popMatrix();
}

void drawSweepLine() {
  pushMatrix();
  translate(width/2, height/2);
  stroke(0, 255, 0);
  strokeWeight(2);
  line(0, 0, radarRadius * cos(radians(sweepAngle)), radarRadius * sin(radians(sweepAngle)));
  popMatrix();
}

void updateObjects() {
  // Use temporary list for removal to avoid concurrent modification
  ArrayList<RadarObject> objectsToRemove = new ArrayList<RadarObject>();
  
  for (RadarObject obj : objects) {
    // Calculate angle difference
    float angleDiff = abs(sweepAngle - obj.angle);
    if (angleDiff > 180) angleDiff = 360 - angleDiff;
    
    // Reveal object when sweep passes over it
    if (angleDiff < 5 && !obj.revealed) {
      obj.revealed = true;
      obj.detectionTime = millis();
      obj.alpha = 255;
    }
    
    // Handle object fading
    if (obj.revealed) {
      int elapsed = millis() - obj.detectionTime;
      
      if (elapsed > 3000) {
        objectsToRemove.add(obj); // Mark for removal
      } else if (elapsed > 1000) {
        obj.alpha = map(elapsed, 1000, 3000, 255, 0);
      }
    }
  }
  
  // Remove marked objects AFTER iteration
  objects.removeAll(objectsToRemove);
}

void drawObjects() {
  pushMatrix();
  translate(width/2, height/2);
  
  // Safe iteration - no modification during draw
  for (RadarObject obj : objects) {
    if (obj.revealed && obj.alpha > 0) {
      float radius = map(obj.distance, 0, FLOOR_DISTANCE, 0, radarRadius);
      float x = radius * cos(radians(obj.angle));
      float y = radius * sin(radians(obj.angle));
      
      fill(255, 0, 0, obj.alpha);
      noStroke();
      ellipse(x, y, 12, 12);
    }
  }
  
  popMatrix();
}

void drawText() {
  fill(98, 245, 31);
  textSize(16);
  textAlign(LEFT);
  
  text("SENTRY 360", 20, 30);
  text("Sweep Angle: " + nf(sweepAngle, 1, 1) + "°", 20, 50);
  
  if (initializationComplete) {
    text("Stepper Angle: " + nf(currentAngle, 1, 1) + "°", 20, 70);
    text("Distance: " + (currentDistance > 0 ? nf(currentDistance, 1, 0) + "cm" : "---"), 20, 90);
    
    fill(0, 255, 0);
    text("STATUS: NORMAL", 20, 120);
    
    // Count visible objects - SAFE iteration
    fill(98, 245, 31);
    int visibleObjects = 0;
    for (RadarObject obj : objects) {
      if (obj.revealed && obj.alpha > 0) {
        visibleObjects++;
      }
    }
    text("Objects: " + visibleObjects, 20, 140);
  } else {
    fill(255, 255, 0);
    text("STATUS: INITIALIZING", 20, 70);
  }
  
  text("Floor: " + FLOOR_DISTANCE + "cm", 20, 160);
  text("Speed: 5 RPM", 20, 180);
  
  if (myPort != null) {
    text("Arduino: CONNECTED", 20, 200);
  } else {
    fill(255, 0, 0);
    text("Arduino: DISCONNECTED", 20, 200);
  }
}

void serialEvent(Serial p) {
  try {
    String data = p.readStringUntil('\n');
    if (data != null) {
      data = trim(data);
      
      String[] parts = split(data, ',');
      if (parts.length == 2) {
        currentAngle = float(parts[0]);
        currentDistance = float(parts[1]);
        
        // Start immediately when we receive first data
        if (!initializationComplete) {
          initializationComplete = true;
          println("First data received - radar active");
        }
        
        // Store object
        if (currentDistance > 0 && currentDistance < FLOOR_DISTANCE) {
          objects.add(new RadarObject(currentAngle, currentDistance));
        }
      }
    }
  } catch (Exception e) {
    // Silent error
  }
}