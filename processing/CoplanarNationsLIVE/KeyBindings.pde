
boolean shift = false;
boolean ctrl = false;
boolean opt = false;
boolean cmd = false;
float rotation_step = PI/64.0;
float translation_step = 100;
int min_voices = 0;
int max_voices = 20;

void keyReleased() {
  //println("released keyCode:" + keyCode + ", key: " + key);
  if (keyCode == 16) shift = false;
  if (keyCode == 17) ctrl = false;
  if (keyCode == 18) opt = false;
  if (keyCode == 157) cmd = false;
}

void keyPressed() {
  //println("pressed keyCode:" + keyCode + ", key: " + key);
  if (keyCode == 16) shift = true;
  if (keyCode == 17) ctrl = true;
  if (keyCode == 18) opt = true;
  if (keyCode == 157) cmd = true;

  switch(keyCode) {
  case 32: // SCAPE_BAR turn off PlanarNation visibility and animation

    if (shift) {

      nationA.render_edges = false;
      nationA.render_texture = false;

      nationB.render_edges = false;
      nationB.render_texture = false;

      for (Voice v : voices.voices) {
        v.mute = true;
      }
    }

    nationA.edge_flicker = false;
    nationA.texture_flicker = false;
    nationA.do_animate = false;

    nationB.edge_flicker = false;
    nationB.texture_flicker = false;
    nationB.do_animate = false;

    break;
  case 37: // left
    if (shift) {
      camera1.setRotationZ(camera1.rotation_target.z + rotation_step);
    } else {
      camera1.setRotationY(camera1.rotation_target.y + rotation_step);
    }
    break;
  case 38: // up
    camera1.setRotationX(camera1.rotation_target.x - rotation_step);
    break;
  case 39: // right
    if (shift) {
      camera1.setRotationZ(camera1.rotation_target.z - rotation_step);
    } else {
      camera1.setRotationY(camera1.rotation_target.y - rotation_step);
    }
    break;
  case 40: // down
    camera1.setRotationX(camera1.rotation_target.x + rotation_step);
    break;
  }

  switch(key) {

  case 'w':
    camera1.setTranslationY(camera1.translation_target.y + translation_step);
    break;
  case 'a':
    camera1.setTranslationX(camera1.translation_target.x + translation_step);
    break;
  case 's':
    camera1.setTranslationY(camera1.translation_target.y - translation_step);
    break;
  case 'd':
    camera1.setTranslationX(camera1.translation_target.x - translation_step);
    break;

  case 'W':
    camera1.setPositionY(camera1.position_target.y + translation_step);
    break;
  case 'A':
    camera1.setPositionX(camera1.position_target.x + translation_step);
    break;
  case 'S':
    camera1.setPositionY(camera1.position_target.y - translation_step);
    break;
  case 'D':
    camera1.setPositionX(camera1.position_target.x - translation_step);
    break;

    // Camera Z
  case '1':
    if (ctrl || cmd) {
      nationA = nations[0];
      nationB = nations[1];
    } else {
      camera1.setPositionZ(10);
    }
    break;
  case '2':
    if (ctrl || cmd) {
      nationA = nations[2];
      nationB = nations[3];
    } else {
      camera1.setPositionZ(20);
    }
    break;
  case '3':
    if (ctrl || cmd) {
      nationA = nations[4];
      nationB = nations[5];
    } else {
      camera1.setPositionZ(40);
    }
    break;
  case '4':
    camera1.setPositionZ(80);
    break;
  case '5':
    camera1.setPositionZ(160);
    break;
  case '6':
    camera1.setPositionZ(320);
    break;
  case '7':
    camera1.setPositionZ(640);
    break;
  case '8':
    camera1.setPositionZ(1280);
    break;
  case '9':
    camera1.setPositionZ(2560);
    break;
  case '0':
    camera1.setPositionZ(5120);
    break;

  case '!':
    camera1.setPositionZ(10, true);
    break;
  case '@':
    camera1.setPositionZ(20, true);
    break;
  case '#':
    camera1.setPositionZ(40, true);
    break;
  case '$':
    camera1.setPositionZ(80, true);
    break;
  case '%':
    camera1.setPositionZ(160, true);
    break;
  case '^':
    camera1.setPositionZ(320, true);
    break;
  case '&':
    camera1.setPositionZ(640, true);
    break;
  case '*':
    camera1.setPositionZ(1280, true);
    break;
  case '(':
    camera1.setPositionZ(2560, true);
    break;
  case ')':
    camera1.setPositionZ(5120, true);
    break;



  case 'M':
    camera1.orbit_camera = !camera1.orbit_camera;
    println("orbit camera: "+ camera1.orbit_camera);
    if (camera1.orbit_camera) {
      camera1.randomize_orbit();
      camera1.orbit_rate = random(0.001, 0.01);
    }
    break;

  case 'm':
    verts = generateVertices(qty_vertices);
    nationA.morph(verts);
    nationB.morph(verts);
    break;

  case'r':
    nationA.render_texture = !nationA.render_texture;
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
    nationB.render_texture = !nationB.render_texture;
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
    for (Voice v : voices.voices) {
      v.random_scale();
      v.randomize();
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

  case ']':
    light1.setPositionZ(
      constrain(light1.position_target.z - 10, 100, 500)
      );
    break;
  case '}':
    light1.setPositionZ(
      constrain(light1.position_target.z + 10, 100, 500)
      );
    break;

  case '\\':
    light1.setPositionZ(random(100, 500));
    break;
  case '|':
    light1.setPositionZ(250);
    break;

  case 'E':
    camera1.setCenter(new PVector());
    break;
  case 'e':
    camera1.randomize_center();
    break;
  case 'Q':
    camera1.setPosition(new PVector(0.0, 0.0, camera1.position_lerp.z));
    break;
  case 'q':
    camera1.randomize_position();
    break;
  case 'z':
    camera1.randomize_translation();
    break;
  case 'Z':
    camera1.setTranslation(new PVector());
    break;
  case 'x':
    camera1.randomize_rotation();
    break;
  case 'X':
    camera1.setRotation(new PVector());
    break;
  case 'c':
    camera1.randomize_perspective();
    break;
  case 'C':
    camera1.fov_target = PI/4.0;
    break;
  }
}
