//================================================================
// Cameras

class Cameras {

  //================================================================
  // Fields

  ArrayList<Camera> cameras = new ArrayList<Camera>();
  int active_camera = 0;

  //================================================================
  // Constructors

  Cameras(int qty) {
    for (int i = 0; i < qty; i++) {
      Camera c = new Camera();
      c.randomize_translation(true);
      c.setRotationZ(random(-PI, PI), true);
      cameras.add(c);
    }
  }

  //================================================================
  // Methods

  int size() {
    return this.cameras.size();
  }

  void update() {
    for (int i = 0; i < this.size(); i++) {
      Camera c = this.cameras.get(i);
      c.update();
      if (i == this.active_camera) c.render();
    }
  }

  Camera set_active_camera(int index) {
    this.active_camera = constrain(index, 0, this.size());
    return this.get_active_camera();
  }

  Camera get_active_camera() {
    return this.cameras.get(this.active_camera);
  }

  Camera get(int index) {
    return this.cameras.get(constrain(index, 0, this.size()));
  }
}

//================================================================
// Camera
/*

 camera()
 - Eye - x,y,z location of the camera AKA position
 - Center - x,y,z location of the target (where the eye is pointing)
 - Up - specify which axis is up
 
 perspective()
 - FOV
 - Apect Ratio
 - zNear
 - zFar
 
 note: the following are applied to the matrix after camera parameters are set
 
 translation: shifting the camera without changing the eye/position or center coordinates
 
 rotation
 - pitch = x-axis
 - yaw = y-axis
 - roll = z-axis
 */


class Camera {

  //================================================================
  // Fields

  //----------------------------------------------------------------
  PVector position;
  PVector position_lerp;
  PVector position_target;
  float position_rate = 0.0025;
  float position_progress = 0.0;

  //----------------------------------------------------------------
  PVector center;
  PVector center_lerp;
  PVector center_target;

  float center_rate = 0.0025;
  float center_progress = 0.0;

  //----------------------------------------------------------------
  PVector axis;

  //----------------------------------------------------------------
  PVector translation;
  PVector translation_lerp;
  PVector translation_target;
  float translation_rate = 0.001;
  float translation_progress = 0.0;

  //----------------------------------------------------------------
  PVector rotation;
  PVector rotation_lerp;
  PVector rotation_target;
  float rotation_rate = 0.005;
  float rotation_progress = 0.0;

  //----------------------------------------------------------------
  float aspect_ratio;
  float fov;
  float fov_lerp;
  float fov_target;
  float z_near = 1;
  float z_far = 10000;

  float perspective_rate = 0.001;
  float perspective_progress = 0.0;

  //----------------------------------------------------------------
  float radius;
  float radius_target;
  float radius_ease_amount = 0.1;

  float orbit_rate = 0.01;
  float orbit_progress = 0.0;

  boolean orbit_camera = false;

  //================================================================
  // Constructors

  Camera() {

    this.position = new PVector(0.0, 0.0, 1.0);
    this.position_lerp = position.copy();
    this.position_target = position.copy();

    this.center = new PVector();
    this.center_lerp = center.copy();
    this.center_target = center.copy();

    this.rotation = new PVector();
    this.rotation_lerp = rotation.copy();
    this.rotation_target = rotation.copy();

    this.translation = new PVector(0.0, 0.0, -100);
    this.translation_lerp = translation.copy();
    this.translation_target = translation.copy();

    this.axis = new PVector(0.0, 1.0, 0.0);// y-up

    this.radius = height/2.0;
    this.radius_target = this.radius;

    this.fov = PI/4.0;
    this.fov_lerp = this.fov;
    this.fov_target = this.fov;

    this.aspect_ratio = float(width)/float(height);

    this.z_near = 1.0;
    this.z_far = 10000;
  }

  //================================================================
  // Methods

  //----------------------------------------------------------------

  void update() {

    //this.position_camera();
    //this.center_camera();
    this.animate_perspective();
    this.translate_camera();
    this.rotate_camera();
    if (this.orbit_camera) this.orbit();
  }

  //----------------------------------------------------------------

  void render() {
    beginCamera();

    perspective(
      this.fov,
      this.aspect_ratio,
      this.z_near,
      this.z_far
      );

    camera(
      this.position_lerp.x, this.position_lerp.y, this.position_lerp.z,
      this.center_lerp.x, this.center_lerp.y, this.center_lerp.z,
      this.axis.x, this.axis.y, this.axis.z
      );

    translate(
      this.translation_lerp.x,
      this.translation_lerp.y,
      this.translation_lerp.z
      );

    rotateX(this.rotation_lerp.x); // pitch
    rotateY(this.rotation_lerp.y); // yaw
    rotateZ(this.rotation_lerp.z); // roll

    endCamera();
  }

  float ease(float current, float target, float amount) {
    return(amount * (target - current) + current);
  }

  //----------------------------------------------------------------

  void randomize_orbit() {
    this.radius_target = random(1.0, width/4.0);
    this.orbit_rate = random(0.001, 0.01);
  }

  void setOrbitRadius(int r) {
    this.radius_target = r;
  }

  void orbit() {
    this.orbit_progress += this.orbit_rate;
    if (this.orbit_progress >= 1.0) this.orbit_progress-=1;
    this.position_lerp.x = this.radius * cos(2 * PI * this.orbit_progress);
    this.position_lerp.y = this.radius * sin(2 * PI * this.orbit_progress);
    this.radius = this.ease(this.radius, this.radius_target, this.radius_ease_amount);
  }

  //----------------------------------------------------------------

  void set_fov(float radians) {
    this.fov_target = constrain(radians, PI/128.0, PI);
    this.perspective_progress = 0.0;
  }

  void set_fov(float radians, boolean instant) {
    if ( instant ) {
      this.fov = constrain(radians, PI/128.0, PI);
      this.fov_target = this.fov;
      this.perspective_progress = 1.0;
    } else {
      set_fov(radians);
    }
  }

  void animate_perspective() {
    if (this.perspective_progress < 1.0) {
      this.perspective_progress += this.perspective_rate;
    }

    this.fov = lerp(this.fov, this.fov_target, this.perspective_progress);
  }

  void randomize_perspective() {
    this.perspective_progress = 0.0;
    this.fov_target = random(PI/16.0, PI/2.0);
  }

  void randomize_perspective(boolean instant) {
    if (instant) {
      this.perspective_progress = 1.0;
      this.fov = random(PI/16.0, PI/2.0);
      this.fov_target = this.fov;
    } else {
      this.randomize_perspective();
    }
  }

  void reset_clipping() {
    float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
    this.set_z_near(cameraZ/10.0);
    this.set_z_far(cameraZ*10.0);
  }

  void randomize_clipping() {
    this.set_z_near(random(0.001, 10));
    this.set_z_far(random(5000, 10000));
  }

  void randomize_z_near() {
    this.set_z_near(random(0.001, 10));
  }

  void randomize_z_far() {
    this.set_z_far(random(5000, 10000));
  }

  void set_z_near(float value) {
    println("set_z_near: " + value);
    this.z_near = constrain(value, 0.001, 10);
  }

  void set_z_far(float value) {
    println("set_z_far: " + value);
    this.z_far = constrain(value, 5000, 10000);
  }

  //----------------------------------------------------------------
  // Position Camera

  void randomize_position() {
    this.setPosition(new PVector(
      random(-width/4.0, width/4.0),
      random(-width/4.0, height/4.0),
      random(10, 1000)));
  }

  void randomize_position(boolean instant) {
    if (instant) {
      this.setPosition(new PVector(
        random(-width/4.0, width/4.0),
        random(-width/4.0, height/4.0),
        random(10, 1000)), true);
    } else {
      this.randomize_position();
    }
  }

  void setPositionX(float x) {
    this.position = this.position_lerp.copy();
    this.position_target.x = x;
    this.position_progress = 0.0;
  }

  void setPositionY(float y) {
    this.position = this.position_lerp.copy();
    this.position_target.y = y;
    this.position_progress = 0.0;
  }

  void setPositionZ(float z) {
    this.position = this.position_lerp.copy();
    this.position_target.z = constrain(z, this.z_near, this.z_far);
    this.position_progress = 0.0;
  }

  void setPositionZ(float z, boolean instant) {
    if (instant) {
      this.position = this.position_lerp.copy();
      this.position.z = constrain(z, this.z_near, this.z_far);
      this.position_target = this.position.copy();
      this.position_lerp = this.position.copy();
      this.position_progress = 1.0;
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
      this.position_lerp = this.position.copy();
      this.position_target = this.position.copy();
      this.position_progress = 1.0;
    } else {
      this.setPosition(_position);
    }
  }

  void position_camera() {
    if (this.position_progress < 1.0) {
      this.position_progress = constrain(this.position_progress + this.position_rate, 0.0, 1.0);
      this.position_lerp.x = lerp(this.position.x, this.position_target.x, this.position_progress);
      this.position_lerp.y = lerp(this.position.y, this.position_target.y, this.position_progress);
      this.position_lerp.z = lerp(this.position.z, this.position_target.z, this.position_progress);
    } else if (this.position_progress >= 1.0) {
      this.position = this.position_target.copy();
    }
  }

  //----------------------------------------------------------------
  // Center Camera

  void randomize_center() {
    this.setCenter(new PVector(
      random(-width/4.0, width/4.0),
      random(-height/4.0, height/4.0),
      0.0
      ));
  }

  void randomize_center(boolean instant) {
    if (instant) {
      this.setCenter(new PVector(
        random(-width/4.0, width/4.0),
        random(-height/4.0, height/4.0),
        0.0), true);
    } else {
      randomize_center();
    }
  }

  void setCenterX(float x) {
    this.center = this.center_lerp.copy();
    this.center.x = x;
    this.center_target = this.center.copy();
    this.center_progress = 0.0;
  }

  void setCenterY(float y) {
    this.center = this.center_lerp.copy();
    this.center.y = y;
    this.center_target = this.center.copy();
    this.center_progress = 0.0;
  }

  void setCenterZ(float z) {
    this.center = this.center_lerp.copy();
    this.center.z = z;
    this.center_target = this.center.copy();
    this.center_progress = 0.0;
  }

  void setCenter(PVector _center) {
    this.center = this.center_lerp.copy();
    this.center_target = _center.copy();
    this.center_progress = 0.0;
  }

  void setCenter(PVector _center, boolean instant) {
    if (instant) {
      this.center = _center;
      this.center_target = this.center.copy();
      this.center_lerp = this.center.copy();
      this.center_progress = 1.0;
    } else {
      this.setCenter(_center);
    }
  }

  void center_camera() {
    if (this.center_progress < 1.0) {
      this.center_progress = constrain(this.center_progress + this.center_rate, 0.0, 1.0);
      this.center_lerp = new PVector(
        lerp(this.center.x, this.center_target.x, this.center_progress),
        this.center_lerp.y = lerp(this.center.y, this.center_target.y, this.center_progress),
        this.center_lerp.z = lerp(this.center.z, this.center_target.z, this.center_progress)
        );
    } else if (this.center_progress >= 1.0) {
      this.center = this.center_target.copy();
    }
  }

  //----------------------------------------------------------------
  // Rotate Camera

  void randomize_rotation() {
    this.setRotation(new PVector(
      random(-PI/4.0, PI/4.0),
      random(-PI/4.0, PI/4.0),
      random(0, 2*PI)
      ));
  }

  void randomize_rotation(boolean instant) {
    if (instant) {
      this.setRotation(new PVector(
        random(-PI/4.0, PI/4.0),
        random(-PI/4.0, PI/4.0),
        random(0, 2*PI)
        ), true);
    } else {
      this.randomize_rotation();
    }
  }

  void apply_rotation() {
    this.rotation_lerp = this.rotation.copy();
    this.rotation_target = this.rotation.copy();
    this.rotation_progress = 1.0;
  }

  void setRotationX(float x) {
    this.rotation = this.rotation_lerp.copy();
    this.rotation_target.x = constrain(x, -7*PI/16.0, 7*PI/16.0);
    this.rotation_progress = 0.0;
  }

  void setRotationX(float x, boolean instant) {
    if (instant) {
      this.rotation.x = constrain(x, -7*PI/16.0, 7*PI/16.0);
      this.apply_rotation();
    } else {
      this.setRotationX(x);
    }
  }

  void setRotationY(float y) {
    this.rotation = this.rotation_lerp.copy();
    this.rotation_target.y =  constrain(y, -7*PI/16.0, 7*PI/16.0);
    this.rotation_progress = 0.0;
  }

  void setRotationY(float y, boolean instant) {
    if (instant) {
      this.rotation.y = constrain(y, -7*PI/16.0, 7*PI/16.0);
      this.apply_rotation();
    } else {
      this.setRotationY(y);
    }
  }

  void setRotationZ(float z) {
    this.rotation = this.rotation_lerp.copy();
    this.rotation_target.z =  constrain(z, -PI, PI);
    this.rotation_progress = 0.0;
  }

  void setRotationZ(float z, boolean instant) {

    if (instant) {
      this.rotation.z = constrain(z, -PI, PI);
      this.apply_rotation();
    } else {
      this.setRotationZ(z);
    }
  }

  void setRotation(PVector _rotation) {
    this.rotation = this.rotation_lerp.copy();
    this.rotation_target = _rotation.copy();
    this.rotation_progress = 0.0;
  }

  void setRotation(PVector _rotation, boolean instant) {
    if (instant) {
      this.rotation = _rotation;
      this.rotation_lerp = this.rotation.copy();
      this.rotation_target = this.rotation.copy();
      this.rotation_progress = 1.0;
    } else {
      this.setRotation(_rotation);
    }
  }

  PVector getRotation() {
    return this.rotation.copy();
  }

  void rotate_camera() {

    if (this.rotation_progress < 1.0) {
      this.rotation_progress = constrain(this.rotation_progress + this.rotation_rate, 0.0, 1.0);
      this.rotation_lerp = new PVector(
        lerp(this.rotation.x, this.rotation_target.x, this.rotation_progress),
        lerp(this.rotation.y, this.rotation_target.y, this.rotation_progress),
        lerp(this.rotation.z, this.rotation_target.z, this.rotation_progress)
        );
    } else if (this.rotation_progress >= 1.0) {
      this.rotation = this.rotation_target.copy();
    }
  }

  //----------------------------------------------------------------
  // Translate Camera

  void randomize_translation() {
    this.setTranslation(new PVector(
      random(-width/4.0, width/4.0),
      random(-height/4.0, height/4.0),
      -random(0.0, 2500)
      ));
  }

  void randomize_translation(boolean instant) {
    if (instant) {
      this.setTranslation(new PVector(
        random(-width/4.0, width/4.0),
        random(-height/4.0, height/4.0),
        -random(0.0, 2500)
        ), true);
    } else {
      this.randomize_translation();
    }
  }

  void apply_translation() {
    this.translation_lerp = this.translation.copy();
    this.translation_target = this.translation.copy();
    this.translation_progress = 1.0;
  }

  void setTranslationX(float x) {
    this.translation = this.translation_lerp.copy();
    this.translation_target.x = x;
    this.translation_progress = 0.0;
  }

  void setTranslationX(float x, boolean instant) {
    if (instant) {
      this.translation.x = x;
      this.apply_translation();
    } else {
      this.setTranslationX(x);
    }
  }

  void setTranslationY(float y) {
    this.translation = this.translation_lerp.copy();
    this.translation_target.y = y;
    this.translation_progress = 0.0;
  }

  void setTranslationY(float y, boolean instant) {
    if (instant) {
      this.translation.y = y;
      this.apply_translation();
    } else {
      this.setTranslationY(y);
    }
  }

  void setTranslationZ(float z) {
    this.translation = this.translation_lerp.copy();
    this.translation_target.z = constrain(z, -10000, 0.0);
    this.translation_progress = 0.0;
  }

  void setTranslationZ(float z, boolean instant) {
    if (instant) {
      this.translation.z = constrain(z, -10000, 0.0);
      this.apply_translation();
    } else {
      this.setTranslationZ(z);
    }
  }

  void setTranslation(PVector _translation) {
    this.translation = this.translation_lerp.copy();
    this.translation_target = _translation.copy();
    this.translation_progress = 0.0;
  }

  void setTranslation(PVector _translation, boolean instant) {
    if (instant) {
      this.translation = _translation;
      this.apply_translation();
    } else {
      this.setTranslation(_translation);
    }
  }

  PVector getTranslation() {
    return this.translation.copy();
  }

  void translate_camera() {
    if (this.translation_progress < 1.0) {
      this.translation_progress = constrain(this.translation_progress + this.translation_rate, 0.0, 1.0);
      this.translation_lerp = new PVector(
        lerp(this.translation.x, this.translation_target.x, this.translation_progress),
        lerp(this.translation.y, this.translation_target.y, this.translation_progress),
        lerp(this.translation.z, this.translation_target.z, this.translation_progress)
        );
    } else if (this.translation_progress >= 1.0) {
      this.translation = this.translation_target.copy();
    }
  }
}
