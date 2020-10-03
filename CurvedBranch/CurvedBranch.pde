int rs;
float x1, x2, y1, y2, cx, cy;

void setup() {
  size(800, 600);
  mouseClicked();
}
void draw() {
  background(255);
  randomSeed(rs);
  strokeWeight(1);
  line(x1, y1, x2, y2);
  circle(cx, cy, 15);
  curveTightness(map(mouseX, 0, width, 1, 10));
  noFill();
  strokeWeight(4);
  beginShape();
  vertex(x2, y2);
  quadraticVertex(cx, cy, x1, y1);
  endShape();
}

void mouseClicked() {
  rs = floor(random(100000));
  x1 = random(width*.33, width*.66);
  x2 = x1 + random(-150, 150);
  y1 = random(height/2, height);
  y2 = 100;
  float dx = abs(x2-x1);
  float dy = abs(y2-y1);
  println(dy);
  cx = x1 + random(-dy/2, dy/2);//random(-dx/2,dx/2);
  cy = y1 + (y2-y1)/2;//random(-dy/2,dy/2);
}
