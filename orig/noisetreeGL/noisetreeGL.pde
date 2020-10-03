float k, rs, bg, xOff, rotZ;
float mult = .65, angle=24, z = -200; 
color[] colors;

void setup() {
  size(1920, 1080, OPENGL);
  mouseClicked(null);
}

void draw() {
  randomSeed((int)rs);

  background(bg);//, 200, 255);
  translate(0, 0, z);
  horizonLine();

  translate(width/2+xOff, height-100, -200);
  branch(random(200, 400));
  k += 0.01;
}

void horizonLine() {
  pushMatrix();
  translate(0, 0, -1000);
  rotateZ(rotZ);
  fill(random(90,120));
  rect(-2500, height, 10000, height*5);
  popMatrix();
}

void branch(float len) {

  if (len > 10) {

    stroke(0, 200);
    //stroke(colors[1]);
    float sw = map(len, 200, 4, 15, .1);
    //strokeWeight(sw);
    //line(0, 0, 0, -len);
    oline(0, 0, 0, -len, sw);
    translate(0, -len);

    len *= random(.5, .9);

    // TODO: all branches are same length here; FIX 
    pushMatrix();
    rotate(radians(-angle + map(noise(k), 0, 1, -10, 10)));
    branch(len);
    popMatrix();

    pushMatrix();
    rotate(radians(angle + map(noise(1000+k), 0, 1, -10, 10)));
    branch(len);
    popMatrix();

    if (random(1) < .4) {
      pushMatrix();
      rotate(radians(angle/2 + map(noise(1100+k), 0, 1, -10, 10)));
      branch(len);
      popMatrix();
    }
    return;
  } 
  drawLeaf(len);
}

void draw2DLeaf(float length) {

  // (mouseX/(float)width)*255);
  float len = length/2.0;
  for (int i = 0; i < 20; i++) {
    stroke(random(200, 255), random(180, 230));
    line(0, 0, 0, random(-len, len), random(-len, len), random(-len, len));
  }
}

void drawLeaf(float len) {
  if (len < 6) draw2DLeaf(len); 
  
  noStroke();
  float b =random(100, 180);
  fill(b*.9, b*.45, b, 100);
     b =random(100,255);
  fill(b*random(.1,.2), b*random(.6,.8), b, 100);
  float sz = random(len, len*2); 
  beginShape();

  vertex(-sz, -sz, -sz);
  vertex( sz, -sz, -sz);
  vertex(   0, 0, sz);
  sz = random(2, 5);
  vertex( sz, -sz, -sz);
  vertex( sz, sz, -sz);
  vertex(   0, 0, sz);
  sz = random(2, 5);
  vertex( sz, sz, -sz);
  vertex(-sz, sz, -sz);
  vertex(   0, 0, sz);
  sz = random(2, 5);
  vertex(-sz, sz, -sz);
  vertex(-sz, -sz, -sz);
  vertex(   0, 0, sz);
  endShape();
  //ellipse(0, 0, random(2, 5), random(10, 20));
  //text(random(1)>.5 ? '1':'0',0,0);//,random(2,5),random(10,20));
  //text('1',0,0);
}

void oline(float x1, float y1, float x2, float y2, float weight)
{
  //stroke(colors[1] & ~#000000 | round(map(weight, 0, 14, 120, 400)));
  stroke(noise(20), map(weight, 0, 14, 120, 400));
  strokeCap(ROUND);
  strokeWeight(weight);

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
    line(tx1, ty1, tx2, ty2);
    twist2[i + 1] = twist;
  }
}

void mouseWheel(MouseEvent event) {
  z -= 10 * event.getCount();
}

void mouseClicked(MouseEvent evt) {
  //if (evt != null && evt.getCount() == 2) {
  //  println(colors[0]+","+colors[2]+",");
  //}

  rs = random(Integer.MAX_VALUE);
  //colors = getColors();
  xOff = random(-15, 15);
  rotZ = radians(random(-3, 3));
  bg = random(50,70);
}

color[] getColors() {
  return new color[] {
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80)), 
    color(random(255), random(80), random(80), random(180, 220))
  };
}
