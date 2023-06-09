#include <FastLED.h>

int r = 152;
int g = 0;
int b = 80;

int bri = 0;

int max = 0;
int min = 1023;

int max2 = 0;
int min2 = 1023;

const int buttonPlay = 8;
const int buttonNext = 9;
const int buttonPrev = 10;

int state = 0;

int buttonState = 0;

String sv;

#define LED_PIN 7
#define NUM_LEDS 288

CRGB leds[NUM_LEDS];
CRGB led[NUM_LEDS];
int s = 0;

void setup() {

  FastLED.addLeds<WS2812, LED_PIN, GRB>(leds, NUM_LEDS);
  for (int i = NUM_LEDS / 2; i >= 0; i--) {
    leds[i] = CRGB(r, g, b);
    leds[NUM_LEDS - i] = CRGB(r, g, b);
    FastLED.show();
  }
  Serial.begin(9600);

  pinMode(buttonPlay, INPUT_PULLUP);
  pinMode(buttonNext, INPUT_PULLUP);
  pinMode(buttonPrev, INPUT_PULLUP);
}
void loop() {
  while (Serial.available() > 0) {

    if (digitalRead(buttonPlay) == LOW) {
      if (buttonState == 1) {
        buttonState = 2;
      } else {
        buttonState = 1;
      }
    }

    if (buttonState == 1) {
      sv = "Play";
    } else if (buttonState == 2) {
      sv = "Pause";
    }


    if (digitalRead(buttonNext) == LOW) {
      state = 2;
    } else {
      state = 0;
    }

    if (digitalRead(buttonPrev) == LOW) {
      state = 3;
    }

    Serial.print(sv);
    Serial.print(",");
    Serial.println(state);

    
    int sensor = analogRead(A0);

    if (sensor > max2) {
      max2 = sensor;
    }

    if (sensor < min2) {
      min2 = sensor;
    }

    bri = map(sensor, min2, max2, 0, 180);

    String str = Serial.readStringUntil('\n');
    str.trim();

    int ss = str.toInt();
    if (ss > max) {
      max = ss;
    }

    if (ss < min) {
      min = ss;
    }

    s = ss;

    if ((s >= 450) && (s <= 550)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(0, 0, 255);
      leds[NUM_LEDS / 2] = CRGB(0, 0, 255);
    } else if ((s >= 400) && (s <= 450)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(153, 153, 0);
      leds[NUM_LEDS / 2] = CRGB(153, 153, 0);
    } else if ((s >= 350) && (s <= 400)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(255, 50, 255);
      leds[NUM_LEDS / 2] = CRGB(255, 50, 255);
    } else if ((s >= 300) && (s <= 350)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(10, 25, 217);
      leds[NUM_LEDS / 2] = CRGB(10, 25, 217);
    }

    else if ((s >= 276) && (s <= 300)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(50, 50, 150);
      leds[NUM_LEDS / 2] = CRGB(50, 50, 150);
    } else if ((s >= 250) && (s <= 275)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(230, 0, 10);
      leds[NUM_LEDS / 2] = CRGB(230, 0, 10);
    } else if ((s >= 235) && (s <= 250)) {
      leds[(NUM_LEDS / 2) - 1] = CRGB(0, 160, 0);
      leds[NUM_LEDS / 2] = CRGB(0, 160, 0);
    }
    for (int i = 0; i <= ((NUM_LEDS / 2) - 2); i++) {
      leds[i] = leds[i + 1];
      leds[NUM_LEDS - 1 - i] = leds[(NUM_LEDS)-i - 2];
    }
    FastLED.setBrightness(bri);
    FastLED.show();
  }
}