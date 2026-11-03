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

    while (client.available() > 0) {
      String message = client.readString();
      if (message == null) return;

      JSONObject json = parseJSONObject(message);
      if (json == null) {
        println("JSONObject could not be parsed");
        return;
      }

      byte[] response = processJSON(json);
      if (response == null) return;

      client.write(response);
    }
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

byte[] processJSON(JSONObject json) {
  try {
    int frames = json.getInt("frame_count");

    byte[] pixelData = voices.getPixelData(pixels, frames);
    if (pixelData == null) return null;

    return pixelData;
  }
  catch (Exception e) {
    println("Exception caught @ processJSON(): " + e);
  }
  return null;
}
