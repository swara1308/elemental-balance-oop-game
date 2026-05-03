// ================================================
// ELEMENTAL BALANCE - Enhanced Portfolio Version
// WCOM1000 Final Project
// 
// A collection-based arcade game demonstrating:
// - Object-Oriented Programming (classes)
// - ArrayList management
// - Collision detection
// - Particle systems
// - Game state management
// - Difficulty scaling
// ================================================

// -----------------------------
// GAME STATE VARIABLES
// -----------------------------
Guardian player;
ArrayList<Orb> orbs;
ArrayList<Particle> particles;

int gameState = 0;  // 0=menu, 1=playing, 2=paused, 3=gameover, 4=victory
int score = 0;
int highScore = 0;
int targetScore = 30;
int difficultyLevel = 1;
float gameTime = 0;

// Element tracking
int[] elementCount = new int[5];  // fire, water, earth, air, chaos
String[] elementNames = {"Fire", "Water", "Earth", "Air", "Chaos"};

// UI state
boolean showInstructions = true;
float uiAlpha = 0;  // for fade-in effects

// Difficulty parameters
float orbSpawnRate = 0.03;  // chance per frame
int maxOrbs = 25;
float baseOrbSpeed = 1.5;

// -----------------------------
// SETUP
// -----------------------------
void setup() {
  size(1000, 1000);
  textAlign(LEFT, TOP);
  smooth();
  
  player = new Guardian(width/2, height/2);
  orbs = new ArrayList<Orb>();
  particles = new ArrayList<Particle>();
  
  // Spawn initial orbs
  for (int i = 0; i < 15; i++) {
    spawnOrb();
  }
}

// -----------------------------
// DRAW
// -----------------------------
void draw() {
  drawBackground();
  
  if (gameState == 0) {
    drawMenuScreen();
  } else if (gameState == 1) {
    updateGame();
    drawGame();
    drawHUD();
  } else if (gameState == 2) {
    drawGame();
    drawHUD();
    drawPauseScreen();
  } else if (gameState == 3) {
    drawGame();
    drawGameOverScreen();
  } else if (gameState == 4) {
    drawGame();
    drawVictoryScreen();
  }
  
  uiAlpha = min(255, uiAlpha + 5);  // fade in UI elements
}

// -----------------------------
// GAME UPDATE LOGIC
// -----------------------------
void updateGame() {
  gameTime += 1/60.0;
  
  // Update difficulty every 10 seconds
  if (frameCount % 600 == 0) {
    increaseDifficulty();
  }
  
  // Update player
  player.update();
  player.applyFriction();
  player.constrainToScreen();
  
  // Update orbs
  for (int i = orbs.size() - 1; i >= 0; i--) {
    Orb orb = orbs.get(i);
    orb.update();
    orb.bounceOffWalls();
    
    // Check collision with player
    if (orb.active && player.collidesWith(orb)) {
      handleOrbCollection(orb);
      orbs.remove(i);
    }
  }
  
  // Spawn new orbs randomly
  if (random(1) < orbSpawnRate && orbs.size() < maxOrbs) {
    spawnOrb();
  }
  
  // Update particles
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
  
  // Check win/lose conditions
  if (score >= targetScore) {
    gameState = 4;  // victory
    if (score > highScore) highScore = score;
  }
  if (player.health <= 0) {
    gameState = 3;  // game over
    if (score > highScore) highScore = score;
  }
}

// -----------------------------
// HANDLE ORB COLLECTION
// -----------------------------
void handleOrbCollection(Orb orb) {
  if (orb.type == 4) {  // Chaos orb (harmful)
    player.takeDamage(15);
    spawnParticleBurst(orb.x, orb.y, color(180, 0, 255), 15);
  } else {  // Beneficial orb
    score++;
    elementCount[orb.type]++;
    player.heal(5);
    player.changeColor(orb.type);
    spawnParticleBurst(orb.x, orb.y, orb.getColor(), 20);
  }
}

// -----------------------------
// DIFFICULTY SCALING
// -----------------------------
void increaseDifficulty() {
  difficultyLevel++;
  orbSpawnRate = min(0.08, orbSpawnRate + 0.005);
  baseOrbSpeed += 0.15;
  maxOrbs = min(30, maxOrbs + 1);
}

// -----------------------------
// SPAWN NEW ORB
// -----------------------------
void spawnOrb() {
  float x = random(80, width - 80);
  float y = random(100, height - 100);
  
  // 20% chance for chaos orb if difficulty level > 2
  int type;
  if (difficultyLevel > 2 && random(1) < 0.2) {
    type = 4;  // chaos
  } else {
    type = int(random(4));  // fire, water, earth, air
  }
  
  orbs.add(new Orb(x, y, type, baseOrbSpeed));
}

// -----------------------------
// PARTICLE BURST EFFECT
// -----------------------------
void spawnParticleBurst(float x, float y, color col, int count) {
  for (int i = 0; i < count; i++) {
    float angle = random(TWO_PI);
    float speed = random(1, 4);
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    particles.add(new Particle(x, y, vx, vy, col));
  }
}

// -----------------------------
// DRAW FUNCTIONS
// -----------------------------
void drawGame() {
  // Draw orbs
  for (Orb orb : orbs) {
    orb.display();
  }
  
  // Draw particles
  for (Particle p : particles) {
    p.display();
  }
  
  // Draw player
  player.display();
}

void drawBackground() {
  background(12, 15, 35);
  
  // Animated starfield
  for (int i = 0; i < 60; i++) {
    float x = (i * 73 + frameCount * 0.2) % width;
    float y = (i * 97) % height;
    float twinkle = sin(frameCount * 0.05 + i) * 30 + 225;
    fill(twinkle, twinkle, 255, 100);
    circle(x, y, 2);
  }
  
  // Atmospheric layers
  noStroke();
  fill(25, 45, 75, 40);
  ellipse(width * 0.3, 150, 400, 400);
  fill(45, 35, 85, 40);
  ellipse(width * 0.7, 120, 350, 350);
  
  // Ground layers
  fill(20, 40, 60);
  beginShape();
  vertex(0, height);
  vertex(0, 600);
  vertex(300, 500);
  vertex(700, 550);
  vertex(width, 520);
  vertex(width, height);
  endShape(CLOSE);
  
  fill(30, 60, 50);
  rect(0, height - 150, width, 150);
  
  // Floating platforms
  fill(40, 70, 65, 180);
  ellipse(200, 650, 280, 80);
  ellipse(550, 630, 350, 90);
  ellipse(850, 660, 250, 75);
}

void drawHUD() {
  // Score panel
  fill(0, 0, 0, 140);
  rect(20, 20, 300, 180, 12);
  
  fill(255, uiAlpha);
  textSize(24);
  text("Elemental Balance", 35, 35);
  
  textSize(18);
  text("Score: " + score + " / " + targetScore, 35, 70);
  text("High Score: " + highScore, 35, 95);
  text("Difficulty: " + difficultyLevel, 35, 120);
  
  // Element breakdown
  textSize(14);
  for (int i = 0; i < 4; i++) {
    fill(getElementColor(i), uiAlpha);
    text(elementNames[i] + ": " + elementCount[i], 35 + (i%2)*140, 145 + (i/2)*20);
  }
  
  // Health bar
  float healthBarWidth = 260;
  float healthPercent = player.health / 100.0;
  
  fill(60, 60, 60, 180);
  rect(35, height - 60, healthBarWidth, 25, 8);
  
  // Health bar color changes based on health
  if (healthPercent > 0.6) {
    fill(80, 220, 100, 220);
  } else if (healthPercent > 0.3) {
    fill(255, 200, 50, 220);
  } else {
    fill(255, 80, 80, 220);
  }
  rect(35, height - 60, healthBarWidth * healthPercent, 25, 8);
  
  fill(255);
  textSize(14);
  text("Health: " + int(player.health), 40, height - 55);
  
  // Instructions toggle
  if (showInstructions) {
    drawInstructions();
  }
  
  // Controls hint
  textSize(12);
  fill(255, uiAlpha * 0.6);
  text("WASD: Move  |  P: Pause  |  R: Restart  |  I: Toggle Help", 35, height - 25);
}

void drawInstructions() {
  fill(0, 0, 0, 160);
  rect(width - 380, 20, 360, 200, 12);
  
  fill(255, 255, 180);
  textSize(20);
  text("HOW TO PLAY", width - 365, 35);
  
  fill(255);
  textSize(15);
  text("• Collect elemental orbs to gain points", width - 365, 70);
  text("• Each orb heals you slightly", width - 365, 92);
  
  fill(180, 0, 255);
  text("• Avoid CHAOS orbs - they damage you!", width - 365, 114);
  
  fill(255);
  text("• Reach " + targetScore + " points to restore balance", width - 365, 136);
  text("• Game gets harder over time", width - 365, 158);
  text("• Don't let your health reach zero!", width - 365, 180);
}

void drawMenuScreen() {
  fill(255, 255, 200, uiAlpha);
  textAlign(CENTER, CENTER);
  textSize(56);
  text("ELEMENTAL BALANCE", width/2, height/2 - 120);
  
  fill(255, uiAlpha);
  textSize(22);
  text("A mystical guardian must collect elemental orbs", width/2, height/2 - 40);
  text("to restore balance to the realm", width/2, height/2 - 10);
  
  textSize(28);
  fill(150, 255, 150, sin(frameCount * 0.1) * 100 + 155);
  text("Press SPACE to Begin", width/2, height/2 + 80);
  
  textSize(16);
  fill(200, 200, 255, uiAlpha * 0.8);
  text("High Score: " + highScore, width/2, height/2 + 140);
  
  textAlign(LEFT, TOP);
}

void drawPauseScreen() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);
  
  fill(255, 255, 150);
  textAlign(CENTER, CENTER);
  textSize(48);
  text("PAUSED", width/2, height/2 - 30);
  
  fill(255);
  textSize(20);
  text("Press P to resume", width/2, height/2 + 30);
  textAlign(LEFT, TOP);
}

void drawGameOverScreen() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);
  
  fill(255, 100, 100);
  textAlign(CENTER, CENTER);
  textSize(52);
  text("BALANCE LOST", width/2, height/2 - 100);
  
  fill(255);
  textSize(24);
  text("Final Score: " + score, width/2, height/2 - 30);
  text("High Score: " + highScore, width/2, height/2 + 10);
  
  textSize(18);
  text("Elements Collected:", width/2, height/2 + 60);
  for (int i = 0; i < 4; i++) {
    fill(getElementColor(i));
    text(elementNames[i] + ": " + elementCount[i], width/2, height/2 + 90 + i*25);
  }
  
  fill(150, 255, 150, sin(frameCount * 0.1) * 100 + 155);
  textSize(22);
  text("Press R to Try Again", width/2, height/2 + 200);
  textAlign(LEFT, TOP);
}

void drawVictoryScreen() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);
  
  fill(255, 255, 150);
  textAlign(CENTER, CENTER);
  textSize(52);
  text("BALANCE RESTORED!", width/2, height/2 - 100);
  
  fill(150, 255, 150);
  textSize(28);
  text("Victory! The realm is saved!", width/2, height/2 - 40);
  
  fill(255);
  textSize(24);
  text("Final Score: " + score, width/2, height/2 + 10);
  text("High Score: " + highScore, width/2, height/2 + 45);
  
  textSize(18);
  text("Elements Mastered:", width/2, height/2 + 95);
  for (int i = 0; i < 4; i++) {
    fill(getElementColor(i));
    text(elementNames[i] + ": " + elementCount[i], width/2, height/2 + 125 + i*25);
  }
  
  fill(150, 255, 150, sin(frameCount * 0.1) * 100 + 155);
  textSize(22);
  text("Press R to Play Again", width/2, height/2 + 230);
  textAlign(LEFT, TOP);
}

// -----------------------------
// HELPER FUNCTIONS
// -----------------------------
color getElementColor(int type) {
  switch(type) {
    case 0: return color(255, 90, 40);      // fire
    case 1: return color(70, 170, 255);     // water
    case 2: return color(110, 190, 80);     // earth
    case 3: return color(210, 230, 255);    // air
    case 4: return color(180, 0, 255);      // chaos
    default: return color(255);
  }
}

color getElementGlow(int type) {
  switch(type) {
    case 0: return color(255, 180, 90);
    case 1: return color(140, 220, 255);
    case 2: return color(170, 240, 150);
    case 3: return color(255, 255, 255);
    case 4: return color(255, 100, 255);
    default: return color(255);
  }
}

void resetGame() {
  player = new Guardian(width/2, height/2);
  orbs.clear();
  particles.clear();
  score = 0;
  gameTime = 0;
  difficultyLevel = 1;
  orbSpawnRate = 0.03;
  maxOrbs = 25;
  baseOrbSpeed = 1.5;
  
  for (int i = 0; i < 5; i++) {
    elementCount[i] = 0;
  }
  
  for (int i = 0; i < 15; i++) {
    spawnOrb();
  }
  
  gameState = 1;
}

// -----------------------------
// INPUT HANDLING
// -----------------------------
void keyPressed() {
  // Menu
  if (gameState == 0 && key == ' ') {
    resetGame();
  }
  
  // Toggle instructions
  if (key == 'i' || key == 'I') {
    showInstructions = !showInstructions;
  }
  
  // Pause
  if (key == 'p' || key == 'P') {
    if (gameState == 1) gameState = 2;
    else if (gameState == 2) gameState = 1;
  }
  
  // Restart
  if (key == 'r' || key == 'R') {
    resetGame();
  }
  
  // Movement (only during active gameplay)
  if (gameState == 1) {
    if (key == 'w' || key == 'W') player.moveUp();
    if (key == 's' || key == 'S') player.moveDown();
    if (key == 'a' || key == 'A') player.moveLeft();
    if (key == 'd' || key == 'D') player.moveRight();
  }
}

void mousePressed() {
  if (gameState == 1 && !player.isDead()) {
    player.x = mouseX;
    player.y = mouseY;
  }
}

// ================================================
// GUARDIAN CLASS - The Player Character
// ================================================
class Guardian {
  float x, y;
  float vx, vy;
  float size;
  float health;
  float maxHealth;
  color bodyColor;
  color glowColor;
  float bobPhase;
  
  Guardian(float startX, float startY) {
    x = startX;
    y = startY;
    vx = 2.0;
    vy = 0;
    size = 50;
    health = 100;
    maxHealth = 100;
    bodyColor = color(160, 120, 255);
    glowColor = color(255, 255, 180);
    bobPhase = 0;
  }
  
  void update() {
    // Auto-movement
    x += vx;
    
    // Vertical movement
    y += vy;
    
    // Bob animation
    bobPhase += 0.08;
  }
  
  void applyFriction() {
    vy *= 0.88;
    
    // Auto-bounce off walls
    if (x > width - 80 || x < 80) {
      vx *= -1;
    }
  }
  
  void constrainToScreen() {
    x = constrain(x, 80, width - 80);
    y = constrain(y, 120, height - 120);
  }
  
  void moveUp() {
    vy -= 4.5;
  }
  
  void moveDown() {
    vy += 4.5;
  }
  
  void moveLeft() {
    vx -= 0.9;
    vx = constrain(vx, -6, 6);
  }
  
  void moveRight() {
    vx += 0.9;
    vx = constrain(vx, -6, 6);
  }
  
  void takeDamage(float amount) {
    health = max(0, health - amount);
  }
  
  void heal(float amount) {
    health = min(maxHealth, health + amount);
  }
  
  boolean isDead() {
    return health <= 0;
  }
  
  void changeColor(int elementType) {
    bodyColor = getElementColor(elementType);
    glowColor = getElementGlow(elementType);
  }
  
  boolean collidesWith(Orb orb) {
    float distance = dist(x, y, orb.x, orb.y);
    return distance < (size/2 + orb.size/2);
  }
  
  void display() {
    float bobOffset = sin(bobPhase) * 10;
    
    // Outer glow
    noStroke();
    fill(glowColor, 80);
    ellipse(x, y + bobOffset, size * 2.2, size * 2.2);
    
    // Energy ring
    noFill();
    stroke(glowColor, 180);
    strokeWeight(2.5);
    ellipse(x, y + bobOffset, size * 1.5, size * 1.5);
    
    // Body core
    noStroke();
    fill(bodyColor);
    ellipse(x, y + bobOffset, size * 0.9, size * 1.2);
    
    // Head
    fill(245, 245, 255);
    circle(x, y - size * 0.6 + bobOffset, size * 0.5);
    
    // Eyes
    fill(30, 30, 60);
    circle(x - size * 0.12, y - size * 0.65 + bobOffset, size * 0.08);
    circle(x + size * 0.12, y - size * 0.65 + bobOffset, size * 0.08);
    
    // Wings
    fill(bodyColor, 180);
    triangle(x - size * 0.25, y - size * 0.1 + bobOffset, 
             x - size * 1.0, y + size * 0.3 + bobOffset, 
             x - size * 0.4, y + size * 0.5 + bobOffset);
    triangle(x + size * 0.25, y - size * 0.1 + bobOffset, 
             x + size * 1.0, y + size * 0.3 + bobOffset, 
             x + size * 0.4, y + size * 0.5 + bobOffset);
    
    // Core gem
    fill(255, 230, 120);
    ellipse(x, y + size * 0.4 + bobOffset, size * 0.25, size * 0.35);
    
    // Sparkles
    fill(255, 255, 220, 200);
    circle(x - size * 0.5, y - size * 0.2 + bobOffset, size * 0.1);
    circle(x + size * 0.55, y - size * 0.3 + bobOffset, size * 0.1);
    circle(x, y + size * 0.75 + bobOffset, size * 0.12);
  }
}

// ================================================
// ORB CLASS - Collectible Elements
// ================================================
class Orb {
  float x, y;
  float vx, vy;
  float size;
  int type;  // 0-3: elements, 4: chaos
  boolean active;
  float pulsePhase;
  
  Orb(float startX, float startY, int orbType, float speedMultiplier) {
    x = startX;
    y = startY;
    type = orbType;
    size = random(25, 38);
    active = true;
    pulsePhase = random(TWO_PI);
    
    // Random velocity
    vx = random(-1.8, 1.8) * speedMultiplier;
    vy = random(-1.5, 1.5) * speedMultiplier;
    
    // Ensure minimum speed
    if (abs(vx) < 0.6) vx = 1.2 * speedMultiplier;
    if (abs(vy) < 0.5) vy = -1.0 * speedMultiplier;
  }
  
  void update() {
    x += vx;
    y += vy;
    pulsePhase += 0.1;
  }
  
  void bounceOffWalls() {
    if (x < 50 || x > width - 50) vx *= -1;
    if (y < 90 || y > height - 90) vy *= -1;
  }
  
  color getColor() {
    return getElementColor(type);
  }
  
  void display() {
    float pulse = sin(pulsePhase) * 4 + size;
    color mainCol = getElementColor(type);
    color glowCol = getElementGlow(type);
    
    // Outer glow
    noStroke();
    fill(glowCol, 70);
    ellipse(x, y, pulse + 25, pulse + 25);
    
    // Main orb body
    fill(mainCol);
    ellipse(x, y, pulse, pulse);
    
    // Highlight
    fill(255, 255, 255, 140);
    ellipse(x - pulse * 0.2, y - pulse * 0.2, pulse * 0.4, pulse * 0.3);
    
    // Type symbol
    stroke(255, 255, 255, 200);
    strokeWeight(2.5);
    noFill();
    
    if (type == 0) {  // Fire - flame
      line(x, y + 7, x, y - 9);
      line(x, y - 9, x - 6, y - 2);
      line(x, y - 9, x + 6, y - 2);
    } else if (type == 1) {  // Water - droplet
      ellipse(x, y, 10, 14);
    } else if (type == 2) {  // Earth - layers
      line(x - 7, y + 5, x + 7, y + 5);
      line(x - 5, y, x + 5, y);
      line(x - 3, y - 5, x + 3, y - 5);
    } else if (type == 3) {  // Air - wind
      line(x - 8, y - 3, x + 8, y - 3);
      line(x - 6, y + 3, x + 6, y + 3);
    } else if (type == 4) {  // Chaos - skull/warning
      strokeWeight(3);
      line(x - 5, y - 5, x + 5, y + 5);
      line(x + 5, y - 5, x - 5, y + 5);
    }
    
    noStroke();
  }
}

// ================================================
// PARTICLE CLASS - Visual Effects
// ================================================
class Particle {
  float x, y;
  float vx, vy;
  float life;
  float maxLife;
  color col;
  float size;
  
  Particle(float startX, float startY, float velX, float velY, color c) {
    x = startX;
    y = startY;
    vx = velX;
    vy = velY;
    col = c;
    life = random(30, 60);
    maxLife = life;
    size = random(3, 8);
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.15;  // gravity
    vx *= 0.98;  // air resistance
    life--;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    float alpha = map(life, 0, maxLife, 0, 255);
    noStroke();
    fill(col, alpha);
    circle(x, y, size * (life / maxLife));
  }
}
