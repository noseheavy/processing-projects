class Collision {
  boolean collided;
  float   depth;
  Vector2 normal;
  
  // function to resolve detected collisions
  void resolve(Object object1, Object object2, Collision collision) {
    float restitution = (object1.material.restitution < object2.material.restitution)?
                        object1.material.restitution : object2.material.restitution; // minimum restitution is used
    float friction    = (object1.material.friction + object2.material.friction)/2; // assume collision friction is average
    
    float invMass1 = (object1.mass != 0)? 1/object1.mass : 0; 
    float invMass2 = (object2.mass != 0)? 1/object2.mass : 0;
    
    Vector2 relVel = object2.velocity.sub(object1.velocity);
    float relVelNormal = relVel.dot(collision.normal);
    
    if (relVelNormal > 0 || (invMass1 == 0 && invMass2 == 0)) {
      return; // no position correction if separating
    } 
    
    float num   = -(1 + restitution) * relVelNormal;
    float denom = invMass1 + invMass2;
    float jN    = num/denom;
    
    Vector2 tangent = relVel.sub(collision.normal.scale(relVelNormal));
    float magn = sqrt(tangent.dot(tangent));
    float k    = (magn == 0)? 0 : -1/magn;
    tangent = tangent.scale(k);
    
    num = -(1 + restitution) * relVel.dot(tangent);
    float jT = num/denom;
    
    // todo: friction model
    // currently objects bounce away from collision point following restitution
    // except clamping when chosen friction value exceeded?
    if (jT > friction) {
      jT = friction;
    }
    
    if (showCollisions) {
      println("\ncollided! depth: " + collision.depth +
              ", normal: " + collision.normal.x + ", " + collision.normal.y +
              ", tangent: " + tangent.x + ", " + tangent.y);
      println("jN: " + jN + " jT: " + jT);
      println("V1: " + object1.velocity.x, ", " + object1.velocity.y);
      println("V2: " + object2.velocity.x + ", " + object2.velocity.y);
    }
    
    Vector2 impulse = collision.normal.scale(jN).add(tangent.scale(jT));
    
    // effect on 2
    object2.velocity = object2.velocity.add(impulse.scale(invMass2));
    object1.velocity = object1.velocity.sub(impulse.scale(invMass1));
    
    if (showCollisions) {
      println("V1': " + object1.velocity.x + ", " + object1.velocity.y);
      println("V2': " + object2.velocity.x + ", " + object2.velocity.y);
    }
    
    // sinking/overlap correction
    // float iM1 = (invMass1 < 1 && invMass1 != 0)? 1 : invMass1;
    // float iM2 = (invMass2 < 1 && invMass2 != 0)? 1 : invMass2;
    float corrFac1 = invMass1/denom;
    float corrFac2 = invMass2/denom;
    
    switch (object2.shape.type) {
      case 0: // AABB
        object2.shape.min = object2.shape.min.add(
          collision.normal.scale(correction * corrFac2 * collision.depth)
        );
        object2.shape.max = object2.shape.max.add(
          collision.normal.scale(correction * corrFac2 * collision.depth)
        );
        break;
      case 1: // circle
        object2.shape.pos = object2.shape.pos.add(
          collision.normal.scale(correction * corrFac2 * collision.depth)
        );
        break;
    }
    switch (object1.shape.type) {
      case 0: // AABB
        object1.shape.min = object1.shape.min.sub(
          collision.normal.scale(correction * corrFac1 * collision.depth)
        );
        object1.shape.max = object1.shape.max.sub(
          collision.normal.scale(correction * corrFac1 * collision.depth)
        );
        break;
      case 1: // circle
        object1.shape.pos = object1.shape.pos.sub(
          collision.normal.scale(correction * corrFac1 * collision.depth)
        );
        break;
    }
    
    // non-physical impulse correction
    // tending to zero
    object2.velocity = object2.velocity.add(
      collision.normal.scale(correction * corrFac2 * collision.depth * collision.depth)
    );
    object1.velocity = object1.velocity.sub(
      collision.normal.scale(correction * corrFac1 * collision.depth * collision.depth)
    );
    
    return;
  }
  
  // collision detection functions
  Collision AABBToAABB(Shape shape1, Shape shape2) {
    Collision collision = new Collision();
    
    boolean left   = shape2.min.x <= shape1.min.x && shape1.min.x <= shape2.max.x;
    boolean right  = shape2.max.x >= shape1.max.x && shape1.max.x >= shape2.min.x;
    boolean top    = shape2.max.y >= shape1.max.y && shape1.max.y >= shape2.min.y;
    boolean bottom = shape2.min.y <= shape1.min.y && shape1.min.y <= shape2.max.y;
    
    float leftDist   = 9999;
    float rightDist  = 9999;
    float topDist    = 9999;
    float bottomDist = 9999;
    
    if ((left || right) && (top || bottom)) {
      collision.collided = true;
      
      if (left) {
        leftDist = shape2.max.x - shape1.min.x;
      }
      if (right) {
        rightDist = shape1.max.x - shape2.min.x;
      }
      if (top) {
        topDist = shape1.max.y - shape2.min.y;
      }
      if (bottom) {
        bottomDist = shape2.max.y - shape1.min.y;
      }
      
      if (leftDist < rightDist && leftDist < topDist && leftDist < bottomDist) {
        collision.depth = leftDist;
        collision.normal = new Vector2(-1, 0);
        // println("left");
      } else if (rightDist < leftDist && rightDist < topDist && rightDist < bottomDist) {
        collision.depth = rightDist;
        collision.normal = new Vector2(1, 0);
        // println("right");
      } else if (topDist < leftDist && topDist < rightDist && topDist < bottomDist) {
        collision.depth = topDist;
        collision.normal = new Vector2(0, 1);
        // println("top");
      } else {
        collision.depth = bottomDist;
        collision.normal = new Vector2(0, -1);
        // println("bottom");
      }
    } else {
      collision.collided = false;
    }
    
    return collision;
  }
  Collision AABBToCircle(Shape shape1, Shape shape2) {
    Collision collision = new Collision();
    
    boolean left   = shape2.pos.x < shape1.min.x;
    boolean right  = shape2.pos.x > shape1.max.x;
    boolean top    = shape2.pos.y > shape1.max.y;
    boolean bottom = shape2.pos.y < shape1.min.y;
    
    collision.collided = false;
    
    if ((left || right) && (top || bottom)) { // corners
      Vector2 closest = shape2.pos.sub(shape1.min.add(shape1.max).scale(0.5));
      if (left) {
        closest.x = shape1.min.x;
      } else {
        closest.x = shape1.max.x;
      }
      if (top) {
        closest.y = shape1.max.y;
      } else {
        closest.y = shape1.min.y;
      }
      
      Vector2 dist = shape2.pos.sub(closest);
      float squaredDist = dist.dot(dist);
      
      if (squaredDist < shape2.radius * shape2.radius) {
        collision.collided = true;
        
        collision.normal = dist;
        float magn = sqrt(squaredDist);
        collision.normal = collision.normal.scale(1.0f/magn);
        
        collision.depth = shape2.radius - magn;
      }
    } else { // sides
      if (left) {
        if (shape1.min.x - shape2.pos.x < shape2.radius) {
          collision.collided = true;
          collision.depth = shape2.radius - shape1.min.x + shape2.pos.x;
          collision.normal = new Vector2(-1, 0);
        }
      } else if (right) {
        if (shape2.pos.x - shape1.max.x < shape2.radius) {
          collision.collided = true;
          collision.depth = shape2.radius - shape2.pos.x + shape1.max.x;
          collision.normal = new Vector2(1, 0);
        }
      } else if (top) {
        if (shape2.pos.y - shape1.max.y < shape2.radius) {
          collision.collided = true;
          collision.depth = shape2.radius - shape2.pos.y + shape1.max.y;
          collision.normal = new Vector2(0, 1);
        }
      } else {
        if (shape1.min.y - shape2.pos.y < shape2.radius) {
          collision.collided = true;
          collision.depth = shape2.radius - shape1.min.y + shape2.pos.y;
          collision.normal = new Vector2(0, -1);
        }
      }
    }
    
    return collision;
  }
  Collision circleToCircle(Shape shape1, Shape shape2) {
    Collision collision = new Collision();
    
    Vector2 dist = shape2.pos.sub(shape1.pos);
    float squaredDist = dist.dot(dist);
    
    if (squaredDist < (shape1.radius + shape2.radius) * (shape1.radius + shape2.radius)) {
      collision.collided = true;
      
      collision.normal = dist;
      float magnitude = sqrt(squaredDist);
      collision.normal = collision.normal.scale(1.0f/magnitude);
      
      collision.depth = shape1.radius + shape2.radius - magnitude;
    } else {
      collision.collided = false;
    }
    
    return collision;
  }
}
