class Light {
  color c;
  PVector position;
  PVector position_lerp;
  PVector position_target;
  float position_progress=0.0;
  float position_rate = 0.01;
  boolean do_position = false;

  Light() {
    this.c = color(255);
    this.position = new PVector(0.0, 0.0, 100);
    this.position_lerp = this.position.copy();
    this.position_target = this.position.copy();
  }

  Light(PVector _position) {
    this.c = color(255);
    this.position = _position.copy();
    this.position_lerp = _position.copy();
    this.position_target = _position.copy();
  }

  Light(color _c, PVector _position) {
    this.c = _c;
    this.position = _position.copy();
    this.position_lerp = _position.copy();
    this.position_target = _position.copy();
  }

  void setColor(color _c) {
    this.c = _c;
  }

  void update() {
    this.position_light();
  }

  void light() {
    pointLight(
      this.c >> 16 & 0xFF, this.c >> 8 & 0xFF, this.c & 0xff,
      this.position_lerp.x, this.position_lerp.y, this.position_lerp.z
      );
  }

  void randomize_position() {
    this.position = this.position_lerp.copy();
    this.position_progress = 0.0;
    this.do_position = true;
    this.position_target.x = random(-width/4.0, width/4.0);
    this.position_target.y = random(-width/4.0, height/4.0);
    this.position_target.z = random(height/10.0, height/2.0);
  }

  void setPositionX(float x) {
    this.position = this.position_lerp.copy();
    this.position_target.x = x;
    this.position_progress = 0.0;
    this.do_position = true;
  }

  void setPositionY(float y) {
    this.position = this.position_lerp.copy();
    this.position_target.y = y;
    this.position_progress = 0.0;
    this.do_position = true;
  }

  void setPositionZ(float z) {
    this.position = this.position_lerp.copy();
    this.position_target.z = constrain(z, 10, 10000);
    this.position_progress = 0.0;
    this.do_position = true;
  }

  void setPositionZ(float z, boolean instant) {
    if (instant) {
      this.position = this.position_lerp.copy();
      this.position.z = z;
      this.position_target = this.position.copy();
      this.position_lerp = this.position.copy();
    } else {
      this.setPositionZ(z);
    }
  }

  void setPosition(PVector _position) {
    this.position = this.position_lerp.copy();
    this.position_target = _position.copy();
    this.position_progress = 0.0;
    this.do_position = true;
  }

  void position_light() {

    if (this.position_progress < 1.0 && this.do_position) {
      this.position_progress = constrain(this.position_progress + this.position_rate, 0.0, 1.0);

      this.position_lerp.x = lerp(this.position.x, this.position_target.x, this.position_progress);
      this.position_lerp.y = lerp(this.position.y, this.position_target.y, this.position_progress);
      this.position_lerp.z = lerp(this.position.z, this.position_target.z, this.position_progress);
    } else if (this.position_progress >= 1.0 && this.do_position) {
      this.position = this.position_target.copy();
      this.do_position = false;
    }
  }
}
