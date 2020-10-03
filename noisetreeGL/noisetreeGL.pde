float k, hc, rs, bg, xOff, rotZ, fps, minY, minX, maxX, startY;
float mult = .65, angle=24, z = 0, startMs = 0, maxMs = 10000;
int leaves = 0, leafThresh = 8, resets = 0, maxBranch = 200, flowThresh=6;
boolean info, firstBuild;
PGraphics buf;

void setup() {
  size(1920, 1080, P3D);
  buf = createGraphics(1920, 1080, P3D);
  frameRate(24);
  reset();
}

void draw() {
  maxX = 0;
  minX = width;
  minY = height;
  randomSeed((int)rs);

  PGraphics pg = buf; // use offscreen buffer
  pg.beginDraw();
  pg.background(bg);//, 200, 255);

  pg.pushMatrix();
  pg.translate(0, 0, z);
  horizon(pg);

  pg.translate(width/2+xOff, height*.9, 0);
  startY = pg.screenY(0, 0, 0);
  branch(pg, maxBranch, 1);
  pg.popMatrix();

  if (info) showInfo(pg);

  pg.endDraw();

  if (millis()-startMs > maxMs) {
    reset();
    return;
  }
  if (firstBuild) { // check tree-size (make function)
    if (leaves < 3000 || leaves > 8000) {
      println("reset"+(resets)+"(L):"+leaves);
      reset();
      return;
    }
    if (minY > height/3.0 || minY < height/50.0) {
      println("reset"+(resets)+"(H):"+minY);
      reset();
      return;
    }
    if (maxX-minX > width/2) {
      println("reset"+(resets)+"(W):"+(maxX-minX) );
      reset();
      return;
    }
    firstBuild = false;
    resets = 0;
  }

  image(pg, 0, 0); // draw the buffer 
  k += 0.01;
}

void branch(PGraphics g, float len, int depth) {

  if (len > leafThresh) {

    g.stroke(0, 200);

    // map strokeWeight to branch len
    float sw = map(len, maxBranch, leafThresh, 21, .1);

    drawBranch(g, 0, 0, 0, -len, sw, depth);
    g.translate(0, -len);

    len *= random(.5, .9);
    float slop = len/10.0;

    g.pushMatrix(); // TODO: different angles?
    g.rotate(radians(-angle + map(noise(k), 0, 1, -10, 10)));
    branch(g, len+random(-slop, slop), depth+1);
    g.popMatrix();

    g.pushMatrix();
    g.rotate(radians(angle + map(noise(1000+k), 0, 1, -10, 10)));
    branch(g, len+random(-slop, slop), depth+1);
    g.popMatrix();

    if (depth > 2 && random(1) < .4) {
      g.pushMatrix();
      g.rotate(radians(angle/2 + map(noise(1100+k), 0, 1, -10, 10)));
      branch(g, len+random(-slop, slop), depth+1);
      g.popMatrix();
    }
    return;
  }
  drawLeaf(g, len);
  if (firstBuild) leaves++;
}

void drawFlower(PGraphics g, float length) {

  float len = length /2.0;
  for (int i = 0; i < 20; i++) {
    g.stroke(random(200, 255), random(180, 230));
    g.line(0, 0, 0, random(-len, len), random(-len, len), random(-len, len));
  }
}

void drawLeaf(PGraphics g, float len) {

  // compute leaf screen position
  float sx = g.screenX(0, 0, 0);
  float sy = g.screenY(0, 0, 0);
  if (sy - leafThresh < minY) {
    minY = sy - leafThresh;
  }
  if (sx - leafThresh < minX) {
    minX = sx - leafThresh;
  } else if (sx + leafThresh > maxX) {
    maxX = sx + leafThresh;
  }

  if (len < flowThresh) drawFlower(g, len); 

  g.noStroke();
  float b = random(100, 180);
  g.fill(b*.9, b*.45, b, 100);
  b = random(100, 255);
  g.fill(b*random(.1, .2), b*random(.6, .8), b, 100);
  float sz = random(len, len*2); 
  
  g.beginShape();
  g.vertex(-sz, -sz, -sz);
  g.vertex( sz, -sz, -sz);
  g.vertex(   0, 0, sz);
  sz = random(2, 5);
  g.vertex( sz, -sz, -sz);
  g.vertex( sz, sz, -sz);
  g.vertex(   0, 0, sz);
  sz = random(2, 5);
  g.vertex( sz, sz, -sz);
  g.vertex(-sz, sz, -sz);
  g.vertex(   0, 0, sz);
  sz = random(2, 5);
  g.vertex(-sz, sz, -sz);
  g.vertex(-sz, -sz, -sz);
  g.vertex(   0, 0, sz);
  g.endShape();
}

void drawBranch(PGraphics g, float x1, float y1, float x2, float y2, float weight, int depth)
{
  //g.strokeCap(ROUND); // needed?
  float col = random(20);
  if (depth <4) {
    g.stroke(20);
    g.strokeWeight(weight*(depth == 1?.97:.9));
    g.line(x1, y1, x2, y2);
  }

  g.stroke(col);//, map(weight, 0, 14, 120, 400));
  g.strokeWeight(weight);

  float twisti = 2 + 1/weight * 5;

  float xd = x2 - x1, yd = y2 - y1;
  float dist = sqrt(xd * xd + yd * yd);
  int sections = ceil(dist / 10.0f);
  // sections = 8;

  float twist, twist2[] = new float[sections + 1];
  for (int i = 0; i < sections; i++)
  {
    twist = random(-twisti, twisti);
    float tx1 = x1 + ((xd / sections) * (i)) + twist2[i];
    float tx2 = x1 + ((xd / sections) * (i + 1)) + twist;
    float ty1 = y1 + ((yd / sections) * (i));
    float ty2 = y1 + ((yd / sections) * (i + 1));
    if (i == sections - 1)
    {
      tx2 = x2;
      ty2 = y2;
    }
    g.line(tx1, ty1, tx2, ty2);
    twist2[i + 1] = twist;
  }
}

void showInfo(PGraphics g) 
{  
  float y = 0;
  float treeW = maxX - minX;
  float treeH = startY - minY;
  g.fill(255);
  g.textSize(20);
  g.text("fps: "+round(frameRate), 20, y+=30);
  g.text("dim: "+round(treeW)+","+round(treeH), 20, y+=30);
  g.text("leaves: "+leaves, 20, y+=30);
  g.text("zoom: "+z, 20, y+=30);
  g.stroke(200);//, 100);
  g.noFill();
  g.strokeWeight(1);
  g.rect(minX, startY, treeW, -treeH);
}

void horizon(PGraphics g) {
  g.pushMatrix();
  g.rotateZ(rotZ);
  g.translate(0, -200, 0);//-1000);
  
  g.fill(hc);
  g.noStroke();
  g.rect(-2500, height, 10000, height*5);
  g.popMatrix();
}

void mouseWheel(MouseEvent event) {
  z -= 10 * event.getCount();
}

void keyPressed() {
  if (key== 'i')  info = !info;
}

void mouseClicked(MouseEvent evt) {
  reset();
  //if (evt != null && evt.getCount() == 2) {}
}

void reset() {

  resets++;
  leaves = 0;
  firstBuild = true;
  startMs = millis();
  rs = random(Integer.MAX_VALUE);
  xOff = random(-35, 35);
  rotZ = radians(random(-2, 2));
  bg = random(120, 150);
  hc = random(40, 60);
}

color[] getColors() { // unused
  return new color[] {
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80), random(180, 220))
  };
}
