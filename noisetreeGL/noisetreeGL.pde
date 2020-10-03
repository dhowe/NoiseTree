float k, hc, rs, bg, xOff, rotZ, fps, trunk, treeH, zOff;
float mult = .65, angle=24, z = -200;
int leaves = 0, leafThresh = 16;
boolean info = true, firstBuild = true;
PGraphics pg;

void setup() {
  size(1920, 1080, P3D);
  pg = createGraphics(1920, 1080, P3D);
  frameRate(24);
  reset();
}

void draw() {
  PGraphics gg = pg;
  randomSeed((int)rs);

  gg.beginDraw();
  gg.background(bg);//, 200, 255);
  gg.pushMatrix();
  gg.translate(0, 0, z);
  horizon(gg);

  gg.translate(width/2+xOff, height-100, -200);
  branch(gg, trunk = random(200, 360));
  gg.popMatrix();
  if (info) showInfo(gg);
  gg.endDraw();

  if (firstBuild) { // check tree-size
    if (treeH > height/3.0 || treeH < height/10.0) {
      println("reset:"+treeH);
      reset();
      return;
    }
    firstBuild = false;
  }
  image(gg, 0, 0); // draw the buffer 
  k += 0.01;
}

void showInfo(PGraphics g) 
{
  g.fill(255);
  g.textSize(24);
  //if (frameCount % 10 == 0) fps = frameRate;
  g.text("fps: "+round(frameRate), 20, 30);
  g.text("leaves: "+leaves, 20, 60);
  if (firstBuild) println(leaves);
  g.text("trunk: "+trunk, 20, 90);
  g.text("density: "+(1-(trunk/(float)leaves)), 20, 120);
  g.text("height: "+treeH, 20, 150);
  g.text("zOff: "+min(treeH, 0)*5, 20, 180);
  g.stroke(255);
  g.line(0, treeH, width, treeH);
  g.noStroke();
}

void horizon(PGraphics g) {
  g.pushMatrix();
  g.translate(0, 0, -1000);
  g.rotateZ(rotZ);
  g.fill(hc);
  g.rect(-2500, height, 10000, height*5);
  g.popMatrix();
}

void branch(PGraphics g, float len) {

  if (len > leafThresh) {

    g.stroke(0, 200);
    //stroke(colors[1]);
    float sw = map(len, 200, 4, 15, .1);
    //strokeWeight(sw);
    //line(0, 0, 0, -len);
    drawBranch(g, 0, 0, 0, -len, sw);
    g.translate(0, -len);

    len *= random(.5, .9);

    // TODO: all branches are same length here; FIX 
    g.pushMatrix();
    g.rotate(radians(-angle + map(noise(k), 0, 1, -10, 10)));
    branch(g, len);
    g.popMatrix();

    g.pushMatrix();
    g.rotate(radians(angle + map(noise(1000+k), 0, 1, -10, 10)));
    branch(g, len);
    g.popMatrix();

    if (random(1) < .4) {
      g.pushMatrix();
      g.rotate(radians(angle/2 + map(noise(1100+k), 0, 1, -10, 10)));
      branch(g, len);
      g.popMatrix();
    }
    return;
  }
  drawLeaf(g, len);
  if (firstBuild) leaves++;
}

void drawFlower(PGraphics g, float length) {

  // (mouseX/(float)width)*255);
  float len = length /2.0;
  for (int i = 0; i < 20; i++) {
    g.stroke(random(200, 255), random(180, 230));
    g.line(0, 0, 0, random(-len, len), random(-len, len), random(-len, len));
  }
}

void drawLeaf(PGraphics g, float len) {
  if (g.screenY(0, 0, 0) < treeH) {
    treeH = g.screenY(0, 0, 0);
  }
  if (len < leafThresh*.6) drawFlower(g, len); 

  g.noStroke();
  float b =random(100, 180);
  g.fill(b*.9, b*.45, b, 100);
  b =random(100, 255);
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
  //g.ellipse(0, 0, random(2, 5), random(10, 20));
  //g.text(random(1)>.5 ? '1':'0',0,0);//,random(2,5),random(10,20));
  //g.text('1',0,0);
}

void drawBranch(PGraphics g, float x1, float y1, float x2, float y2, float weight)
{
  //stroke(colors[1] & ~#000000 | round(map(weight, 0, 14, 120, 400)));
  g.stroke(noise(20), map(weight, 0, 14, 120, 400));
  g.strokeCap(ROUND);
  g.strokeWeight(weight);

  float twisti = 1 + (weight/24.0f);

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

void mouseWheel(MouseEvent event) {
  z -= 10 * event.getCount();
}

void mouseClicked(MouseEvent evt) {
  reset();
  //if (evt != null && evt.getCount() == 2) {
}

void reset() {
  firstBuild = true;
  leaves = 0;
  treeH = height;
  rs = random(Integer.MAX_VALUE);
  xOff = random(-35, 35);
  rotZ = radians(random(-3, 3));
  bg = random(90, 120);
  hc = random(40, 60);
}

color[] getColors() {
  return new color[] {
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80), random(180, 220))
  };
}
