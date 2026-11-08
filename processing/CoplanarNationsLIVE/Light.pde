//================================================================
// Lights

class Lights {
  //================================================================
  // Fields

  ArrayList<Light> lights = new ArrayList<Light>();

  //================================================================
  // Constructors

  Lights(int qty) {
    for (int i = 0; i<qty; i++) {
      lights.add(new Light());
    }
  }

  //================================================================
  // Methods

  void update() {
    for (Light l : this.lights) {
      l.update();
      l.light();
    }
  }

  Light get(int index) {
    return this.lights.get(
      constrain(index, 0, this.size())
      );
  }

  int size() {
    return this.lights.size();
  }
}

//================================================================
// Light

class Light {
  //================================================================
  // Fields

  color c;

  color c_lerp;
  color c_target;
  float c_progress=0.0;
  float c_rate = 0.01;

  PVector position;
  PVector position_lerp;
  PVector position_target;
  float position_progress=0.0;
  float position_rate = 0.01;

  //================================================================
  // Constructors

  Light() {
    this.c = color(0);
    this.position = new PVector(0.0, 0.0, 1000);
    this.apply_position();
  }

  Light(PVector _position) {
    this.c = color(0);
    this.position = _position.copy();
    this.apply_position();
  }

  Light(color _c, PVector _position) {
    this.c = _c;
    this.position = _position.copy();
    this.apply_position();
  }

  //================================================================
  // Methods

  void update() {
    this.position_light();
    this.color_light();
  }

  void light() {
    pointLight(
      this.c_lerp >> 16 & 0xFF, this.c_lerp >> 8 & 0xFF, this.c_lerp & 0xff,
      this.position_lerp.x, this.position_lerp.y, this.position_lerp.z
      );
  }

  void apply_position() {
    this.position_lerp = this.position.copy();
    this.position_target = this.position.copy();
    this.position_progress = 1.0;
  }

  void randomize_position() {
    this.position = this.position_lerp.copy();
    this.position_progress = 0.0;
    this.position_target = new PVector(
      random(-width/4.0, width/4.0),
      random(-width/4.0, height/4.0),
      random(height/10.0, height/2.0)
      );
  }

  void randomize_position(boolean instant) {
    if (instant) {
      this.position = new PVector(
        random(-width/4.0, width/4.0),
        random(-width/4.0, height/4.0),
        random(height/10.0, height/2.0)
        );
      this.apply_position();
    } else {
      this.randomize_position();
    }
  }

  void setPositionX(float x) {
    this.position = this.position_lerp.copy();
    this.position_target.x = x;
    this.position_progress = 0.0;
  }

  void setPositionX(float x, boolean instant) {
    if (instant) {
      this.position = this.position_lerp.copy();
      this.position.x = x;
      this.apply_position();
    } else {
      this.setPositionZ(x);
    }
  }

  void setPositionY(float y) {
    this.position = this.position_lerp.copy();
    this.position_target.y = y;
    this.position_progress = 0.0;
  }

  void setPositionY(float y, boolean instant) {
    if (instant) {
      this.position = this.position_lerp.copy();
      this.position.y = y;
      this.apply_position();
    } else {
      this.setPositionZ(y);
    }
  }

  void setPositionZ(float z) {
    this.position = this.position_lerp.copy();
    this.position_target.z = constrain(z, 10, 10000);
    this.position_progress = 0.0;
  }

  void setPositionZ(float z, boolean instant) {
    if (instant) {
      this.position = this.position_lerp.copy();
      this.position.z = z;
      this.apply_position();
    } else {
      this.setPositionZ(z);
    }
  }

  void setPosition(PVector _position) {
    this.position = this.position_lerp.copy();
    this.position_target = _position.copy();
    this.position_progress = 0.0;
  }

  void setPosition(PVector _position, boolean instant) {
    if (instant) {
      this.position = _position;
      this.apply_position();
    } else {
      this.setPosition(_position);
    }
  }

  void position_light() {

    if (this.position_progress < 1.0) {
      this.position_progress = constrain(this.position_progress + this.position_rate, 0.0, 1.0);

      this.position_lerp.x = lerp(this.position.x, this.position_target.x, this.position_progress);
      this.position_lerp.y = lerp(this.position.y, this.position_target.y, this.position_progress);
      this.position_lerp.z = lerp(this.position.z, this.position_target.z, this.position_progress);
    } else if (this.position_progress >= 1.0) {
      this.position = this.position_target.copy();
    }
  }

  //================================================================


  void apply_color() {
    this.c_lerp = this.c;
    this.c_target = this.c;
    this.c_progress = 1.0;
  }

  void setColor(color _c) {
    this.c = this.c_lerp;
    this.c_target = _c;
    this.c_progress = 0.0;
  }

  void setColor(color _c, boolean instant) {
    if (instant) {
      this.c = _c;
      this.apply_color();
    } else {
      setColor(_c);
    }
  }

  void color_light() {
    if (this.c_progress < 1.0) {
      this.c_progress = constrain(this.c_progress + this.c_rate, 0.0, 1.0);
      this.c_lerp = lerpColor(this.c, this.c_target, this.c_progress);
    } else if (this.c_progress >= 1.0) {
      this.c = this.c_target;
    }
  }
}
