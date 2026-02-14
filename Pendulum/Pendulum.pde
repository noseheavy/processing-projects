// Double Pendulum
// Siwoo Kim

// using the Runge-Kutta algorithm

// note: need to implement proper
// solution of ode system instead

float g = 9.81 * 100;
float slowdown = 50;

float theta1    = random(-PI, PI);
float theta2    = random(-PI, PI);
float thetaDot1 = random(-PI, PI);
float thetaDot2 = random(-PI, PI);
float l1 = 100;
float l2 = 100;
float m1 = 1;
float m2 = 1;

boolean avail  = false;
boolean toggle = false;

PGraphics bg, pg, mg;
PVector p1, p2, p3, prev;

void setup() {
  prev = new PVector(0, 0);
  p1 = new PVector(
    (width - 1)/2, (height - 1)/2
  );
  p2 = new PVector(0, 0);
  p3 = new PVector(0, 0);
  
  size(512, 512);
  bg = createGraphics(width, height);
  mg = createGraphics(width, height);
  pg = createGraphics(width, height);
  
  pg.beginDraw();
  pg.background(0, 0);
  pg.endDraw();
}

void draw() {
  // calculate p2 and p3
  p2.x = p1.x + l1 * sin(theta1);
  p2.y = p1.y + l1 * cos(theta1);
  p3.x = p2.x + l2 * sin(theta2);
  p3.y = p2.y + l2 * cos(theta2);
  
  // draw
  bg.beginDraw();
  bg.background(255);
  bg.fill(0);
  bg.textAlign(LEFT, TOP);
  bg.text(frameRate, 0, 0);
  bg.endDraw();
  
  mg.beginDraw();
  mg.stroke(0);
  mg.strokeWeight(5);
  mg.background(255, 0);
  mg.fill(0, 0, 255);
  mg.line(p1.x, p1.y, p2.x, p2.y);
  mg.line(p2.x, p2.y, p3.x, p3.y);
  mg.circle(p2.x, p2.y, 25);
  mg.circle(p3.x, p3.y, 25);
  mg.endDraw();
  
  pg.beginDraw();
  pg.stroke(200);
  pg.strokeWeight(5);
  if (!avail) {
    pg.point(p3.x, p3.y);
    avail = true;
  } else {
    pg.line(p3.x, p3.y, prev.x, prev.y);
  }
  prev.x = p3.x;
  prev.y = p3.y;
  pg.endDraw();
  
  image(bg, 0, 0);
  if (toggle) image(pg, 0, 0);
  image(mg, 0, 0);
  
  // update simulation
  update(
    (1 - slowdown/100)/frameRate
  );
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    pg.beginDraw();
    pg.background(0, 0);
    pg.endDraw();
  } else if (key == 't' || key == 'T') {
    toggle = !toggle;
  } else if (key == 'r' || key == 'R') {
    theta1    = random(-PI, PI);
    theta2    = random(-PI, PI);
    thetaDot1 = random(-PI, PI);
    thetaDot2 = random(-PI, PI);
    // l1 = random(1, 100);
    // l2 = random(1, 100);
  }
}

void update(float h) {
  float[] dthetas1    = new float[4];
  float[] dthetas2    = new float[4];
  float[] dthetaDots1 = new float[4];
  float[] dthetaDots2 = new float[4];
  
  float num;
  float denom;

  // compute a
  dthetas1[0] = thetaDot1;
  dthetas2[0] = thetaDot2;
  
  num   = -g * (2 * m1 + m2) * sin(theta1) - m2 * g * sin(theta1 - 2 * theta2) - 2 * sin(theta1 - theta2) * m2 * (thetaDot2 * thetaDot2 * l2 + thetaDot1 * thetaDot1 * l1 * cos(theta1 - theta2));
  denom = l1 * (2 * m1 + m2 - m2 * cos(2 * theta1 - 2 * theta2));
  dthetaDots1[0] = num/denom;
  num   = 2 * sin(theta1 - theta2) * (thetaDot1 * thetaDot1 * l1 * (m1 + m2) + g * (m1 + m2) * cos(theta1) + thetaDot2 * thetaDot2 * l2 * m2 * cos((theta1 - theta2)));
  denom = l2 * (2 * m1 + m2 - m2 * cos(2 * theta1 - 2 * theta2));
  dthetaDots2[0] = num/denom;
  
  // compute b
  dthetas1[1] = thetaDot1 + (h/2) * dthetaDots1[0];
  dthetas2[1] = thetaDot2 + (h/2) * dthetaDots2[0];
  
  num   = -g*(2*m1+m2)*sin(theta1+(h/2)*dthetas1[0])-m2*g*sin((theta1+(h/2)*dthetas1[0])-2*(theta2+(h/2)*dthetas2[0]))-2*sin((theta1+(h/2)*dthetas1[0])-(theta2+(h/2)*dthetas2[0]))*m2*((thetaDot2+(h/2)*dthetaDots2[0])*(thetaDot2+(h/2)*dthetaDots2[0])*l2+(thetaDot1+(h/2)*dthetaDots1[0])*(thetaDot1+(h/2)*dthetaDots1[0])*l1*cos((theta1+(h/2)*dthetas1[0])-(theta2+(h/2)*dthetas2[0])));
  denom = l1*(2*m1+m2-m2*cos(2*(theta1+(h/2)*dthetas1[0])-2*(theta2+(h/2)*dthetas2[0])));
  dthetaDots1[1] = num/denom;
  num   = 2*sin((theta1+(h/2)*dthetas1[0])-(theta2+(h/2)*dthetas2[0]))*((thetaDot1+(h/2)*dthetaDots1[0])*(thetaDot1+(h/2)*dthetaDots1[0])*l1*(m1+m2)+g*(m1+m2)*cos(theta1+(h/2)*dthetas1[0])+(thetaDot2+(h/2)*dthetaDots2[0])*(thetaDot2+(h/2)*dthetaDots2[0])*l2*m2*cos(((theta1+(h/2)*dthetas1[0])-(theta2+(h/2)*dthetas2[0]))));
  denom = l2*(2*m1+m2-m2*cos(2*(theta1+(h/2)*dthetas1[0])-2*(theta2+(h/2)*dthetas2[0])));
  dthetaDots2[1] = num/denom;
  
  // compute c
  dthetas1[2] = thetaDot1 + (h/2) * dthetaDots1[1];
  dthetas2[2] = thetaDot2 + (h/2) * dthetaDots2[1];
  
  num   = -g*(2*m1+m2)*sin(theta1+(h/2)*dthetas1[1])-m2*g*sin((theta1+(h/2)*dthetas1[1])-2*(theta2+(h/2)*dthetas2[1]))-2*sin((theta1+(h/2)*dthetas1[1])-(theta2+(h/2)*dthetas2[1]))*m2*((thetaDot2+(h/2)*dthetaDots2[1])*(thetaDot2+(h/2)*dthetaDots2[1])*l2+(thetaDot1+(h/2)*dthetaDots1[1])*(thetaDot1+(h/2)*dthetaDots1[1])*l1*cos((theta1+(h/2)*dthetas1[1])-(theta2+(h/2)*dthetas2[1])));
  denom = l1*(2*m1+m2-m2*cos(2*(theta1+(h/2)*dthetas1[1])-2*(theta2+(h/2)*dthetas2[1])));
  dthetaDots1[2] = num/denom;
  num   = 2*sin((theta1+(h/2)*dthetas1[1])-(theta2+(h/2)*dthetas2[1]))*((thetaDot1+(h/2)*dthetaDots1[1])*(thetaDot1+(h/2)*dthetaDots1[1])*l1*(m1+m2)+g*(m1+m2)*cos(theta1+(h/2)*dthetas1[1])+(thetaDot2+(h/2)*dthetaDots2[1])*(thetaDot2+(h/2)*dthetaDots2[1])*l2*m2*cos(((theta1+(h/2)*dthetas1[1])-(theta2+(h/2)*dthetas2[1]))));
  denom = l2*(2*m1+m2-m2*cos(2*(theta1+(h/2)*dthetas1[1])-2*(theta2+(h/2)*dthetas2[1])));
  dthetaDots2[2] = num/denom;
  
  // compute d
  dthetas1[3] = thetaDot1 + h * dthetaDots1[2];
  dthetas2[3] = thetaDot2 + h * dthetaDots2[2];
  
  num   = -g*(2*m1+m2)*sin(theta1+h*dthetas1[2])-m2*g*sin((theta1+h*dthetas1[2])-2*(theta2+h*dthetas2[2]))-2*sin((theta1+h*dthetas1[2])-(theta2+h*dthetas2[2]))*m2*((thetaDot2+h*dthetaDots2[2])*(thetaDot2+h*dthetaDots2[2])*l2+(thetaDot1+h*dthetaDots1[2])*(thetaDot1+h*dthetaDots1[2])*l1*cos((theta1+h*dthetas1[2])-(theta2+h*dthetas2[2])));
  denom = l1*(2*m1+m2-m2*cos(2*(theta1+h*dthetas1[2])-2*(theta2+h*dthetas2[2])));
  dthetaDots1[3] = num/denom;
  num   = 2*sin((theta1+h*dthetas1[2])-(theta2+h*dthetas2[2]))*((thetaDot1+h*dthetaDots1[2])*(thetaDot1+h*dthetaDots1[2])*l1*(m1+m2)+g*(m1+m2)*cos(theta1+h*dthetas1[2])+(thetaDot2+h*dthetaDots2[2])*(thetaDot2+h*dthetaDots2[2])*l2*m2*cos(((theta1+h*dthetas1[2])-(theta2+h*dthetas2[2]))));
  denom = l2*(2*m1+m2-m2*cos(2*(theta1+h*dthetas1[2])-2*(theta2+h*dthetas2[2])));
  dthetaDots2[3] = num/denom;
  
  // update y
  theta1    += h/6 * (dthetas1[0] + 2 * dthetas1[1] + 2 * dthetas1[2] + dthetas1[3]);
  theta2    += h/6 * (dthetas2[0] + 2 * dthetas2[1] + 2 * dthetas2[2] + dthetas2[3]);
  thetaDot1 += h/6 * (dthetaDots1[0] + 2 * dthetaDots1[1] + 2 * dthetaDots1[2] + dthetaDots1[3]);
  thetaDot2 += h/6 * (dthetaDots2[0] + 2 * dthetaDots2[1] + 2 * dthetaDots2[2] + dthetaDots2[3]);
}
