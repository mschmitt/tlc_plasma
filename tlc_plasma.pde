/*

Arduino Plasma
--------------

Status: Work in progress

This is for an illumination project I'm planning. Currently the sketch
displays on a cheaply hacked 8x8 matrix of 5-cent LEDs, with 4 daisy-
chained TLC5940 ICs.

The plasma animation is calculated on-chip in real time.

Requires the TLC5940 library: http://code.google.com/p/tlc5940arduino/

Demo video of prototype matrix: http://www.youtube.com/watch?v=zahPSRlVl9s

*/


#include "Tlc5940.h"

float offset = 0;                             // Starting value for plasma calculation
float offsetIncrement = 0.5;                  // Increment per loop iteration
int width = 8;                                // Matrix width
int height = 8;                               //   and height
int correctedLuminance[256];                  // Array holds gamma corrected luminance

void setup()
{
  Tlc.init();
  Serial.begin(9600);
  Serial.println("Start");
  
  // Calculate gamma-corrected luminance values
  //   This is way too quick&dirty and should be stored in flash mem, really.
  int correctGamma = 1; // Switch to quickly skip gamma correction for testing.
  for (int i=0; i < 256; i++){
    if (1 == correctGamma){
      /*
      gnuplot> set xrange[0:256]
      gnuplot> set yrange[0:256]
      gnuplot> xmax = 256
      gnuplot> power = 4
      gnuplot> f(x) = x**power / xmax**(power-1)
      gnuplot> plot f(x)
      */
      correctedLuminance[i] = pow(i, 4) / pow(256, 3);
    }else{
      correctedLuminance[i] = i;
    }
    Serial.print(i);
    Serial.print(" ");
    Serial.println(correctedLuminance[i]);
  }
}

void drawpixel(int x, int y, unsigned long luminance){
  unsigned int real_luminance = luminance;
  real_luminance = correctedLuminance[luminance] * 16;
  int real_channel = x * width + y;
  Tlc.set(real_channel, real_luminance);
}

// Distance calculation.
float dist(float a, float b, float c, float d){
  float dist;
  dist = sqrt((a - c) * (a - c) + (b - d) * (b - d));
  return dist;
}

void loop() { 
  offset += offsetIncrement;
  // Serial.println(offset);
  for (int x=0; x < width; x++){ 
    for(int y=0; y < height; y++){
      unsigned int luminance = 0;
      luminance = luminance + 128 + 128 * sin(dist(x + offset, y, 3, 3) / 2);
      luminance = luminance + 128 + 128 * sin(dist(x, y, 4, 4 ) / 2);
      luminance = luminance + 128 + 128 * sin(dist(x, y, 8, 6 ) / 3);
      luminance = luminance + 128 + 128 * sin(dist(x, y + offset * 0.8, 8, 7) / 2 );
      luminance = int(luminance/4);
      drawpixel (x, y, luminance);
      // Serial.print(x);
      // Serial.print(" ");
      // Serial.println(y);
    }
  }
  Tlc.update();
  if (offset > 65535){ 
    offset = 0; // To keep numbers low.
  }
  delay(0);
}

/*
Copyright (c) 2011, Martin Schmitt < mas at scsy dot de >

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/
