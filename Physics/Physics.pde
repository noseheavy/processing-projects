//
//   Physics
//
//   Impulse Resolution
//
//   Siwoo Kim 2019
//

// constants
final int BALLS = 5;
final int AABBS = 6;
final int FPS   = 60;
final int STEPS = 1000; // per second

final int COUNT       = 4 + BALLS + AABBS;
final int STEPS_PER_F = STEPS/FPS;

final float g = 9.81f * 10.0f;
final float correction = 0.5f; // max fraction of correction from collision depth
final boolean showCollisions = false; 

// variables
float scale = 5.11; // to max coords

// objects
Object[] objects;
Collision collisionCont;
PGraphics main;

// initialization
void setup() {
  println("Steps per second specified: " + STEPS);
  println("Steps per frame: " + STEPS_PER_F);
  println("Actual steps per second: " + STEPS_PER_F * FPS);
  
  objects = new Object[COUNT]; // generate array
  collisionCont = new Collision(); // collision container for resolution
  
  Material wall = new Material(0, 0.8, 1); 
  Material obj  = new Material(1, 0.8, 1);
  
  // walls
  objects[0] = new Object(wall, new Vector2(0, 0), new Vector2(100, 10));
  objects[1] = new Object(wall, new Vector2(0, 10), new Vector2(10, 90));
  objects[2] = new Object(wall, new Vector2(90, 10), new Vector2(100, 90));
  objects[3] = new Object(wall, new Vector2(0, 90), new Vector2(100, 100));
  objects[1].velocity = new Vector2(0, 0);
  objects[2].velocity = new Vector2(0, 0);
  
  // objects
  for (int i = 4; i < 4 + BALLS; i++) { // 4 for walls
    objects[i] = new Object(obj, new Vector2(random(20, 80), random(20, 80)), random(1, 10));
    objects[i].velocity = new Vector2(random(-50, 50), random(-50, 50));
  }
  for (int i = 4 + BALLS; i < COUNT; i++) {
    Vector2 min = new Vector2(random(10, 70), random(10, 70));
    Vector2 max = new Vector2(random(min.x + 1, min.x + 20), random(min.y + 1, min.y + 20));
    objects[i] = new Object(obj, min, max);
    objects[i].velocity = new Vector2(random(-50, 50), random(-50, 50));
  }
  
  size(512, 512);
  main = createGraphics(512, 512);
}

// main loop
void draw() {
  // input
  
  // update physics
  for (int s = 0; s < STEPS_PER_F; s++) {
    // collision detection & resolution
    for (int o1 = 0; o1 < COUNT; o1++) { // iterate through objects
      switch (objects[o1].shape.type) {
        case 0: // AABB
          for (int o2 = 0; o2 < COUNT; o2++) { // iterate through other objects
            if (o2 != o1) {
              switch (objects[o2].shape.type) {
                case 0: // AABB with AABB
                  collisionCont = collisionCont.AABBToAABB(objects[o1].shape, objects[o2].shape); 
                  break;
                case 1: // AABB with circle
                  collisionCont = collisionCont.AABBToCircle(objects[o1].shape, objects[o2].shape);
                  break;
              }
              
              if (collisionCont.collided) {
                collisionCont.resolve(objects[o1], objects[o2], collisionCont);
              }
            } // if (o2 != o1) {
          }
          break;
        case 1: // circle
          for (int o2 = 0; o2 < COUNT; o2++) { // iterate through other objects
            if (o2 != o1) {
              switch (objects[o2].shape.type) {
                  case 0: // circle with AABB
                    // note the flipping
                    collisionCont = collisionCont.AABBToCircle(objects[o2].shape, objects[o1].shape);
                    
                    if (collisionCont.collided) {
                      collisionCont.normal = collisionCont.normal.scale(-1.0f);
                    }
                    break;
                  case 1: // circle with circle
                    collisionCont = collisionCont.circleToCircle(objects[o1].shape, objects[o2].shape);
                    break;
                }
                
                if (collisionCont.collided) {
                  collisionCont.resolve(objects[o1], objects[o2], collisionCont);
                }
            } // if (o2 != o1) {
          }
          break;
      }
    }
    
    // acceleration & position updates
    for (int i = 0; i < COUNT; i++) {
      switch (objects[i].shape.type) {
        case 0:
          if (objects[i].mass != 0) { // do not accelerate objects with infinite mass
            objects[i].velocity = objects[i].velocity.add(new Vector2(0, -g).scale(1f/(60f * STEPS_PER_F)));
          }
          objects[i].shape.min = objects[i].shape.min.add(objects[i].velocity.scale(1f/(60f * STEPS_PER_F)));
          objects[i].shape.max = objects[i].shape.max.add(objects[i].velocity.scale(1f/(60f * STEPS_PER_F)));
          break;
        case 1:
          if (objects[i].mass != 0) { // do not accelerate objects with infinite mass
            objects[i].velocity = objects[i].velocity.add(new Vector2(0, -g).scale(1f/(60f * STEPS_PER_F)));
          }
          objects[i].shape.pos = objects[i].shape.pos.add(objects[i].velocity.scale(1f/(60f * STEPS_PER_F)));
          break;
      }
    }
  }
  
  // graphics
  main.beginDraw();
  main.background(255);
  main.stroke(0);
  main.noFill();
  for (int i = 0; i < COUNT; i++) {
    drawObject(scale, main, objects[i]);
  }
  
  float kinetic = 0.0f;
  for (int i = 0; i < COUNT; i++) {
    kinetic += 1.0f/2.0f * objects[i].mass * objects[i].velocity.dot(objects[i].velocity);
  }
  float potential = 0.0f; // measured 0 at floor
  for (int i = 0; i < COUNT; i++) {
    switch (objects[i].shape.type) {
      case 0: // AABB
        potential += objects[i].mass * g * (objects[i].shape.min.y - 10);
        break;
      case 1: // circle
        potential += objects[i].mass * g * (objects[i].shape.pos.y - objects[i].shape.radius - 10);
        break;
    }
  }
  main.textAlign(LEFT, TOP);
  main.textSize(14);
  main.fill(0);
  main.text(" ke: " + round(kinetic) + ", pe: " + ((potential > 0)? round(potential) : 0) + ", total: " + ((potential > 0)? round(potential + kinetic) : round(kinetic)), 0, 2);
  // main.text(frameRate, 2, 2);
  main.endDraw();
  image(main, 0, 0);
}

void keyPressed() {
  setup();
}

// graphics functions
Vector2 worldToImage(float s, Vector2 v) {
  return new Vector2(s * v.x, (height - 1) - s * v.y);
}
void drawObject(float s, PGraphics pg, Object obj) {
  switch (obj.shape.type) {
    case 0: // AABB
      Vector2 min = worldToImage(s, obj.shape.min);
      Vector2 max = worldToImage(s, obj.shape.max);
      pg.line(min.x, min.y, max.x, min.y);
      pg.line(min.x, max.y, max.x, max.y);
      pg.line(min.x, min.y, min.x, max.y);
      pg.line(max.x, min.y, max.x, max.y);
      break;
    case 1: // circle
      Vector2 pos = worldToImage(s, obj.shape.pos);
      pg.circle(pos.x, pos.y, 2 * s * obj.shape.radius);
      break;
  }
}
