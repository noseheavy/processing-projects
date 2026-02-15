public class Object {
  public float mass;
  public Material material;
  public Shape    shape;
  public Vector2  velocity;
  
  public Object(Material mat, Vector2 min, Vector2 max) {
    material = mat;
    shape    = new Shape(min, max);
    velocity = new Vector2(0, 0);
    mass = (max.x - min.x) * (max.y - min.y) * material.density;
  }
  public Object(Material mat, Vector2 pos, float rad) {
    material = mat;
    shape    = new Shape(pos, rad);
    velocity = new Vector2(0, 0);
    mass = PI * rad * rad * material.density;
  }
}
