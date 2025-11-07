// PPI Radar Display - MOCK SIMULATION (No Arduino Required)
// All serial code has been removed and replaced with a simulation.

// import processing.serial.*; // <<< REMOVED
// Serial myPort; // <<< REMOVED
PFont uiFont; // Font for all UI text

float angle = 0;
float distance = 0;
float[] distanceMemory = new float[360];
int[] sweepPersistence = new int[360]; // Array to store the sweep's "brightness"

// --- Visualization Parameters ---
final int GRID_LINES = 12;    // Number of angular grid lines (360 / 12 = 30 degree sectors)
final int RANGE_RINGS = 6;    // Number of concentric rings
final int MAX_RANGE_CM = 600; // Simulated maximum range for text labels
final int SWEEP_FADE_SPEED = 10; // How fast the green fan fades (higher is faster)
final float TARGET_DECAY_RATE = 0.98; // How fast red lines fade (closer to 1.0 is slower)
final int ALERT_DISTANCE = 200; // <<< NEW: Alert threshold in CM
boolean intruderAlert = false; // <<< NEW: Global state for alert

// --- Mock Data Parameters ---
float currentMockAngle = 0; // <<< RE-ADDED
float sweepSpeed = 1.0; // <<< RE-ADDED

void setup() {
  size(800, 800);
  background(0);
  frameRate(30); 
  
  // Initialize persistence array
  for (int i = 0; i < 360; i++) {
    sweepPersistence[i] = 0;
  }
  
  // <<< NEW: Create and set the UI font
  // "Monospaced" is a safe, cross-platform font that looks "technical"
  uiFont = createFont("Monospaced", 16, true);
  textFont(uiFont); // Set this as the default font
  
  // --- Initialize Serial Port (REMOVED) ---
  // println(Serial.list()); 
  // String portName = Serial.list()[0]; 
  // myPort = new Serial(this, portName, 9600);
  // myPort.bufferUntil('.'); 
}

// --- serialEvent() function (REMOVED) ---

void draw() {
  // --- 0. CALCULATE DYNAMIC RADIUS ---
  float radarPixelRadius = min(width, height) * 0.4;
  
  // --- 1. MOCK DATA GENERATION (RE-ADDED) ---
  
  currentMockAngle += sweepSpeed;
  if (currentMockAngle >= 360) {
    currentMockAngle = 0;
  }
  
  float mockDistance;
  if (currentMockAngle >= 30 && currentMockAngle <= 70) { 
    mockDistance = 250 + random(0, 100); 
  } else if (currentMockAngle >= 130 && currentMockAngle <= 160) { 
    mockDistance = 100 + random(0, 50);
  } else if (currentMockAngle >= 250 && currentMockAngle <= 300) { 
    mockDistance = 350 + random(0, 100);
  } else {
    mockDistance = 0; 
  }
  
  // Update the global angle and distance variables
  angle = currentMockAngle;
  distance = mockDistance;
  int angleIndex = (int) currentMockAngle % 360;
  
  // Store new target data
  if (distance > 0) {
    distanceMemory[angleIndex] = distance;
  }
  
  // Set current sweep angle to full brightness for the fan effect
  sweepPersistence[angleIndex] = 255;
  
  
  // --- 1b. NEW: Decay all non-active target blips ---
  // This loop runs every frame and fades all targets that are *not*
  // at the current sweep angle.
  for (int i = 0; i < 360; i++) {
    if (i != angleIndex) {
      distanceMemory[i] *= TARGET_DECAY_RATE; // Make the line shorter
      if (distanceMemory[i] < 1) distanceMemory[i] = 0; // Clear it if it's too small
    }
  }

  // --- 1c. NEW: Check for intruder alerts ---
  // This loop checks *all* active blips. If any are too close, it triggers the alert.
  intruderAlert = false; // Assume no alert
  for (int i = 0; i < 360; i++) {
    if (distanceMemory[i] > 0 && distanceMemory[i] <= ALERT_DISTANCE) {
      intruderAlert = true;
      break; // Found one, no need to check the rest
    }
  }

  // --- 2. RADAR DISPLAY AND VISUALIZATION ---
  
  background(0); 
  translate(width / 2, height / 2); // Move origin to center

  // 2a. Draw Fading Green Fan (Filled Arcs)
  for (int i = 0; i < 360; i++) {
    if (sweepPersistence[i] > 0) {
      fill(0, 255, 0, sweepPersistence[i]); 
      noStroke(); 
      
      // Fix for arc direction
      float startAngle = radians(-i - 0.5); 
      float endAngle = radians(-i + 0.5);   
      
      arc(0, 0, radarPixelRadius * 2, radarPixelRadius * 2, startAngle, endAngle, PIE);
      
      sweepPersistence[i] -= SWEEP_FADE_SPEED; 
    }
  }

  // 2b. Draw Grid and Range Rings
  strokeWeight(4); // Fatter grid lines
  stroke(0, 255, 0, 150); // Semi-transparent Green
  noFill();
  
  for (int i = 1; i <= RANGE_RINGS; i++) {
    float ringDiameter = (float) i / RANGE_RINGS * (radarPixelRadius * 2);
    ellipse(0, 0, ringDiameter, ringDiameter);
  }
  
  for (int i = 0; i < GRID_LINES; i++) {
    float lineAngle = radians(i * (360 / GRID_LINES));
    float x = radarPixelRadius * cos(lineAngle);
    float y = -radarPixelRadius * sin(lineAngle);
    line(0, 0, x, y);
  }
  
  // 2c. Draw Target Echoes (Thick Radial Lines)
  stroke(255, 0, 0); // Bright Red
  strokeWeight(4);   
  
  for (int i = 0; i < 360; i++) {
    float r_cm = distanceMemory[i];
    
    // Scale distance (cm) to pixel radius
    float r_pixels = map(r_cm, 0, MAX_RANGE_CM, 0, radarPixelRadius);
    r_pixels = constrain(r_pixels, 0, radarPixelRadius);
    
    // Only draw if there's a valid distance
    if (r_pixels > 1) { 
      float x = r_pixels * cos(radians(i));
      float y = -r_pixels * sin(radians(i)); 
      
      // Draw a thick line from the center to the target
      line(0, 0, x, y); 
    }
  }

  // 2d. Draw (Main) Sweep Line (on top of everything)
  stroke(0, 255, 0); // Bright Green
  strokeWeight(3); // Fatter main sweep line
  float sweepX = radarPixelRadius * cos(radians(angle)); 
  float sweepY = -radarPixelRadius * sin(radians(angle));
  line(0, 0, sweepX, sweepY);

  // 2e. Add Range Labels (Dynamic Text Size)
  fill(0, 255, 0);
  float labelSize = max(10, radarPixelRadius * 0.05); 
  textFont(uiFont, labelSize * 0.9); // <<< Apply the new font
  textAlign(CENTER, TOP); // <<< Align text to be drawn *above* the line
  
  for (int i = 1; i <= RANGE_RINGS; i++) {
    float labelX = (float) i / RANGE_RINGS * radarPixelRadius; 
    float rangeValue = (float) i * (MAX_RANGE_CM / RANGE_RINGS);
    // <<< Draw label text just above the 0-degree (right) horizontal line
    text(nf(rangeValue, 0, 0), labelX, 5); 
  }
  
  // 2f. Draw UI Elements (Dynamic Text Size and Position)
  float uiTextSize = max(12, width * 0.02); 
  textFont(uiFont, uiTextSize); // <<< Apply the new font
  textAlign(LEFT);
  resetMatrix(); 
  fill(0, 255, 0);
  
  float textY = height - (uiTextSize * 1.5);
  
  text("Sentry 360", 20, textY);
  textAlign(RIGHT);
  // <<< MODIFIED: Increased spacing by changing 10 to 15 to prevent overlap
  text("Angle: " + nf(angle, 0, 0) + "°", width - (uiTextSize * 15), textY);
  text("Distance: " + nf(distance, 0, 0) + " cm", width - 20, textY);
  
  // --- 2g. NEW: Draw Angular Labels ---
  translate(width / 2, height / 2); // Go back to center
  fill(0, 255, 0); // Green
  textFont(uiFont, labelSize * 0.9); // Use the new font
  noStroke();

  for (int i = 0; i < 360; i += 30) { // Every 30 degrees (matches GRID_LINES)
      // Calculate the position just outside the radar circle
      float labelRadius = radarPixelRadius + (labelSize * 2.0); // Add padding
      float x = labelRadius * cos(radians(i));
      float y = -labelRadius * sin(radians(i)); // Use -sin for correct Processing Y-axis

      // Adjust text alignment based on position for readability
      if (i == 0 || i == 360) { // Right
          textAlign(LEFT, CENTER);
      } else if (i == 180) { // Left
          textAlign(RIGHT, CENTER);
      } else if (i == 90) { // Top
          textAlign(CENTER, BOTTOM);
      } else if (i == 270) { // Bottom
          textAlign(CENTER, TOP);
      } else if (i > 0 && i < 90) { // Top-Right
          textAlign(LEFT, BOTTOM);
      } else if (i > 90 && i < 180) { // Top-Left
          textAlign(RIGHT, BOTTOM);
      } else if (i > 180 && i < 270) { // Bottom-Left
          textAlign(RIGHT, TOP);
      } else if (i > 270 && i < 360) { // Bottom-Right
          textAlign(LEFT, TOP);
      }

      text(i + "°", x, y);
  }
  
  // --- 2h. NEW: Draw Intruder Alert (Upper Left) ---
  if (intruderAlert) {
    // Logic for the blink (1 second interval: 0.5s on, 0.5s off)
    boolean isBlinkOn = (millis() % 1000 < 500);
    
    // Draw the light bulb
    // Use resetMatrix() to draw in corner, but must re-translate for button
    resetMatrix(); // Draw relative to screen corner
    float lightX = 25;
    float lightY = 30;
    float lightDiameter = uiTextSize * 1.5;
    
    if (isBlinkOn) {
      fill(255, 0, 0); // Bright Red
    } else {
      fill(100, 0, 0); // Dark Red (Off)
    }
    noStroke();
    ellipse(lightX, lightY, lightDiameter, lightDiameter);
    
    // Draw the text (only when blink is ON)
    if (isBlinkOn) {
      fill(255, 0, 0); // Bright Red Text
      textAlign(LEFT, CENTER);
      textFont(uiFont, uiTextSize);
      text("WARNING! INTRUDER ALERT!", lightX + lightDiameter + 10, lightY);
    }
  }

  // --- 2i. NEW: Draw Reset Button (was 2h) ---
  // Must be drawn *after* resetMatrix() to use screen coordinates
  resetMatrix();
  float btnW = uiTextSize * 6; // Button width
  float btnH = uiTextSize * 2; // Button height
  float btnX = width - btnW - 20; // X position (20px from right edge)
  float btnY = 20; // Y position (20px from top edge)

  // Draw button background
  // Check if mouse is hovering over it
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    fill(0, 200, 0); // Brighter green on hover
  } else {
    fill(0, 150, 0); // Dark green
  }
  stroke(0, 255, 0); // Bright green border
  strokeWeight(2);
  rect(btnX, btnY, btnW, btnH, 5); // Rounded corners

  // Draw button text
  fill(0, 255, 0); // Bright green text
  textAlign(CENTER, CENTER);
  textFont(uiFont, uiTextSize);
  text("RESET", btnX + btnW / 2, btnY + btnH / 2);
}

// --- NEW FUNCTION: Handles Mouse Clicks ---
void mousePressed() {
  // Calculate button dimensions again (since it's dynamic)
  float uiTextSize = max(12, width * 0.02); 
  float btnW = uiTextSize * 6;
  float btnH = uiTextSize * 2;
  float btnX = width - btnW - 20;
  float btnY = 20;

  // Check if the click was inside the button
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    // --- Perform Reset ---
    currentMockAngle = 0;
    angle = 0;
    intruderAlert = false; // <<< NEW: Reset alert state
    
    // Clear all memory arrays for a full visual reset
    for (int i = 0; i < 360; i++) {
      distanceMemory[i] = 0;
      sweepPersistence[i] = 0;
    }
  }
}