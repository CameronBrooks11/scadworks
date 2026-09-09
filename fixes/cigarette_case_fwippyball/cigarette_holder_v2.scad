/* [Capacity] */

// how many cigarettes the case holds
cylnumber = 4; // [1:1:12]
// nominal cylinder size (the bore comes out 2mm under this)
cyldiam = 12; // [6:0.5:24]
// distance between cylinder centers, below cyldiam makes them overlap
cyloffset = 10.5; // [4:0.1:24]
// length of one cigarette, this sets the closed height of the case
ciglength = 84; // [50:1:120]
// headroom above the cigarettes when the lid is shut
cigclearance = 1.5; // [0:0.1:6]

/* [Case proportions] */

// inner height of the holder, raise for a taller case and a shorter lid
holderheight = 65; // [20:1:110]
// how far the lid slides down over the holder
lidoverlap = 20; // [5:1:40]

/* [Walls and fit] */

// thickness of plastic surrounding cylinders
cylthick = 1; // [0.6:0.1:3]
// floor under the cigarettes
basefloor = 1; // [0.4:0.1:4]
// ceiling above the cigarettes, inside the lid
topwall = 1; // [0.4:0.1:4]
// tolerance of lid fit, raise this if the lid binds
cyltol = 0.01; // [0:0.01:0.4]
// radius of the fillet blending the cylinders into one outline
fildiam = 3; // [0.5:0.1:8]
// outer chamfer depth
outerchamf = .2; // [0:0.05:2]

/* [Output] */

// which part to render
part = "both"; // [both:Both laid out to print, holder:Holder only, lid:Lid only, fitcheck:Assembled with cigarette dummies]

// make it pretty
$fn = 128; // [16:8:256]

/* [Hidden] */

//vertical step size of the chamfer approximation
chamflayer = 0.1;

//DERIVED
//The cigarette sets the closed height of the case, so lidheight is not a free
//choice - holderheight alone decides how that height splits between the parts.
innerlength = basefloor + ciglength + cigclearance;
lidheight = innerlength + topwall - (holderheight - lidoverlap);

assert(holderheight > lidoverlap + 3, "holderheight must exceed lidoverlap - no reduced section left for the lid to grip");
assert(lidheight > lidoverlap + topwall, "lid too short to cover the overlap - lower holderheight or raise lidoverlap");

//NECESSARY MODULES

//generates offset circles
module circles(diam) {
  for (i = [0:1:cylnumber - 1]) {
    translate([cyloffset * i, 0, 0])
      circle(d=diam);
  }
}

//does the weird math for the shape
module radius(amount) {
  offset(r=amount)
    offset(delta=-amount)
      children();
}

//creates holder outline
module outline(diam) {
  radius(-fildiam)
    circles(diam);
}

// Chamfers the top of an extruded 2D profile, flip the part to chamfer a bottom.
// The original used roof(), which is an EXPERIMENTAL builtin: absent on release
// builds and off by default on dev snapshots. When it is missing OpenSCAD only
// warns and carries on, so the original silently lost its taper and every
// extrusion came out short. Stacked inward offsets need no feature flag.
module chamfer(h, chamfer, layer=chamflayer) {
  if (chamfer > 0) {
    steps = max(4, ceil(chamfer / layer));
    step = chamfer / steps;
    linear_extrude(h - chamfer) children();
    translate([0, 0, h - chamfer])
      for (i = [0:1:steps - 1])
        translate([0, 0, i * step])
          linear_extrude(step + 0.001)
            offset(delta=-(i + 0.5) * step)
              children();
  }
  else {
    linear_extrude(h) children();
  }
}

//generates holder model
module holder() {
  //carve out bottom inner chamfered holes
  difference() {
    //carve out cylinder holes
    difference() {
      //group the outer holder and under-lid holder
      group() {
        translate([0, 0, 3])
          chamfer(holderheight - 3, .3)
            offset(-cylthick) {
              outline(cyldiam + cylthick);
            }
        translate([0, 0, holderheight - lidoverlap])
          mirror([0, 0, 1])
            chamfer(holderheight - lidoverlap, outerchamf)
              outline(cyldiam + cylthick);
      }
      translate([0, 0, basefloor + holderheight])
        mirror([0, 0, 1])
          chamfer(holderheight, 1)
            circles(cyldiam - 2);
    }
    chamfer(.5, .5)
      circles(cyldiam - 2.5);
  }
}

//generates lid model
module lid() {
  //carve out holder space + fit tolerance
  difference() {
    translate([0, 0, lidheight])
      mirror([0, 0, 1])
        chamfer(lidheight, outerchamf)
          outline(cyldiam + cylthick);
    translate([0, 0, lidheight - topwall])
      mirror([0, 0, 1])
        chamfer(lidheight - topwall, 1)
          offset(-cylthick + cyltol) {
            outline(cyldiam + cylthick);
          }
  }
}

if (part == "both" || part == "holder") holder();
if (part == "both" || part == "lid")
  translate([0, 20, 0])
    lid();

//drops the lid onto the shoulder and shows cigarette stand-ins, to check fit
if (part == "fitcheck") {
  holder();
  translate([0, 0, holderheight - lidoverlap]) lid();
  #for (i = [0:1:cylnumber - 1])
    translate([cyloffset * i, 0, basefloor])
      cylinder(ciglength, d=9);
}
