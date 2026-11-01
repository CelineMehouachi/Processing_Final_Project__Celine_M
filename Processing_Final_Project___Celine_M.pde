//Game Name: Slithering: Moon's Embrace
//this is just the beginning

PFont titleFont;
PFont buttonFont;

void setup() {
  size(1000, 650);

  // These are temporary fonts. I'm going to replace these later with a downloaded font.
  titleFont = createFont("Courier New Bold", 58);
  buttonFont = createFont("Courier New Bold", 22);

  textAlign(CENTER, CENTER);
}

void draw() {
  drawBackground();
  drawTitle();
  drawButtons();
  drawCredit();
}

void drawBackground() {
  background(10, 10, 35);

  //placeholder stars
  randomSeed(10);
  for (int i = 0; i < 70; i++) {
    fill(120, 210, 255);
    noStroke();
    circle(random(width), random(height), 2);
  }

  //moon placeholder
  fill(80, 150, 190, 100);
  circle(width - 170, 150, 190);
  fill(25, 25, 65);
  circle(width - 130, 130, 170);

//random line cuz why not
  stroke(0, 220, 255, 120);
  line(0, height - 130, width, height - 130);
}

void drawTitle() {
  textFont(titleFont);

  fill(0, 220, 255);
  text("SLITHERING:", width / 2, 120);

  fill(255, 60, 200);
  text("MOON'S EMBRACE", width / 2, 185);
}

void drawButtons() {
  drawButton("START", width / 2, 340, 250, 55);
  drawButton("ACHIEVEMENTS", width / 2, 425, 250, 55);
}

void drawButton(String label, float x, float y, float buttonWidth, float buttonHeight) {
  noFill();
  stroke(0, 220, 255);
  strokeWeight(2);
  rectMode(CENTER);
  rect(x, y, buttonWidth, buttonHeight);

  fill(230);
  textFont(buttonFont);
  text(label, x, y);
}

void drawCredit() {
  fill(180);
  textFont(createFont("Courier New", 13));
  textAlign(LEFT, BOTTOM);
  text("GAME DEVELOPED BY CelineM.inc", 20, height - 20);
}

void mousePressed() {
  // Buttons don't work yet
