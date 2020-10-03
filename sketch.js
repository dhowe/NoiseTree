let k = 0, rs = 0, mult = .65, angle=24;

// TODO: display max-height, leaf-count -> reject too short/tall, too many/few leaves
//       handle 3rd branchs (max 1 per level, never in a (center?) child)
function setup() {
  createCanvas(1100,700);
  mouseClicked();
}

function draw() {
  randomSeed(rs);
  //background(0,200,255);
  background('#00C9DE');
  translate(width/2+xoff, height);
  // translate(0, height / 2); //GL
  branch(130);
  k += 0.01;
}

function branch(len) {

  if (len > 4) {

    stroke(0,200);
    let sw = map(len, 200, 4, 20, .1);
    oline(0, 0, 0, -len, sw);
    translate(0, -len);

    len *= random(.5,.9);

    push();
    rotate(radians(-angle + map(noise(k),0,1,-10,10)));
    branch(len);
    pop();

    push();
    rotate(radians(angle + map(noise(1000+k),0,1,-10,10)));
    branch(len);
    pop();

    if (random(1) < .5) {
      push();
      rotate(radians(angle/2 + map(noise(1100+k),0,1,-10,10)));
      branch(len);
      pop();
    }
  }
  else {
    noStroke();
    fill(random(100,255),0,0,32);
    ellipse(0,0,random(2,5),random(10,20));
    //text(random(1)>.5 ? '1':'0',0,0);//,random(2,5),random(10,20));
    //text('1',0,0);
  }
}

function mouseClicked() {
  xoff = random(-5, 5);
  rs = random(Number.MAX_SAFE_INTEGER);
}

function oline(x1, y1, x2, y2, weight)
{
  strokeCap(ROUND);
  strokeWeight(weight);

  let twisti = 1 + (weight/24.0);
  let xd = x2 - x1, yd = y2 - y1;
  let dist = sqrt(xd * xd + yd * yd);
  let sections = ceil(dist / 10.0);

  let twist, twist2 = new Array(sections + 1);
  for (let i = 0; i < twist2.length; i++) {
     twist2[i] = 0.0;
  }

  for (let i = 0; i < sections; i++)
  {
    twist = random(-twisti, twisti);
    let tx1 = x1 + ((xd / sections) * (i)) + twist2[i];
    let tx2 = x1 + ((xd / sections) * (i + 1)) + twist;
    let ty1 = y1 + ((yd / sections) * (i));
    let ty2 = y1 + ((yd / sections) * (i + 1));
    if (i == sections - 1)
    {
      tx2 = x2;
      ty2 = y2;
    }
    line(tx1, ty1, tx2, ty2);
    twist2[i + 1] = twist;
  }
}
