
boolean shift = false;
boolean ctrl = false;
boolean opt = false;
boolean cmd = false;

float rotation_step = PI/64.0;
float translation_step = 100;

int min_voices = 0;
int max_voices = 20;

float zMin = 0.0;
float zMax = -5000;

float x = 0.0;
float y = 0.0;
float z = 0.0;

Camera c;
//================================================================
// KEY RELEASED

void keyReleased() {
  //println("released keyCode:" + keyCode + ", key: " + key);

  //----------------------------------------------------------------
  // Detect when SHIFT, CTRL, CMD, or OPT are  released
  if (keyCode == 16) shift = false;
  if (keyCode == 17) ctrl = false;
  if (keyCode == 18) opt = false;
  if (keyCode == 157) cmd = false;
}

//================================================================
// KEY PRESSED


void keyPressed() {
  c = cameras.get_active_camera();
  //println("pressed keyCode:" + keyCode + ", key: " + key);

  //----------------------------------------------------------------
  // Detect when SHIFT, CTRL, CMD, or OPT are pressed
  if (keyCode == 16) shift = true;
  if (keyCode == 17) ctrl = true;
  if (keyCode == 18) opt = true;
  if (keyCode == 157) cmd = true;

  //================================================================
  // Detect non-character keys
  switch(keyCode) {

    //----------------------------------------------------------------
    // SPACE_BAR
  case 32:

    if (shift) {

      //turn off PlanarNation visibility
      nationA.render_edges = false;
      nationA.render_texture = false;

      nationB.render_edges = false;
      nationB.render_texture = false;

      // silence voices
      for (Voice v : voices.voices) {
        v.mute = true;
      }
    }

    //stop flickering and animation
    nationA.edge_flicker = false;
    nationA.texture_flicker = false;
    nationA.do_animate = false;

    nationB.edge_flicker = false;
    nationB.texture_flicker = false;
    nationB.do_animate = false;
    break;

    //----------------------------------------------------------------
    // LEFT_ARROW
  case 37:
    if (shift) {
      c.setRotationZ(c.rotation_target.z + rotation_step);
    } else {
      c.setRotationY(c.rotation_target.y + rotation_step);
    }
    break;

    //----------------------------------------------------------------
    // UP_ARROW
  case 38: // up
    c.setRotationX(c.rotation_target.x - rotation_step);
    break;

    //----------------------------------------------------------------
    // RIGHT_ARROW
  case 39: // right
    if (shift) {
      c.setRotationZ(c.rotation_target.z - rotation_step);
    } else {
      c.setRotationY(c.rotation_target.y - rotation_step);
    }
    break;

    //----------------------------------------------------------------
    // DOWN_ARROW
  case 40: // down
    c.setRotationX(c.rotation_target.x + rotation_step);
    break;
  }

  //================================================================
  switch(key) {

    //================================================================
    // Camera Controls

    //----------------------------------------------------------------
    // translation

  case 'W':
    c.setTranslationY(c.translation_target.y + translation_step * random(0.9, 1.1), opt);
    break;
  case 'A':
    c.setTranslationX(c.translation_target.x + translation_step * random(0.9, 1.1), opt);
    break;
  case 'S':
    c.setTranslationY(c.translation_target.y - translation_step * random(0.9, 1.1), opt);
    break;
  case 'D':
    c.setTranslationX(c.translation_target.x - translation_step * random(0.9, 1.1), opt);
    break;
  case 'Q':
    if (cmd||ctrl) {
      c.setTranslation(new PVector(0.0, 0.0, -10.0));
    } else {
      z = c.translation_target.z + translation_step * random(0.9, 1.1);
      c.setTranslationZ(z, opt);
    }
    break;
  case 'E':
    if (cmd||ctrl) {
      c.setTranslation(new PVector(0.0, 0.0, -10.0), true);
    } else {
      z = c.translation_target.z - translation_step * random(0.9, 1.1);
      c.setTranslationZ(z, opt);
    }
    break;

    //----------------------------------------------------------------
    // rotation

  case 'w':
    c.setRotationX(c.rotation_target.x + rotation_step * random(0.9, 1.1), opt);
    break;
  case 'a':
    c.setRotationY(c.rotation_target.y + rotation_step * random(0.9, 1.1), opt);
    break;
  case 's':
    c.setRotationX(c.rotation_target.x - rotation_step * random(0.9, 1.1), opt);
    break;
  case 'd':
    c.setRotationY(c.rotation_target.y - rotation_step * random(0.9, 1.1), opt);
    break;
  case 'q':
    if (cmd||ctrl) {
      c.setRotation(new PVector());
    } else {
      c.setRotationZ(c.rotation_target.z + rotation_step * random(0.9, 1.1), opt);
    }
    break;
  case 'e':
    if (cmd||ctrl) {
      c.setRotation(new PVector(), true);
    } else {
      c.setRotationZ(c.rotation_target.z - rotation_step * random(0.9, 1.1), opt);
    }
    break;


    //----------------------------------------------------------------
    // perspective

  case 'z':
    c.set_fov(c.fov + rotation_step * random(0.9, 1.1), opt);
    break;
  case 'x':
    c.set_fov( PI/4.0, opt);
    break;
  case 'c':
    c.set_fov(c.fov - rotation_step * random(0.9, 1.1), opt);
    break;

  case 'Z':
    c.randomize_z_near();
    break;
  case 'X':
    c.reset_clipping();
    break;
  case 'C':
    c.randomize_z_far();
    break;

    //----------------------------------------------------------------
    // Z translation

  case '1':
    if (ctrl || cmd) {
      nationA = nations[0];
      nationB = nations[1];
    } else if (opt) {
      println("Camera 1");
      cameras.set_active_camera(0);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.0));
    }
    break;
  case '2':
    if (ctrl || cmd) {
      nationA = nations[2];
      nationB = nations[3];
    } else if (opt) {
      println("Camera 2");
      cameras.set_active_camera(1);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.11));
    }
    break;
  case '3':
    if (ctrl || cmd) {
      nationA = nations[4];
      nationB = nations[5];
    } else if (opt) {
      println("Camera 3");
      cameras.set_active_camera(2);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.22));
    }
    break;
  case '4':
    if (opt) {
      println("Camera 4");
      println("Translation - x: "+c.translation.x+", y: "+c.translation.y+", z: "+c.translation.z);
      cameras.set_active_camera(3);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.33));
    }
    break;
  case '5':
    c.setTranslationZ(lerp(zMin, zMax, 0.44));
    break;
  case '6':
    c.setTranslationZ(lerp(zMin, zMax, 0.55));
    break;
  case '7':
    c.setTranslationZ(lerp(zMin, zMax, 0.66));
    break;
  case '8':
    c.setTranslationZ(lerp(zMin, zMax, 0.77));
    break;
  case '9':
    c.setTranslationZ(lerp(zMin, zMax, 0.88));
    break;
  case '0':
    c.setTranslationZ(lerp(zMin, zMax, 0.99));
    break;

  case '!':
    if (opt) {
      cameras.get(0).randomize_rotation(true);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.0), true);
    }
    break;
  case '@':
    if (opt) {
      cameras.get(1).randomize_rotation(true);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.11), true);
    }
    break;
  case '#':
    if (opt) {
      cameras.get(2).randomize_rotation(true);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.22), true);
    }
    break;
  case '$':
    if (opt) {
      cameras.get(3).randomize_rotation(true);
    } else {
      c.setTranslationZ(lerp(zMin, zMax, 0.33), true);
    }
    break;
  case '%':
    c.setTranslationZ(lerp(zMin, zMax, 0.44), true);
    break;
  case '^':
    c.setTranslationZ(lerp(zMin, zMax, 0.55), true);
    break;
  case '&':
    c.setTranslationZ(lerp(zMin, zMax, 0.66), true);
    break;
  case '*':
    c.setTranslationZ(lerp(zMin, zMax, 0.77), true);
    break;
  case '(':
    c.setTranslationZ(lerp(zMin, zMax, 0.88), true);
    break;
  case ')':
    c.setTranslationZ(lerp(zMin, zMax, 0.99), true);
    break;


  case 'M':
    c.orbit_camera = !c.orbit_camera;
    println("orbit camera: "+ c.orbit_camera);
    if (c.orbit_camera) {
      c.randomize_orbit();
      c.orbit_rate = random(0.001, 0.01);
    }
    break;

    //================================================================
    // PlanarNation Controls

  case 'm':
    verts = generateVertices(qty_vertices);
    nationA.morph(verts);
    nationB.morph(verts);
    break;

  case'r':

    if (ctrl || cmd) {
      nationA.draw_mode+=1;
      nationA.draw_mode%=2;
    } else {
      nationA.render_texture = !nationA.render_texture;
    }
    if (!nationA.render_texture) nationA.randomizeVertices();
    break;
  case't':

    if (ctrl || cmd) {
      nationA.draw_mode+=1;
      nationA.draw_mode%=2;

      nationB.draw_mode+=1;
      nationB.draw_mode%=2;
    } else {
      nationA.render_texture = !nationA.render_texture;
      if (!nationA.render_texture) nationA.randomizeVertices();
      nationB.render_texture = !nationB.render_texture;
      if (!nationB.render_texture) nationB.randomizeVertices();
    }
    break;
  case'y':

    if (ctrl || cmd) {
      nationB.draw_mode+=1;
      nationB.draw_mode%=2;
    } else {
      nationB.render_texture = !nationB.render_texture;
    }
    if (!nationB.render_texture) nationB.randomizeVertices();
    break;

  case'R':
    nationA.render_edges = !nationA.render_edges;
    break;
  case'T':
    nationA.render_edges = !nationA.render_edges;
    nationB.render_edges = !nationB.render_edges;
    break;
  case'Y':
    nationB.render_edges = !nationB.render_edges;
    break;

  case 'f':
    nationA.randomizeVertices();
    break;
  case 'g':
    nationA.randomizeVertices();
    nationB.randomizeVertices();
    break;
  case 'h':
    nationB.randomizeVertices();

    break;

  case 'F':
    nationA.do_animate = !nationA.do_animate;
    break;
  case 'G':
    nationA.do_animate = !nationA.do_animate;
    nationB.do_animate = !nationB.do_animate;
    break;
  case 'H':
    nationB.do_animate = !nationB.do_animate;
    break;

  case 'v':
    nationA.texture_flicker = !nationA.texture_flicker;
    break;
  case 'b':
    nationA.texture_flicker = !nationA.texture_flicker;
    nationB.texture_flicker = !nationB.texture_flicker;
    break;
  case 'n':
    nationB.texture_flicker = !nationB.texture_flicker;
    break;

  case 'V':
    nationA.edge_flicker = !nationA.edge_flicker;
    break;
  case 'B':
    nationA.edge_flicker = !nationA.edge_flicker;
    nationB.edge_flicker = !nationB.edge_flicker;
    break;
  case 'N':
    nationB.edge_flicker = !nationB.edge_flicker;
    break;

  case ',': // decrement animation rate
    nationA.noise_rate = constrain( nationA.noise_rate - 0.0001, 0.0, 0.001);
    nationB.noise_rate = constrain( nationB.noise_rate - 0.0001, 0.0, 0.005);
    break;
  case '.': // increment animation rate
    nationA.noise_rate = constrain( nationA.noise_rate + 0.0001, 0.0, 0.001);
    nationB.noise_rate = constrain( nationB.noise_rate + 0.0001, 0.0, 0.005);
    break;
  case '/':
    nationA.noise_rate = random(0.005);
    nationB.noise_rate = random(0.005);
    break;

  case '<': // decrement flicker rate
    nationA.flicker_amount = constrain( nationA.flicker_amount - 0.05, 0.01, 0.99);
    nationB.flicker_amount = constrain( nationB.flicker_amount - 0.05, 0.01, 0.99);
    break;
  case '>': // increment flicker rate
    nationA.flicker_amount = constrain( nationA.flicker_amount + 0.05, 0.01, 0.99);
    nationB.flicker_amount = constrain( nationB.flicker_amount + 0.05, 0.01, 0.99);
    break;
  case '?':
    nationA.flicker_amount = random(0.01, 0.99);
    nationB.flicker_amount = random(0.01, 0.99);
    break;

    //================================================================
    // Voice Controls

  case 'U': // all voices on
    for (Voice v : voices.voices) {
      v.random_pitch();
    }
    break;

  case 'u': // all voices on
    for (Voice v : voices.voices) {
      v.random_pitch();
      v.randomize();
    }
    break;

  case 'i': // all voices on
    for (Voice v : voices.voices) {
      v.random_note();
      v.randomize();
    }
    break;

  case 'I': // all voices on
    for (Voice v : voices.voices) {
      v.random_note();
    }
    break;

  case 'o': // all voices on
    if (ctrl || cmd) {
      for (Voice v : voices.voices) {
        v.arpeggiate = !v.arpeggiate;
      }
    } else {
      for (Voice v : voices.voices) {
        v.random_scale();
        v.randomize();
      }
    }
    break;

  case 'O': // all voices on
    for (Voice v : voices.voices) {
      v.random_scale();
    }
    break;

  case 'j': // all voices on
    for (Voice v : voices.voices) {
      v.mute = false;
    }
    break;

  case 'J': // all voices off
    for (Voice v : voices.voices) {
      v.mute = true;
    }
    break;

  case 'k': // all voices on
    println("Toggle Mutes");
    for (Voice v : voices.voices) {
      v.mute = !v.mute;
    }
    break;

  case 'K': // all voices off
    println("Randomize Mutes");
    for (Voice v : voices.voices) {
      v.mute = random(1) < 0.5;
    }
    break;

  case 'l': // all voices on
    for (Voice v : voices.voices) {
      v.move_enabled = true;
    }
    break;

  case 'L': // all voices off
    for (Voice v : voices.voices) {
      v.move_enabled = false;
    }
    break;

  case ';': // all voices on
    for (Voice v : voices.voices) {
      v.move_enabled = !v.move_enabled;
    }
    break;

  case ':': // all voices off
    for (Voice v : voices.voices) {
      v.move_enabled = random(1) < 0.5;
    }
    break;

  case '_': // turn one more off
    int limit = voices.size() - min_voices;
    for (int i = 0; i < limit; i++) {
      voices.remove();
    }
    break;

  case '+': // turn one more on
    for (int i = voices.size(); i < max_voices; i++) {
      Voice v = new Voice(B_locrian);
      v.mute = false;
      voices.add(v);
    }
    break;

  case '-': // remove one voice
    if (voices.size() > min_voices) voices.remove();
    break;

  case '=': // add one voice
    if (voices.size() < max_voices) {
      Voice v = new Voice(B_locrian);
      v.mute = false;
      voices.add(v);
    }
    break;

  case 'p': // add one voice
    for (Voice v : voices.voices) {
      v.randomize_velocity();
      v.randomize_position();
      v.randomize_orientation();
    }
    break;

  case 'P': // add one voice
    for (Voice v : voices.voices) {
      v.randomize_orientation();
    }
    break;

  case '[': // add one voice
    for (Voice v : voices.voices) {
      v.randomize_velocity();
      v.randomize_position();
      v.randomize_orientation();
      v.randomize_mode();
    }
    break;

  case '{': // add one voice
    for (Voice v : voices.voices) {
      v.randomize_mode();
    }
    break;

    //================================================================
    // Light Controls

  case ']':
    lights.get(0).setPositionZ(
      constrain(lights.get(0).position_target.z - 100, 0, 1000)
      );
    break;
  case '}':
    lights.get(0).setPositionZ(
      constrain(lights.get(0).position_target.z + 100, 0, 1000)
      );
    break;

  case '\\':
    lights.get(0).setPositionZ(random(100, 500));
    break;
  case '|':
    lights.get(0).setPositionZ(250);
    break;
  }
}
