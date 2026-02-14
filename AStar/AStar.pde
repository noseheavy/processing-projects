//
//  A*
//
//  Siwoo Kim 2019
//

final int CELLS     = 32;
final int SIZE      = 512;
final int SIZE_CELL = SIZE/CELLS;

final int[][] DIST_DIFF = {
  {14, 10, 14},
  {10, 0,  10},
  {14, 10, 14}
};
final int[][] BAR_MAP = {
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};

PGraphics graphics;
Node[][] nodeMap = new Node[CELLS][CELLS];

void setup() {
  for (int i = 0; i < CELLS; i++) {
    for (int j = 0; j < CELLS; j++) {
      nodeMap[i][j] = new Node();
      
      nodeMap[i][j].x = i;
      nodeMap[i][j].y = j;
      
      if (BAR_MAP[j][i] == 1) {
        nodeMap[i][j].isBarrier = true; 
      }
    }
  }
  
  size(512, 512);
  graphics = createGraphics(width, height);
}

void draw() {
  boolean found = findPath(nodeMap, 0,  9,
                                    19, 18);
  Node[] path = generatePath(nodeMap[0][9]); // trace back from dest
  
  graphics.beginDraw();
  for (int i = 0; i < CELLS; i++) {
    for (int j = 0; j < CELLS; j++) {
      drawCell(
        graphics, i, j,
        (nodeMap[i][j].isBarrier)?                 #000000 :
        (nodeMap[i][j].status == Status.ACTIVE)?   #AAFFAA :
        (nodeMap[i][j].status == Status.INACTIVE)? #FFAAAA :
                                                   #FFFFFF
      );
    }
  }
  
  for (int i = 0; i < path.length; i++) {
    drawCell(graphics, path[i].x, path[i].y, #AAAAFF);
  }
  graphics.endDraw();
  image(graphics, 0, 0);
}

void keyPressed() {
  setup();
}

// go to active min val pos->check surrounding->deactivate
boolean findPath(Node[][] map, int destX, int destY, int srcX, int srcY) {
  // clear grid
  for (int i = 0; i < CELLS; i++) {
    for (int j = 0; j < CELLS; j++) {
      map[i][j].src    = null;
      map[i][j].status = Status.EMPTY;
    }
  }
  
  // starting point
  map[srcX][srcY].status  = Status.ACTIVE;
  map[srcX][srcY].distSrc = 0;
  map[srcX][srcY].val     = 0; // unused as deactivated
  
  boolean foundActive = true;
  boolean foundPath   = false;
  
  while (foundActive && !foundPath) {
    foundActive = false;
    
    // overwritten by first search result
    int minVal = 0;
    int minI = 0;
    int minJ = 0;
    
    for (int i = 0; i < CELLS; i++) {
      for (int j = 0; j < CELLS; j++) {
        if (map[i][j].status == Status.ACTIVE) {
          if (!foundActive) {
            foundActive = true;
            
            minVal = map[i][j].val;
            minI = i;
            minJ = j;
          } else if (map[i][j].val < minVal) {
            minVal = map[i][j].val;
            minI = i;
            minJ = j;
          }
        }
      }
    }
    
    if (foundActive) {
      for (int i = (minI == 0)? 0 : -1; i <= ((minI == CELLS - 1)? 0 : 1); i++) {
        for (int j = (minJ == 0)? 0 : -1; j <= ((minJ == CELLS - 1)? 0 : 1); j++) {
          if (i != 0 || j != 0) { // surrounding only
            if (minI + i == destX && minJ + j == destY) {
              foundPath = true;
              
              map[minI + i][minJ + j].src = map[minI][minJ];
            } else {
              updateNode(map, destX, destY,
                         minI + i, minJ + j,
                         map[minI][minJ].distSrc + DIST_DIFF[i + 1][j + 1], // accumulation
                         map[minI][minJ]);
            }
          }
        }
      }
      
      map[minI][minJ].status = Status.INACTIVE;
    }
  }
  
  return foundPath;
}
void updateNode(Node[][] map, int destX, int destY, int x, int y, int distSrc, Node src) {
  if (!map[x][y].isBarrier) {
    if (map[x][y].status == Status.EMPTY) { // first visit
      map[x][y].status = Status.ACTIVE;
      map[x][y].src    = src;
      
      map[x][y].distSrc  = distSrc; // accumulated...
      map[x][y].distDest = 10 * (abs(destX - x) + abs(destY - y)); // taxicab
      // map[x][y].distDest = int(10 * sqrt((destX - x) * (destX - x) + (destY - y) * (destY - y)));
      map[x][y].val = map[x][y].distSrc + map[x][y].distDest; // *
    } else if (map[x][y].status == Status.ACTIVE) {
      if (distSrc < map[x][y].distSrc) { // only need to check half of expr
        map[x][y].src = src;
        
        map[x][y].distSrc = distSrc;
        // distDest alerady set
        map[x][y].val = map[x][y].distSrc + map[x][y].distDest; // *
      }
    }
  }
}

// reconstruct chained path
Node[] generatePath(Node dest) {
  int len = 0;
  
  Node[] list = new Node[0];
  Node node   = dest;
  
  do {
    Node[] newList = new Node[len + 1];
    for (int i = 0; i < len; i++) {
      newList[i] = list[i];
    }
    newList[len] = node;
    
    list = newList;
    len++;
    
    // next entry will be src of curr
    node = node.src;
  } while (node != null); // cont if avilable
  
  return list;
}

void drawCell(PGraphics g, int x, int y, int col) {
  g.fill(col);
  g.rect(SIZE_CELL * x, SIZE_CELL * y, SIZE_CELL - 1, SIZE_CELL - 1);
}
