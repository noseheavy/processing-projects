public class Vector2 {
  public float x, y;
  
  public Vector2(float a, float b) {
    x = a;
    y = b;
  }
  
  public Vector2 add(Vector2 v) {
    return new Vector2(x + v.x, y + v.y);
  }
  public Vector2 sub(Vector2 v) {
    return new Vector2(x - v.x, y - v.y);
  }
  public Vector2 scale(float k) {
    return new Vector2(k * x, k * y);
  }
  public float dot(Vector2 v) {
    return x * v.x + y * v.y;
  }
  public float cross(Vector2 v) {
    return x * v.y - y * v.x;
  }
  
  // unused
  public Vector2 t(float[][] m) {
    return new Vector2(0, 0);
  }
  public boolean cmp(Vector2 v) {
    return abs(x/v.x - 1) < 0.001 && abs(y/v.y - 1) < 0.001;
  }
}
