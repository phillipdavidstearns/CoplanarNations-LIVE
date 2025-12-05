class PlanarNation {
  PImage texture;
  float[][] vertices;
  float[][] vertices_morphed;
  float[][] vertices_target;
  //float scale = 1920.0;
  float[] noise_offset = {
    random(-5,5),
    random(-5,5),
    random(-5,5),
    random(-5,5)
  };
  float noise_position = 0.0;
  float noise_rate = 0.001;
  boolean do_animate = false;
  float morph_progress = 0.0;
  float morph_speed = 0.01;
  boolean morph_enabled = false;
  boolean debug = false;
  boolean render_edges = false;
  boolean render_texture = false;
  int qty_vertices;
  boolean edge_flicker=false;
  boolean texture_flicker=false;
  float flicker_amount=0.5;
  

  //----------------------------------------------------------------
  // Constructors

  PlanarNation(int qty_vertices, PImage texture) {
    this.morph_speed = random(0.0001, 0.01);
    this.qty_vertices = qty_vertices;
    this.texture = texture;
    this.vertices = this.generateVertices(this.qty_vertices);
    this.vertices_target = new float[this.vertices.length][];
    this.vertices_morphed = new float[this.vertices.length][];
  }

  //----------------------------------------------------------------
  // update

  void update() {
    if (this.edge_flicker) this.render_edges = random(1) < this.flicker_amount;
    if (this.texture_flicker) this.render_texture = random(1) < this.flicker_amount;
    if (this.do_animate) this.noise_position += this.noise_rate;
    if (this.morph_enabled) this.do_morph();
  }

  //----------------------------------------------------------------
  // morphControls

  void do_morph() {
    if (this.morph_progress >= 1.0) {
      this.morph_enabled = false;
      this.morph_progress = 0.0;
      arrayCopy(this.vertices_target, this.vertices);
    } else {
      this.morph_progress = constrain(this.morph_progress + this.morph_speed, 0.0, 1.0);
      for (int i = 0; i < this.vertices.length; i++) {
        for (int j = 0; j < this.vertices_morphed[i].length; j++) {
          this.vertices_morphed[i][j] = lerp(this.vertices[i][j], this.vertices_target[i][j], this.morph_progress);
        }
      }
    }
  }

  void morph(float[][] target_vertices) {
    arrayCopy(this.vertices, this.vertices_morphed);
    arrayCopy(target_vertices, this.vertices_target);
    this.morph_progress = 0.0;
    this.morph_enabled = true;
  }

  //----------------------------------------------------------------
  // render

  void render() {
    float[] start;
    float[] temp;

    if (this.render_edges) {
      strokeWeight(1);
      stroke(255);
    } else {
      noStroke();
    }

    textureMode(NORMAL);
    textureWrap(REPEAT);
    

    //draw the vertices
    beginShape();
    if (this.texture != null && this.render_texture) {
      texture(this.texture);
    } else {
      noFill();
    }
    
    for (int i = 0; i < this.vertices.length - 2; i++){
      start = this.morph_enabled ? this.vertices_morphed[i] : this.vertices[i];
      this.placeVertex(start);
      for(int j = 1; j < 3; j++){
        temp = this.morph_enabled ? this.vertices_morphed[i+j] : this.vertices[i+j];
        this.placeVertex(temp);
      }
      this.placeVertex(start);
    }

    for (int i = 0; i < this.vertices.length; i++) {
      temp = this.morph_enabled ? this.vertices_morphed[i] : this.vertices[i];
      this.placeVertex(temp);
    }

    float[] end = this.morph_enabled ? this.vertices_morphed[0] : this.vertices[0];
    this.placeVertex(end);
    endShape();
  }

  void placeVertex(float[] vertex) {
    vertex(
      width * ( vertex[0] * 2.0 * ( noise(50.0 * vertex[0], this.noise_offset[0] - this.noise_position) - 0.5)),
      width * ( vertex[1] * 2.0 * ( noise(-50.0 * vertex[1], this.noise_offset[1] + this.noise_position) - 0.5)),
      vertex[2] * 2.0 * ( noise(50.0 * vertex[2], this.noise_offset[2] - this.noise_position) - 0.5),
      vertex[3] * 2.0 * ( noise(-50.0 * vertex[3], this.noise_offset[3] + this.noise_position) - 0.5)
      );
  }

  float[][] generateVertices(int _qty_vertices) {
    float[][] new_vertices = new float[_qty_vertices][];
    for (int i = 0; i < this.qty_vertices; i++) {
      new_vertices[i] = this.generateRandomVertex();
    }
    return new_vertices;
  }

  //----------------------------------------------------------------
  // randomizeVertices

  float[][] randomizeVertices() {
    for (int i = 0; i < this.vertices.length; i++) {
      this.vertices[i] = this.generateRandomVertex();
    }
    arrayCopy(this.vertices, this.vertices_morphed);
    arrayCopy(this.vertices, this.vertices_target);
    return this.vertices;
  }

  //----------------------------------------------------------------
  // generateRandomVertex

  float[] generateRandomVertex() {
    return new float[]{
      random(-1, 1),
      random(-1, 1),
      random(-1,1),
      random(-1,1)
    };
  }
  //----------------------------------------------------------------
  // getters

  //----------------------------------------------------------------
  // setters
  PlanarNation setVertices(float[][] vertices) {
    if (this.morph_enabled) {
      this.vertices_target = vertices;
    } else {
      this.vertices = vertices;
    }

    return this;
  }
}
