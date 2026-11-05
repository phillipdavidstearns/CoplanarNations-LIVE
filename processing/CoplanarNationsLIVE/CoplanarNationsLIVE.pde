import processing.net.*;
Server server = null;
Client client = null;

PlanarNation[] nations = new PlanarNation[6];
PlanarNation nationA;
PlanarNation nationB;

Voices voices;
Cameras cameras;
Lights lights;

int qty_vertices = 32;
float[][] verts = generateVertices(qty_vertices);

//================================================================

void setup() {

  //----------------------------------------------------------------
  // Environmental settings

  fullScreen(P3D, 2);
  noCursor();
  noSmooth();
  pixelDensity(1);
  background(0);
  frameRate(30);

  //----------------------------------------------------------------

  server = new Server(this, 1337);

  //set up the camera object
  cameras = new Cameras(4);

  //setup the light object
  lights = new Lights(1);

  nations[0] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_Sudan.png")
    );

  nations[1] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_SPLM-N.png")
    );

  nations[2] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_Russia.png")
    );

  nations[3] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_Ukraine.png")
    );

  nations[4] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_Israel.png")
    );

  nations[5] = new PlanarNation(
    qty_vertices,
    loadImage("Flag_of_Palestine.png")
    );

  populate_notes();
  //start off with 0 voices. press = to add one at a time, - to subtract
  voices = new Voices(1, B_locrian);

  nationA = nations[0];
  nationB = nations[1];

  noiseDetail(1, 1.0);
}

//================================================================

void draw() {
  background(0);

  cameras.update();
  lights.update();

  nationA.update();
  nationA.render();

  nationB.update();
  nationB.render();

  fill(255);

  loadPixels();
  handleClient();
  voices.render(pixels);
  voices.update();
  updatePixels();
}
