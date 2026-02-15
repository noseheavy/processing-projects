public class Shape {
  byte type; // todo: enum
  
  float radius;
  Vector2 min, max;
  Vector2 pos;
  
  public Shape(Vector2 a, Vector2 b) {
    type = 0;
    
    min = new Vector2(a.x, a.y);
    max = new Vector2(b.x, b.y);
  }
  public Shape(Vector2 p, float r) {
    type = 1;
    
    radius = r;
    pos = new Vector2(p.x, p.y);
  }
}
