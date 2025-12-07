IntDict notes = new IntDict();

// assumes 44.1Khz sample rate

String[][] D_dorian = {
  {
    "D1",
    "E1",
    "F1",
    "G1",
    "A1",
    "B1",
    "C2",
    "D2"
  },
  {
    "D2",
    "E2",
    "F2",
    "G2",
    "A2",
    "B2",
    "C3",
    "D3"
  },
  {
    "D3",
    "E3",
    "F3",
    "G3",
    "A3",
    "B3",
    "C4",
    "D4"
  },
  {
    "D4",
    "E4",
    "F4",
    "G4",
    "A4",
    "B4",
    "C5",
    "D5"
  },
  {
    "D5",
    "E5",
    "F5",
    "G5",
    "A5",
    "B5",
    "C6",
    "D6"
  },
};

String[][] B_locrian = {
  {
    "B0",
    "C1",
    "D1",
    "E1",
    "F1",
    "G1",
    "A1",
    "B1"
  },
  {
    "B1",
    "C2",
    "D2",
    "E2",
    "F2",
    "G2",
    "A2",
    "B2"
  },
  {
    "B2",
    "C3",
    "D3",
    "E3",
    "F3",
    "G3",
    "A3",
    "B3"
  },
  {
    "B3",
    "C3",
    "D3",
    "E3",
    "F3",
    "G3",
    "A3",
    "B4"
  },
  {
    "B4",
    "C4",
    "D4",
    "E4",
    "F4",
    "G4",
    "A4",
    "B5"
  },
  {
    "B5",
    "C5",
    "D5",
    "E5",
    "F5",
    "G5",
    "A5",
    "B6"
  },
};

void populate_notes() {
  notes.set("F#0", 1907);
  notes.set("G0", 1800);
  notes.set("G#0", 1699);
  notes.set("A0", 1604);
  notes.set("A#0", 1513);
  notes.set("B0", 1429);
  notes.set("C1", 1349);
  notes.set("C1#", 1273);
  notes.set("D1", 1201);
  notes.set("D1#", 1134);
  notes.set("E1", 1070);
  notes.set("F1", 1010);
  notes.set("F#1", 954);
  notes.set("G1", 900);
  notes.set("G#1", 849);
  notes.set("A1", 802);
  notes.set("A#1", 757);
  notes.set("B1", 714);
  notes.set("C2", 674);
  notes.set("C#2", 636);
  notes.set("D2", 601);
  notes.set("D#2", 567);
  notes.set("E2", 535);
  notes.set("F2", 505);
  notes.set("F#2", 477);
  notes.set("G2", 450);
  notes.set("G#2", 425);
  notes.set("A2", 401);
  notes.set("A#2", 378);
  notes.set("B2", 354);
  notes.set("C3", 337);
  notes.set("C#3", 318);
  notes.set("D3", 300);
  notes.set("D#3", 289);
  notes.set("E3", 268);
  notes.set("F3", 253);
  notes.set("F#3", 238);
  notes.set("G3", 225);
  notes.set("G#3", 212);
  notes.set("A3", 200);
  notes.set("A#3", 189);
  notes.set("B3", 179);
  notes.set("C4", 169);
  notes.set("C#4", 159);
  notes.set("D4", 150);
  notes.set("D#4", 142);
  notes.set("E4", 134);
  notes.set("F4", 126);
  notes.set("F#4", 119);
  notes.set("G4", 112);
  notes.set("G#4", 106);
  notes.set("A4", 100);
  notes.set("A#4", 95);
  notes.set("B4", 89);
  notes.set("C5", 84);
  notes.set("C#5", 80);
  notes.set("D5", 75);
  notes.set("D#5", 71);
  notes.set("E5", 67);
  notes.set("F5", 63);
  notes.set("F#5", 60);
  notes.set("G5", 56);
  notes.set("G#5", 53);
  notes.set("A5", 50);
  notes.set("A#5", 47);
  notes.set("B5", 45);
  notes.set("C6", 42);
  notes.set("C#6", 40);
  notes.set("D6", 38);
  notes.set("D#6", 35);
  notes.set("E6", 33);
  notes.set("F6", 32);
  notes.set("F#6", 30);
  notes.set("G6", 28);
  notes.set("G#6", 27);
  notes.set("A6", 25);
  notes.set("A#6", 24);
  notes.set("B6", 22);
  notes.set("C7", 21);
  notes.set("C#7", 20);
  notes.set("D7", 19);
  notes.set("D#7", 18);
  notes.set("E7", 17);
  notes.set("F7", 16);
  notes.set("F#7", 15);
  notes.set("G7", 14);
  notes.set("G#7", 13);
  notes.set("A#7", 12);
  notes.set("B7", 11);
  notes.set("C#8", 10);
  notes.set("D#8", 9);
  notes.set("F8", 8);
  notes.set("G8", 7);
  notes.set("A#8", 6);
  notes.set("C#9", 5);
  notes.set("F9", 4);
  notes.set("A#9", 3);
  notes.set("F10", 2);
}
