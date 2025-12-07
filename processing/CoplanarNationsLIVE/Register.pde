class Register {
  int register = 0;
  int length;
  int[] taps = new int[2];

  Register() {
    this.length = 16;
    this.randomize_register();
    this.randomize_taps();
  }

  Register(int value) {
    this.register = value;
    this.length = 16;
  }

  void loop_left() {
    int temp = this.register >> (this.length - 1) & 0b1;
    this.register <<= 1;
    this.register |= temp;
  }

  void loop_left(int count) {
    for (int i = 0; i < count; i++) {
      this.loop_left();
    }
  }

  void loop_right() {
    int temp = this.register & 0b1;
    this.register >>= 1;
    this.register |= temp << this.length;
  }

  void loop_right(int count) {
    for (int i = 0; i < count; i++) {
      this.loop_right();
    }
  }

  void lfsr_left() {
    int input = (register >> taps[0] & 0b1) ^ (register >> taps[1] & 0b1);
    register <<= 1;
    register |= input;
  }

  void lfsr_left(int count) {
    for (int i = 0; i < count; i++) {
      this.lfsr_left();
    }
  }

  void lfsr_right() {
    int input = (register >> taps[0] & 0b1) ^ (register >> taps[1] & 0b1);
    register >>= 1;
    register |= input << this.length;
  }

  void lfsr_right(int count) {
    for (int i = 0; i < count; i++) {
      this.lfsr_left();
    }
  }

  void randomize() {
    this.randomize_register();
    this.randomize_taps();
  }

  void randomize_register() {
    this.register = floor(random(int(pow(2, this.length))));
  }

  void randomize_taps() {
    int candidate;
    for (int i = 0; i < this.taps.length; i++) {
      candidate = floor(random(1, this.length));
      if (i == 0) {
        taps[i] = candidate;
      } else {
        while (candidate == taps[0]) {
          candidate = floor(random(1, this.length));
        }
        taps[i] = candidate;
      }
    }
  }

  void set() {
  }

  int get() {
    return this.register;
  }

  int get(int q) {
    return this.register >> q & 0b1;
  }
}
