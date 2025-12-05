import processing.net.*;
Server server = null;
Client client = null;

PlanarNation[] nations = new PlanarNation[6];
PlanarNation nationA;
PlanarNation nationB;

Camera camera1;

Light light1;

Voices voices;

int qty_vertices = 32;

//================================================================

void setup() {

  fullScreen(P3D, 2);
  noCursor();

  //size(1920, 1080, P3D);

  noSmooth();
  pixelDensity(1);
  background(0);
  frameRate(30);

  server = new Server(this, 1337);

  camera1 = new Camera();
  light1 = new Light(new PVector(
    0.0, 0.0, 100.0
    ));

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

  camera1.update();

  light1.update();
  light1.light();

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

//================================================================
// Network Functions:
//----------------------------------------------------------------
// handleClient()
// Attempts to read messages from connected client
// If a connected client sends a decodable string, it's parsed as JSON

void handleClient() {
  try {
    client = server.available();
    if (client == null) return;

    String message = client.readString();
    if (message == null) return;

    JSONObject json = parseJSONObject(message);
    if (json == null) {
      println("JSONObject could not be parsed");
      return;
    }

    JSONObject response = processJSON(json);
    if (response == null) return;

    client.write(response.toString());
  }
  catch(Exception e) {
    println("Exception caught @ handleClient(): " + e);
    print(e.toString());
    client.stop();
    server.disconnect(client);
  }
}

//----------------------------------------------------------------
// processJSON()
// For now, there's just a basic check to see if it's a request for frame data.
// If so, then grab the pixel data and return it

JSONObject processJSON(JSONObject json) {
  try {
    String type = json.getString("type");
    String parameter = json.getString("parameter");
    if (type.equals("get") && parameter.equals("frames")) {
      JSONObject response = new JSONObject();
      int frames = json.getInt("frame_count");
      int[] data = voices.getPixelData(pixels, frames);
      if (data == null) return null;
      JSONArray json_data = new JSONArray();
      for (int i = 0; i < frames; i++) {
        json_data.setInt(i, data[i]);
      }
      response.setJSONArray("data", json_data);
      return response;
    }
  }
  catch (Exception e) {
    println("Exception caught @ processJSON(): " + e);
  }
  return null;
}
