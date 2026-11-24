//Game Name: Slithering: Moon's Embrace

import processing.sound.*;

PFont titleFont;
PFont buttonFont;
PFont smallFont;
SoundFile backgroundSound;

final int START_PAGE = 0;
final int ACHIEVEMENTS_PAGE = 1;
final int LEVELS_PAGE = 2;
final int LEVEL1_PAGE = 3;

int currentPage = START_PAGE;

PImage startBackground;
PImage achievementsBackground;
PImage levelsBackground;
PImage level1Background;
PImage startButtonImage;
PImage achievementsButtonImage;
PImage level1ButtonImage;
PImage level2ButtonImage;
PImage level3ButtonImage;
PImage challengeButtonImage;

final int COLS = 28;
final int ROWS = 15;
final int CELL = 30;
final int MAP_X = 80;
final int MAP_Y = 115;
final int MAX_SNAKE = COLS * ROWS;

boolean[][] walls = new boolean[COLS][ROWS];
boolean[][] seeds = new boolean[COLS][ROWS];
boolean[][] checkpoints = new boolean[COLS][ROWS];

int[] snakeX = new int[MAX_SNAKE];
int[] snakeY = new int[MAX_SNAKE];
int snakeLength = 5;
int directionX = 0;
int directionY = 1;
int nextDirectionX = 0;
int nextDirectionY = 1;

int[] enemyX = {12, 22, 5};
int[] enemyY = {4, 10, 7};
int[] enemyDX = {1, 0, 0};
int[] enemyDY = {0, 1, 0};
int[] enemyMin = {9, 3, 5};
int[] enemyMax = {16, 11, 22};
int enemyStepCounter = 0;

int lives = 3;
int seedsCollected = 0;
int totalSeeds = 0;
int checkpointsCollected = 0;
int totalCheckpoints = 0;
int lastMoveTime;
int moveDelay = 180;
boolean levelWon = false;
boolean gameOver = false;

void setup() {
  size(1000, 650);
  titleFont = createFont("Courier New Bold", 38);
  buttonFont = createFont("Courier New Bold", 22);
  smallFont = createFont("Courier New", 13);
  setupLevel1();
}

void draw() {
  if (currentPage == START_PAGE) {
    drawStartPage();
  } else if (currentPage == ACHIEVEMENTS_PAGE) {
    drawAchievementsPage();
  } else if (currentPage == LEVELS_PAGE) {
    drawLevelsPage();
  } else if (currentPage == LEVEL1_PAGE) {
    drawLevel1Page();
  }
}

void drawBackground(PImage pageBackground) {
  if (pageBackground != null) {
    imageMode(CORNER);
    image(pageBackground, 0, 0, width, height);
  } else {
    background(10, 10, 35);
    randomSeed(10);
    noStroke();
    for (int i = 0; i < 70; i++) {
      fill(120, 210, 255);
      circle(random(width), random(height), 2);
    }
    fill(80, 150, 190, 100);
    circle(width - 170, 150, 190);
    fill(25, 25, 65);
    circle(width - 130, 130, 170);
    stroke(0, 220, 255, 120);
    line(0, height - 130, width, height - 130);
  }
}

void drawStartPage() {
  drawBackground(startBackground);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  fill(0, 220, 255);
  text("SLITHERING:", width / 2, 120);
  fill(255, 60, 200);
  text("MOON'S EMBRACE", width / 2, 185);
  drawButton("START", width / 2, 340, 250, 55, startButtonImage);
  drawButton("ACHIEVEMENTS", width / 2, 425, 250, 55, achievementsButtonImage);
  drawCredit();
}

void drawAchievementsPage() {
  drawBackground(achievementsBackground);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  fill(0, 220, 255);
  text("Achievements:", width / 2, height / 2);
  drawBackButton();
}

void drawLevelsPage() {
  drawBackground(levelsBackground);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  fill(0, 220, 255);
  text("LEVELS", width / 2, 100);
  drawButton("LEVEL 1", 250, 280, 220, 65, level1ButtonImage);
  drawButton("LEVEL 2", 500, 280, 220, 65, level2ButtonImage);
  drawButton("LEVEL 3", 750, 280, 220, 65, level3ButtonImage);
  drawButton("TICKING MAZE", 830, 565, 260, 55, challengeButtonImage);
  drawBackButton();
}

void drawLevel1Page() {
  drawBackground(level1Background);
  if (!levelWon && !gameOver) {
    updateLevel1();
  }
  drawMap();
  drawHUD();
  drawSnake();
  drawEnemies();
  drawBackButton();
  if (levelWon) {
    drawMessage("LEVEL COMPLETE", "Press R to play again or B to return");
  }
  if (gameOver) {
    drawMessage("GAME OVER", "Press R to retry or B to return");
  }
}

void setupLevel1() {
  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      walls[x][y] = false;
      seeds[x][y] = false;
      checkpoints[x][y] = false;
    }
  }

  for (int x = 0; x < COLS; x++) {
    walls[x][0] = true;
    walls[x][ROWS - 1] = true;
  }
  for (int y = 0; y < ROWS; y++) {
    walls[0][y] = true;
    walls[COLS - 1][y] = true;
  }

  for (int x = 3; x < 10; x++) walls[x][4] = true;
  for (int x = 15; x < 24; x++) walls[x][7] = true;
  for (int x = 5; x < 13; x++) walls[x][11] = true;
  for (int y = 2; y < 7; y++) walls[18][y] = true;
  for (int y = 8; y < 13; y++) walls[8][y] = true;
  for (int y = 3; y < 10; y++) walls[25][y] = true;

  int[][] seedPositions = {
    {3, 2}, {6, 2}, {10, 2}, {14, 2}, {21, 2},
    {3, 6}, {7, 6}, {12, 6}, {16, 6}, {22, 6},
    {3, 9}, {12, 9}, {16, 9}, {21, 9}, {23, 12},
    {3, 13}, {14, 13}, {20, 13}, {24, 13}
  };

  for (int i = 0; i < seedPositions.length; i++) {
    int x = seedPositions[i][0];
    int y = seedPositions[i][1];
    if (!walls[x][y]) seeds[x][y] = true;
  }

  int[][] checkpointPositions = {{4, 2}, {14, 6}, {22, 12}};
  for (int i = 0; i < checkpointPositions.length; i++) {
    checkpoints[checkpointPositions[i][0]][checkpointPositions[i][1]] = true;
  }

  totalSeeds = countSeeds();
  totalCheckpoints = checkpointPositions.length;
  resetLevel1();
}

void resetLevel1() {
  snakeLength = 5;
  lives = 3;
  seedsCollected = 0;
  checkpointsCollected = 0;
  directionX = 0;
  directionY = 1;
  nextDirectionX = 0;
  nextDirectionY = 1;
  levelWon = false;
  gameOver = false;
  lastMoveTime = millis();

  for (int i = 0; i < MAX_SNAKE; i++) {
    snakeX[i] = 2;
    snakeY[i] = 1 - i;
  }
  snakeX[0] = 2;
  snakeY[0] = 5;
  snakeX[1] = 2;
  snakeY[1] = 4;
  snakeX[2] = 2;
  snakeY[2] = 3;
  snakeX[3] = 2;
  snakeY[3] = 2;
  snakeX[4] = 2;
  snakeY[4] = 1;

  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      if (x == 2 && y >= 1 && y <= 5) seeds[x][y] = false;
    }
  }
}

void updateLevel1() {
  if (millis() - lastMoveTime < moveDelay) return;
  lastMoveTime = millis();

  if (!(nextDirectionX == -directionX && nextDirectionY == -directionY)) {
    directionX = nextDirectionX;
    directionY = nextDirectionY;
  }

  for (int i = snakeLength - 1; i > 0; i--) {
    snakeX[i] = snakeX[i - 1];
    snakeY[i] = snakeY[i - 1];
  }

  snakeX[0] += directionX;
  snakeY[0] += directionY;
  moveEnemies();
  checkLevelCollisions();
}

void moveEnemies() {
  enemyStepCounter++;
  if (enemyStepCounter % 2 != 0) return;

  for (int i = 0; i < enemyX.length; i++) {
    int newX = enemyX[i] + enemyDX[i];
    int newY = enemyY[i] + enemyDY[i];
    if (newX < enemyMin[i] || newX > enemyMax[i] || newY < enemyMin[i] || newY > enemyMax[i]) {
      enemyDX[i] *= -1;
      enemyDY[i] *= -1;
    }
    enemyX[i] += enemyDX[i];
    enemyY[i] += enemyDY[i];
  }
}

void checkLevelCollisions() {
  int headX = snakeX[0];
  int headY = snakeY[0];

  if (headX < 0 || headX >= COLS || headY < 0 || headY >= ROWS || walls[headX][headY]) {
    loseLife();
    return;
  }

  for (int i = 1; i < snakeLength; i++) {
    if (headX == snakeX[i] && headY == snakeY[i]) {
      loseLife();
      return;
    }
  }

  for (int i = 0; i < enemyX.length; i++) {
    if (headX == enemyX[i] && headY == enemyY[i]) {
      loseLife();
      return;
    }
  }

  if (seeds[headX][headY]) {
    seeds[headX][headY] = false;
    seedsCollected++;
    if (seedsCollected % 3 == 0 && snakeLength < MAX_SNAKE) {
      snakeLength++;
      snakeX[snakeLength - 1] = snakeX[snakeLength - 2];
      snakeY[snakeLength - 1] = snakeY[snakeLength - 2];
    }
  }

  if (checkpoints[headX][headY]) {
    checkpoints[headX][headY] = false;
    checkpointsCollected++;
  }

  if (seedsCollected == totalSeeds && checkpointsCollected == totalCheckpoints) {
    levelWon = true;
  }
}

void loseLife() {
  lives--;
  snakeLength -= 2;
  if (snakeLength <= 0 || lives <= 0) {
    snakeLength = max(0, snakeLength);
    gameOver = true;
    return;
  }

  snakeX[0] = 2;
  snakeY[0] = 5;
  directionX = 0;
  directionY = 1;
  nextDirectionX = 0;
  nextDirectionY = 1;

  for (int i = 1; i < snakeLength; i++) {
    snakeX[i] = 2;
    snakeY[i] = 5 - i;
  }
  lastMoveTime = millis();
}

void drawMap() {
  rectMode(CORNER);
  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      float px = MAP_X + x * CELL;
      float py = MAP_Y + y * CELL;
      if (walls[x][y]) {
        fill(75, 35, 105);
        stroke(180, 60, 220);
      } else {
        fill(12, 20, 48);
        stroke(30, 80, 120);
      }
      rect(px, py, CELL, CELL);

      if (seeds[x][y]) {
        fill(255, 230, 70);
        noStroke();
        circle(px + CELL / 2, py + CELL / 2, 9);
        fill(255, 255, 180, 90);
        circle(px + CELL / 2, py + CELL / 2, 18);
      }

      if (checkpoints[x][y]) {
        fill(255, 50, 190);
        stroke(255, 170, 240);
        ellipse(px + CELL / 2, py + CELL / 2, 21, 21);
      }
    }
  }
}

void drawSnake() {
  rectMode(CORNER);
  for (int i = snakeLength - 1; i >= 0; i--) {
    float px = MAP_X + snakeX[i] * CELL;
    float py = MAP_Y + snakeY[i] * CELL;
    if (i == 0) {
      fill(0, 235, 255);
      stroke(200, 255, 255);
    } else {
      fill(60, 240, 170);
      stroke(20, 150, 130);
    }
    rect(px + 3, py + 3, CELL - 6, CELL - 6, 5);
  }
  if (snakeLength > 0) {
    float px = MAP_X + snakeX[0] * CELL;
    float py = MAP_Y + snakeY[0] * CELL;
    fill(10, 10, 35);
    ellipse(px + 10, py + 11, 4, 4);
    ellipse(px + 20, py + 11, 4, 4);
  }
}

void drawEnemies() {
  rectMode(CORNER);
  for (int i = 0; i < enemyX.length; i++) {
    float px = MAP_X + enemyX[i] * CELL;
    float py = MAP_Y + enemyY[i] * CELL;
    fill(255, 70, 90);
    stroke(255, 180, 100);
    rect(px + 5, py + 5, CELL - 10, CELL - 10, 4);
  }
}

void drawHUD() {
  textAlign(LEFT, CENTER);
  textFont(smallFont);
  fill(240);
  text("LIVES: " + lives + "    SNAKE BLOCKS: " + snakeLength, 80, 35);
  text("SEEDS: " + seedsCollected + "/" + totalSeeds + "    CHECKPOINTS: " + checkpointsCollected + "/" + totalCheckpoints, 80, 62);
}

void drawMessage(String heading, String instruction) {
  rectMode(CENTER);
  fill(5, 8, 30, 235);
  stroke(0, 230, 255);
  rect(width / 2, height / 2, 490, 150);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  fill(255, 70, 210);
  text(heading, width / 2, height / 2 - 35);
  textFont(smallFont);
  fill(230);
  text(instruction, width / 2, height / 2 + 25);
}

int countSeeds() {
  int count = 0;
  for (int x = 0; x < COLS; x++) {
    for (int y = 0; y < ROWS; y++) {
      if (seeds[x][y]) count++;
    }
  }
  return count;
}

void drawButton(String label, float x, float y, float buttonWidth, float buttonHeight, PImage buttonImage) {
  rectMode(CENTER);
  noFill();
  stroke(0, 220, 255);
  strokeWeight(2);
  rect(x, y, buttonWidth, buttonHeight);
  if (buttonImage != null) {
    imageMode(CENTER);
    image(buttonImage, x, y, buttonWidth, buttonHeight);
  } else {
    textAlign(CENTER, CENTER);
    fill(230);
    textFont(buttonFont);
    text(label, x, y);
  }
}

void drawBackButton() {
  drawButton("BACK", 90, 580, 120, 45, null);
}

void drawCredit() {
  textAlign(LEFT, BOTTOM);
  textFont(smallFont);
  fill(180);
  text("GAME DEVELOPED BY CelineM.inc", 20, height - 20);
}

void mousePressed() {
  if (currentPage == START_PAGE) {
    if (insideButton(width / 2, 340, 250, 55)) currentPage = LEVELS_PAGE;
    else if (insideButton(width / 2, 425, 250, 55)) currentPage = ACHIEVEMENTS_PAGE;
  } else if (currentPage == ACHIEVEMENTS_PAGE) {
    if (insideButton(90, 580, 120, 45)) currentPage = START_PAGE;
  } else if (currentPage == LEVELS_PAGE) {
    if (insideButton(250, 280, 220, 65)) {
      setupLevel1();
      currentPage = LEVEL1_PAGE;
    } else if (insideButton(90, 580, 120, 45)) {
      currentPage = START_PAGE;
    }
  } else if (currentPage == LEVEL1_PAGE) {
    if (insideButton(90, 580, 120, 45)) currentPage = LEVELS_PAGE;
  }
}

boolean insideButton(float x, float y, float buttonWidth, float buttonHeight) {
  return mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2;
}

void keyPressed() {
  if (currentPage == LEVEL1_PAGE && !levelWon && !gameOver) {
    if ((key == 'w' || key == 'W' || keyCode == UP) && directionY != 1) {
      nextDirectionX = 0;
      nextDirectionY = -1;
    }
    if ((key == 's' || key == 'S' || keyCode == DOWN) && directionY != -1) {
      nextDirectionX = 0;
      nextDirectionY = 1;
    }
    if ((key == 'a' || key == 'A' || keyCode == LEFT) && directionX != 1) {
      nextDirectionX = -1;
      nextDirectionY = 0;
    }
    if ((key == 'd' || key == 'D' || keyCode == RIGHT) && directionX != -1) {
      nextDirectionX = 1;
      nextDirectionY = 0;
    }
  }
  if ((levelWon || gameOver) && (key == 'r' || key == 'R')) {
    setupLevel1();
  }
  if ((levelWon || gameOver) && (key == 'b' || key == 'B')) {
    currentPage = LEVELS_PAGE;
  }
}
