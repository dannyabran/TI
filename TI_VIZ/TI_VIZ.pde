import processing.sound.*;
import processing.serial.*;

SoundFile song;
String[] songs;
String[] max_amps;
int curr_song = 0;
Amplitude amp;
BeatDetector beats;

float amp_value;
float min_amp = 0, max_amp = 0.75;

//---------------------------------------------- flowfield
int scale = 50;
int cols, rows;

PVector[] flowfield;
float xy_inc = 0.05, z_inc = 0.0001;
float x_off, y_off, z_off = 0;

//---------------------------------------------- partículas
ArrayList<particle> particles;

Serial port;

void setup() {

  fullScreen(P3D);
  colorMode(HSB);
  strokeCap(ROUND);

  songs = loadStrings("songs/songs.txt");
  max_amps = loadStrings("songs/amplitudes.txt");
  song = new SoundFile(this, "songs/"+songs[0]+".wav");
  max_amp = float(max_amps[0]);

  amp = new Amplitude(this);
  beats = new BeatDetector(this);

  song.play();
  amp.input(song);
  beats.input(song);
  beats.sensitivity(1);

  //---------------------------------------------- grelha de vetores
  cols = floor(width/scale);
  rows = floor(height/scale);
  flowfield = new PVector[cols * rows];
  particles = new ArrayList<particle>();

  port = new Serial(this, "/dev/cu.usbserial-1110", 9600);
  port.bufferUntil(10);

  background(0);
}

void draw() {

  amp_value = amp.analyze();

  fill(map(amp_value, min_amp, max_amp, 0, 10), map(amp_value, min_amp, max_amp, 60, 30));
  noStroke();
  rect(0, 0, width, height);

  //---------------------------------------------- preencher flowfield com vetores
  x_off = 0;
  for (int x = 0; x < cols; x++) {

    y_off = 0;
    for (int y = 0; y < rows; y++) {

      float ang = noise(x_off, y_off, z_off) * TWO_PI * 8;
      PVector vector = PVector.fromAngle(ang);
      vector.setMag(1);

      flowfield[x + y * cols] = vector;

      y_off += xy_inc;
    }

    x_off += xy_inc;
    z_off += map(amp_value, min_amp, max_amp, z_inc * 10, z_inc);
  }

  if ((beats.isBeat() || amp_value >= max_amp-0.2) && particles.size() < 5000) {
    for (int i = 0; i < int(map(amp_value, min_amp, max_amp, 1, 10)); i++) {
      particles.add(new particle(amp_value, new PVector(width/2, height/2)));
    }

    for (int i = 0; i < particles.size(); i++) {
      particle p = particles.get(i);

      if (random(1) <= 0.01) {
        strokeWeight(map(amp_value, min_amp, max_amp, 1, 2));
        stroke((map(amp_value, min_amp, max_amp, 0, 255) + frameCount) % 255, 255, 255, map(amp_value, min_amp, max_amp, 0, 30));

        particle p2 = particles.get(int(random(particles.size())));

        for (int j = 0; j < int(map(amp_value, min_amp, max_amp, 1, 4)); j++) {
          line(p.pos.x + random(-10, 10), p.pos.y + random(-10, 10), p2.pos.x + random(-10, 10), p2.pos.y + random(-10, 10));
        }
      }
    }
  }

  if (particles.size() > 0) {

    for (int i = 0; i < particles.size(); i++) {
      particle p = particles.get(i);

      p.update(amp_value);
      p.follow(flowfield);
      p.display(amp_value);


      if (p.outsideScreen() || p.isDead()) particles.remove(i);
    }
  }

  String msg = song.isPlaying() ? ""+map(amp_value, 0, max_amp, 0, 550)+"\n" : ""+0+"\n";
  port.write(msg);

  if ( port.available() > 0) {  // If data is available,
    String val = port.readStringUntil('\n');

    if (val != null) {
      String[] pieces = val.split(",");
      String myString = pieces[0];
      int input = Integer.parseInt(pieces[1].trim());
      println("myString: " + myString);
      println("input: " + input);

      if (myString.equals("Play") && !song.isPlaying()) {
        println("PLAY");
        song.play();
      } else if (myString.equals("Pause") && song.isPlaying()) {
        song.pause();
      }

      if (input == 3) {
        song.stop();

        curr_song++;
        curr_song %= songs.length;

        song = new SoundFile(this, "songs/"+songs[curr_song]+".wav");
        max_amp = float(max_amps[curr_song]);

        amp.input(song);
        beats.input(song);

        song.play();
      } else if (input == 2) {
        song.stop();

        curr_song--;
        if (curr_song < 0) {
          curr_song = songs.length-1;
        }

        song = new SoundFile(this, "songs/"+songs[curr_song]+".wav");
        max_amp = float(max_amps[curr_song]);

        amp.input(song);
        beats.input(song);

        song.play();
      }
    }
  }
}
