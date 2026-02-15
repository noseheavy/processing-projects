// wave simulation
// siwoo kim 2020

/*

  the wave equation is defined as
  
    d^2u
    ---- = c^2 nabla^2u,
    dt^2
    
  which can be simplified to
  
    d^2u       d^2u
    ---- = c^2 ----
    dt^2       dx^2
    
  for the special case of a 
  simple one-dimensional wave.
  
*/

// configuration
// wave speed
final double C = 511.0;
// dampening factor per sec
final double D = 2.5;
// harmonic number
final int N = 5;
// time scale
final double TIME_SCALE = 1.0;
// sub steps
final int SUB_STEPS = 2000;

// pre-caculated values
final double DT = 1.0 / 60.0 / SUB_STEPS * TIME_SCALE; 
final double DX = 1.0;
final double CS = C * C;

// types
enum end_t {
  FIXED,
  FREE
}

// variables
int grab  = 0;
int start = 0;
boolean oscillate = false;
double[] u, v;

end_t t = end_t.FIXED;

// initialization
void setup() {  
  // display
  size(512, 512);
  frameRate(60);
  
  // list of u(x)
  u = new double[width];
  // list of (du/dt)(x)
  v = new double[width];
}

// main loop
void draw() {
  // calculations
  for (int s = 0; s < SUB_STEPS; s++) {
    // apply boundary condition at left edge
    // 2 * 511/n = l
    // l/c = T
    // c/(2 * 511/n) = f
    if (oscillate) u[0] = 32 * sin((float)(
      TIME_SCALE * 2 * PI * (millis() - start)/1000.0 *
      C/(2 * 511/N)
    ));
  
    // iterate through middle
    for (int i = 1; i < width - 1; i++) {
      if (!(mousePressed && mouseButton == LEFT && i == grab)) {
        double d1 = (u[i] - u[i - 1])/DX;
        double d2 = (u[i + 1] - u[i])/DX;
        v[i] += DT * CS * (d2 - d1)/DX;
        v[i] *= 1.0 - DT * D;
        u[i] += DT * v[i];
      }
    }
    
    // free boundary condition for right edge
    if (t == end_t.FREE) {
      double d1 = (u[width - 1] - u[width - 2])/DX;
      double d2 = 0.0;
      v[width - 1] += DT * CS * (d2 - d1)/DX;
      v[width - 1] *= 1.0 - DT * D;
      u[width - 1] += DT * v[width - 1];
    } else {
      // apply fixed boundary condition at right edge
      u[width - 1] = 0;
    }
  }
  
  // graphics
  background(0, 0, 0);
  stroke(color(255, 255, 255));
  fill(255, 255, 255);
  textSize(32);
  textAlign(LEFT, TOP);
  if (oscillate) {
    text("AUTO", 12, 6);
  }
  textAlign(RIGHT, TOP);
  if (t == end_t.FIXED) {
    text("FIXED", width - 12, 6);
  } else {
    text("FREE", width - 12, 6);
  }
  
  if (grab != 0) {
    circle(grab, mouseY, 8);
  }
  for (int i = 0; i < width - 1; i++) {
    if (i % 4 == 0) {
      set(i, height/2, color(255, 255, 255));
    }
  }
  for (int i = 0; i < width - 1; i++) {
    line(i,     height/2 - (int)u[i],
         i + 1, height/2 - (int)u[i + 1]);
  }
  
  // debug
  // println("fps: ", frameRate);
}

// input handling
void keyPressed() {
  if (key == 'o') {
    start = millis();
    
    oscillate = !oscillate;
  } else if (key == 'r') {
    for (int i = 0; i < width; i++) {
      u[i] = 0.0f;
      v[i] = 0.0f;
      
      oscillate = false;
    }
  } else if (key == 't') {
    if (t == end_t.FIXED) {
      t = end_t.FREE;
    } else {
      t = end_t.FIXED;
    }
  }
}
void mousePressed() {
  if (!oscillate &&
      mouseButton == LEFT &&
      mouseX != 0 && mouseX != width - 1) {
    grab = mouseX;
    
    u[grab] = height/2.0 - mouseY;
    v[grab] = 0;
  }
}
void mouseDragged() {
  if (grab != 0) {
    u[grab] = height/2.0 - mouseY;
    v[grab] = 0;
  }
}
void mouseReleased() {
  grab = 0;
}
