//================================================================
class Voices {
  ArrayList<Voice> voices;
  String[][] scale;


  Voices(int qty, String[][] _scale) {
    this.voices = new ArrayList<Voice>();
    this.scale = _scale;
    for (int i = 0; i < qty; i++) {
      voices.add(new Voice(_scale));
    }
  }

  void update() {
    for (Voice v : this.voices) {
      v.update();
    }
  }

  Voice get(int _index) {
    if (_index >= 0 && _index < this.voices.size()) {
      return this.voices.get(_index);
    } else {
      return null;
    }
  }

  void add() {
    this.voices.add(new Voice(this.scale));
  }

  void add(Voice v) {
    this.voices.add(v);
  }

  void remove() {
    this.voices.remove(this.voices.get(this.voices.size()-1));
  }

  int size() {
    return this.voices.size();
  }

  void remove(int _index) {
    if (_index >= 0 && _index < this.voices.size()) this.voices.remove(_index);
  }

  void render(int[] _pixels) {
    for (Voice v : this.voices) {
      v.render(_pixels);
    }
  }

  int[] getPixelData(int[] _pixels, int _qty) {
    try {
      int[] data = new int[_qty];
      int[] temp = new int[_qty];
      for (int i = 0; i < this.voices.size(); i++) {
        Voice v = this.voices.get(i);

        if (v == null) return null;

        temp = v.getPixelData(_pixels, _qty);
        for (int j = 0; j < _qty; j++) {
          if (i == 0) {
            data[j] |= temp[j];
          } else {
            data[j] ^= temp[j];
          }
        }
      }
      return data;
    }
    catch (Exception e) {
      println("Caught Exception @ getPixelData: "+e);
    }
    return null;
  }

  void randomize() {
    for (Voice v : this.voices) {
      v.randomize();
    }
  }
}

//================================================================

class Voice {
  Register register;
  PVector position;
  PVector velocity;

  String orientation = "horizontal";
  int mode = 0;
  boolean wrap = true;
  color line_color = color(0);
  int pixel_index = 0;
  int pixel_index_offset = 0;
  int last_pixel_index_offset = 0;
  boolean move_enabled = false;
  boolean move_x = true;
  boolean move_y = true;
  String[][] scale;

  boolean arpeggiate = false;
  int step_interval = 1;

  boolean mute = true;

  float base = 12;
  int start_size;
  int end_size;
  int size=2;
  float size_progress = 0.0;
  float size_step = 0.0125;

  // Experimental pitch variation
  float warble_amount = 0.05;
  float warble_rate = 0.0025;
  float warble_offset = random(-1, 1);

  Voice(String[][] _scale) {
    this.register = new Register();
    this.randomize();
    this.random_pitch();
    this.scale = new String[_scale.length][];
    arrayCopy(_scale, this.scale);
  }

  void random_scale() {
    int octave_index = floor(random(this.scale.length));
    int note_index = floor(random(this.scale[octave_index].length));
    String note_name = this.scale[octave_index][note_index];
    this.size_progress = 0.0;
    this.start_size = this.size;
    this.end_size = notes.get(note_name);
  }

  void random_note() {
    int note_index = floor(random(notes.size()));
    this.size_progress = 0.0;
    this.start_size = this.size;
    this.end_size = notes.get(notes.keyArray()[note_index]);
  }

  void random_pitch() {
    this.size_progress = 0.0;
    this.start_size = this.size;
    this.end_size = floor(random(2, 1920));
  }

  void update() {
    this.update_size();
    if (this.move_enabled) this.move();
    if (this.arpeggiate) this.arpeggio();
  }

  float ease(float _progress, float _base) {
    return log((_base - 1) * _progress + 1) / log(_base);
  }

  void update_size() {

    this.size_progress = constrain(this.size_progress, 0.0, 1.0);

    this.size = round(lerp(
      this.start_size,
      this.end_size,
      this.ease(this.size_progress, this.base)
      ) +
      (this.size * this.warble_amount * 2 * (noise(frameCount * this.warble_rate + this.warble_offset)-0.5))
      );

    if (this.size_progress < 1) this.size_progress += this.size_step;

    this.size = max(this.size, 2);
  }

  void arpeggio() {
    String note = this.scale[(this.register.get() >> 3 & 0b111) % this.scale.length][this.register.get() & 0b111];
    this.setNote(note);
    if (frameCount % this.step_interval == this.step_interval - 1) {
      this.mute = random(1) < 0.25;
      if (random(1) < 0.75) {
        this.register.lfsr_left();
      }
    }
  }

  void randomize_velocity() {
    this.velocity = new PVector(
      random(-0.002, 0.002),
      random(-0.002, 0.002)
      );
  }

  void randomize_position() {
    this.position = new PVector(
      random(0, 1),
      random(0, 1)
      );
  }

  void randomize_mode() {
    this.mode = floor(random(4));
    switch(mode) {
    case 0: // r
      this.line_color = color(255, 0, 0);
      break;
    case 1: // g
      this.line_color = color(0, 255, 0);
      break;
    case 2: // b
      this.line_color = color(0, 0, 255);
      break;
    case 3: // r ^ g ^ b
      this.line_color = color(255, 255, 255);
      break;
    }
  }

  void randomize_orientation() {
    this.orientation = random(1) < 0.5 ? "horizontal" : "vertical";
  }

  void randomize() {
    this.randomize_position();
    this.randomize_velocity();
    this.register.randomize();
    this.randomize_mode();
    this.step_interval = floor(32/random(1, 4));
    this.randomize_orientation();
  }

  void move() {

    // wrap
    if (wrap) {
      if (move_x) {
        this.position.x += this.velocity.x;
        if (this.position.x < 0.0) {
          this.position.x += 1.0;
        } else if (this.position.x >= 1.0) {
          this.position.x -= 1.0;
        }
      }

      if (move_y) {
        this.position.y += this.velocity.y;
        if (this.position.y < 0.0) {
          this.position.y += 1.0;
        } else if (this.position.y >= 1.0) {
          this.position.y -= 1.0;
        }
      }
    } else { // Bounce
      if (move_x) {
        this.position.x += this.velocity.x;
        if (this.position.x < 0.0) {
          this.position.x *= -1.0;
          this.velocity.x *=-1;
        } else if (this.position.x >= 1.0) {
          this.position.x = 2.0 - this.position.x;
          this.velocity.x *=-1;
        }
      }
      if (move_y) {
        this.position.y += this.velocity.y;
        if (this.position.y < 0.0) {
          this.position.y *= -1.0;
          this.velocity.y *=-1;
        } else if (this.position.y >= 1.0) {
          this.position.y = 2.0 - this.position.x;
          this.velocity.y *=-1;
        }
      }
    }
  }

  int[] getPixelData(int[] _pixels, int _qty) {

    int[] line = new int[_qty];
    int start_pixel = this.getStart();
    int line_position = this.getPosition();

    int pixel = color(0);
    int value = 0;

    for (int l = 0; l < _qty; l++) {
      if (this.mute) {
        value = 127;
      } else {
        this.pixel_index_offset = (l + this.last_pixel_index_offset) % this.size;
        this.pixel_index = this.pixel_index_offset + start_pixel;

        if (this.getOrientation().equals("horizontal")) {
          pixel = _pixels[line_position * width + (this.pixel_index  % width)];
        } else {
          pixel = _pixels[(this.pixel_index % height) * width + line_position];
        }

        switch(mode) {
        case 0: // r
          value = (pixel >> 16 & 0xff);
          break;
        case 1: // g
          value = (pixel >> 8 & 0xff);
          break;
        case 2: // b
          value = (pixel & 0xff);
          break;
        case 3: // r ^ g ^ b
          value = (pixel & 0xFF) ^ (pixel >> 8 & 0xFF) ^ (pixel >> 16 & 0xff);
          break;
        }
      }

      line[l] = value;
    }

    this.last_pixel_index_offset = this.pixel_index_offset;
    return line;
  }

  void setNote(String note) {
    if (notes.hasKey(note)) {
      this.size_progress = 0.0;
      this.start_size = this.size;
      this.end_size = notes.get(note);
    }
  }

  int getMax() {
    return this.orientation.equals("horizontal") ? width : height;
  }

  int getPosition() {
    return floor(
      this.orientation.equals("horizontal") ?
      this.position.y * height
      :
      this.position.x * width
      );
  }

  int getStart() {
    if (this.orientation.equals("horizontal")) {
      return (floor(this.position.x * width - (this.size / 2.0)) + width) % width;
    } else {
      return (floor(this.position.y * height - (this.size / 2.0)) + height) % height;
    }
  }


  String getOrientation() {
    return orientation;
  }

  void moveEnable() {
    this.move_enabled = true;
  }

  void moveDisable() {
    this.move_enabled = false;
  }

  void render(int[] _pixels) {
    if (this.mute) return;
    for (int l = 0; l < this.size; l++) {
      if (this.getOrientation().equals("horizontal")) {
        _pixels[((height + this.getPosition()) % height) * width + ((l+this.getStart() + width) % width)] = this.line_color;
      } else {
        _pixels[((l+this.getStart() + height) % height) * width + ((width + this.getPosition()) % width)] = this.line_color;
      }
    }
  }
}
