// Converts the image into a binary image, finds the contours of each blob, and then fits
// a polygon to each external contour.

import boofcv.processing.*;
import boofcv.struct.image.*;
import georegression.struct.point.*;
import java.util.*;
import processing.video.*;
Movie myMovie;

boolean movieInit = false;

//PImage input;
List<List<Point2D_I32>> polygons;

void setup() {

  size(200, 200);
  myMovie = new Movie(this, "woman_short.mov");
  myMovie.loop();
}

void draw() {
  // Toggle between the background image and a solid color for clarity
  //if ( mousePressed ) {
    background(0);
  /*} else {
    image(myMovie, 0, 0);
  }*/

  // Configure the line's appearance
  noFill();
  strokeWeight(3);
  stroke(255, 0, 0);

  // Draw each polygon
  // Point2D_I32 is a class from boof, similiar to PVector
  // it is 2D, i.e. has only x and y coordinates
  // I32 (probably) means that its coordinates are 32-bit integers (whole numbers)
  try {
    for ( List<Point2D_I32> poly : polygons ) {
      beginShape();
      for ( Point2D_I32 p : poly) {
        vertex( p.x, p.y );
      }
      // close the loop
      Point2D_I32 p = poly.get(0);
      vertex( p.x, p.y );
      endShape();
    }
  } catch(Exception e) {
    e.printStackTrace();
  }
}

void movieEvent(Movie m) {
  m.read();
  if (!movieInit) {
    //sets the size of the window
    surface.setSize(myMovie.width, myMovie.height);
    movieInit = true;
  }
  calcPolygon();
}

void calcPolygon() {
  // Convert the image into a simplified BoofCV data type
  SimpleGray gray = Boof.gray(myMovie, ImageDataType.F32);

  // Find the initial set of contours automatically select a threshold
  // using the Otsu method
  SimpleContourList contours = gray.thresholdOtsu(false).erode8(1).contour().getContours();

  // filter contours which are too small
  List<SimpleContour> list = contours.getList();
  List<SimpleContour> prunedList = new ArrayList<SimpleContour>();

  for ( SimpleContour c : list ) {
    if ( c.getContour().external.size() >= 200 ) {
      prunedList.add( c );
    }
  }

  // create a new contour list
  contours = new SimpleContourList(prunedList, myMovie.width, myMovie.height);

  // Fit polygons to external contours
  polygons = contours.fitPolygons(true, 0.05, 0.01);
}
