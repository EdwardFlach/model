/* @pjs
 pauseOnBlur="true";
 preload="image.jpg";
 */

final color grey = color(190, 195, 195);
final color navy = color(  0, 90, 155);
final color sky = color( 90, 175, 225);
final color leaf = color(130, 200, 120);
final color yellow = color(255, 205, 90);
final color orange = color(250, 165, 85);
final color berry = color(235, 20, 85);

int fontSize;
PFont myFont;
boolean ask = false;

final int RESISTANT = 0;
final int SENSITIVE = 1;
final int WILD      = 2;
CellType[] types = new CellType[3];

PImage land;
Space space;
final float SCALER = 200;
float SCALING;

PVector wildCentre;

void setup() {
  size(screenWidth, screenHeight);
  smooth();
  SCALING = min(1.0*width/SCALER, 1.0*height/SCALER);
  fontSize = floor(8*SCALING);
  myFont = createFont("Futura", fontSize);
  textFont(myFont, fontSize);

  types[WILD]      = new CellType(WILD, grey);
  types[RESISTANT] = new CellType(RESISTANT, navy);
  types[SENSITIVE] = new CellType(SENSITIVE, sky);

  space = new Space();
  frameRate(10);
}

void draw() {
  background(land);

  space.grow();
  space.kill();
  if (!space.cancerDetected()) space.test();
  if (space.cancerDetected()) space.treat();

  space.draw();

  if (ask) { 
    explain();
  }
}

void mouseClicked () {
  ask = !ask;
}

void explain() {
  rectMode(CENTER);
  textAlign(CENTER, CENTER);

  fill(255, 100);
  rect(.5*width, .88*height, 70*SCALING, fontSize*2.1, 5*SCALING);
  fill(100);
  text("phenotype space", .5*width, .88*height);

  fill(255, 100);
  rect(.65*width, .72*height, 80*SCALING, fontSize*2.1, 5*SCALING);
  fill(land.get(int(.6*width), int(.3*height)));
  text("wild-type landscape", .65*width, .72*height);

  fill(255, 100);
  rect(.75*width, .55*height, 80*SCALING, fontSize*2.1, 5*SCALING);
  fill(land.get(int(.6*width), int(.5*height)));
  text("treatment landscape", .75*width, .55*height);  

  fill(255, 100);
  rect(.6*width, .2*height, 50*SCALING, fontSize*2.1, 5*SCALING);
  fill(sky);
  text("cancer cells", .6*width, .2*height);

  fill(255, 100);
  if (!space.cancerDetected()) {
    rect(.2*width, .4*height, 65*SCALING, 45*SCALING, 5*SCALING);
    fill(100);
    text("the tumour is too small to be detected at the moment", .2*width-60*SCALING/2, .4*height-55*SCALING/2, 60*SCALING, 55*SCALING);
  }
  else {
    rect(.2*width, .4*height, 65*SCALING, 45*SCALING, 5*SCALING);
    fill(100);
    text("under treatment the viable landscape is reduced", .2*width-61*SCALING/2, .4*height-55*SCALING/2, 60*SCALING, 55*SCALING);
  }
}

class Cell {
  final float Drift = 15*SCALING;
  PVector location;
  float age;
  CellType type;

  Cell(PVector parent) {
    age = 0;
    location = new PVector( parent.x + random(-Drift, Drift),
                            parent.y + random(-Drift, Drift));
    color c = land.get(floor(location.x), floor(location.y));
    if (green(c) < 170 && blue(c) < 170) type = types[RESISTANT]; // not green is red?
    else if (red(c) < 230 && green(c) < 230 && blue(c) < 230) type = types[SENSITIVE]; // not red is green?
    else type = types[WILD];
    type.increment();
  }

  void remove() {
    type.decrement();
  }

  void mature() {
    age += random(1);
  }

  void draw() {
    fill(type.col,100);
    ellipse(location.x, location.y, 5*SCALING, 5*SCALING);
  }
}

class CellType {
  int index;
  color col;
  int total = 0;

  CellType(int i, color c) {
    index = i;
    col = c;
  }

  void increment() {
    total++;
  }

  void decrement() {
    total--;
  }
}

class Space {
  final int Mature = 5;
  ArrayList cells;
  boolean detected = false;

  Space() {
    land = loadImage("image.jpg");
    land.resize(width, height);
    land.loadPixels();

    wildCentre = new PVector(.4*width, .3*height);
    if (random(2) < 1) wildCentre.x = .6*width;
    if (random(2) < 1) wildCentre.y = .6*height;

    cells = new ArrayList();
    Cell cell;
    for (int i = 1; i < 30; i++) {
      cell = new Cell(wildCentre);
      cell.age = random(Mature);
      cells.add(cell);
    }
  }

  void test() {
    if (cells.size() > 2000) detected = true;
  }

  boolean cancerDetected() {
    return detected;
  }

  void grow() {
    for (int i = cells.size()-1; i >= 0; i--) { 
      Cell cell = (Cell) cells.get(i);
      cell.mature();
      if (cell.age > Mature) {
        Cell child = new Cell(cell.location);
        cells.add(child);
        cell.age = 0;
      }
    }
  }

  void kill() {
    float deathRate = log(cells.size())/80;
    for (int i = cells.size()-1; i >= 0; i--) {
      if (random(1) > .5) {
        Cell cell = (Cell) cells.get(i);
        if (WILD == cell.type.index || deathRate > random(1)) {
          cell.remove();
          cells.remove(i);
        }
      }
    }
  }

  void treat() {
    for (int i = cells.size()-1; i >= 0; i--) { 
      Cell cell = (Cell) cells.get(i);
      if (RESISTANT != cell.type.index && random(2) > 1) {
        cell.remove();
        cells.remove(i);
      }
    }
  }

  void drawCells() {
    for (int i = cells.size()-1; i >= 0; i--) { 
      Cell cell = (Cell) cells.get(i);
      cell.draw();
    }
  }

  void draw() {
    noStroke();
    drawCells();
  }
}
