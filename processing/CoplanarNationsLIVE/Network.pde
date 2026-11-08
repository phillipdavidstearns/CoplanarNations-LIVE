//================================================================
// Network Functions:
//----------------------------------------------------------------
// handleClient()
// Attempts to read messages from connected client
// If a connected client sends a decodable string, it's parsed as JSON

void handleClient() {
  String message;
  JSONObject json = null;
  byte[] response;

  try {
    client = server.available();
    if (client == null) return;

    // read in strings until there's nothing left
    while (client.available() > 0) {

      message = client.readString();

      if (message != null) {

        json = parseJSONObject(message);

        if (json == null) {
          println("JSONObject could not be parsed");
          return;
        }

        response = processJSON(json);

        if (response != null) client.write(response);
      }
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
    return voices.getPixelData(json.getInt("frame_count"));
  }
  catch (Exception e) {
    println("Exception caught @ processJSON(): " + e);
  }

  return null;
}
