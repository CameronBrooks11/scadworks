// Parametric cigarette case - Customizer-ready revision of u/FwippyBall's design,
// extruded-shape math by u/oldesole1. Runs on stock OpenSCAD, no experimental features.

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
// plastic surrounding the cylinders, also the floor and the lid ceiling
cylthick = 1; // [0.6:0.1:3]
// tolerance of lid fit, raise this if the lid binds
cyltol = 0.01; // [0:0.01:0.4]
// diameter of fillet circles
fildiam = 3; // [0.5:0.1:8]
// outer chamfer depth
outerchamf = .2; // [0:0.05:2]

/* [Hidden] */
$fn = 128; //make it pretty

// The cigarette fixes the closed height, so lidheight is not a free choice -
// holderheight alone decides how that height splits between the two parts.
lidheight = 2 * cylthick + ciglength + cigclearance - (holderheight - lidoverlap);
assert(holderheight > lidoverlap + 3, "holderheight must exceed lidoverlap - nothing left for the lid to grip");
assert(lidheight > lidoverlap + cylthick, "lid too short to cover the overlap - lower holderheight or raise lidoverlap");

//generates offset circles
module circles(diam) {
  for (i = [0:1:cylnumber - 1])
    translate([cyloffset * i, 0, 0]) circle(d=diam);
}

//does the weird math for the shape
module radius(amount) {
  offset(r=amount) offset(delta=-amount) children();
}

//creates holder outline
module outline(diam) {
  radius(-fildiam) circles(diam);
}

// Chamfers the top of an extrusion, flip the part to chamfer a bottom. roof() does
// this exactly but is an experimental builtin - absent on release builds, off by
// default on dev snapshots, and only warned about, so the original rendered short.
module chamfer(h, chamfer, layer = 0.1) {
  steps = max(4, ceil(chamfer / layer));
  if (h > chamfer) linear_extrude(h - chamfer) children();
  if (chamfer > 0)
    for (i = [0:1:steps - 1])
      translate([0, 0, h - chamfer + i * chamfer / steps])
        linear_extrude(chamfer / steps + 0.001)
          offset(delta=-(i + 0.5) * chamfer / steps)
            children();
}

//generates holder model
module holder() {
  difference() {
    //group the outer holder and under-lid holder
    group() {
      translate([0, 0, 3]) chamfer(holderheight - 3, .3) offset(-cylthick) outline(cyldiam + cylthick);
      translate([0, 0, holderheight - lidoverlap]) mirror([0, 0, 1]) chamfer(holderheight - lidoverlap, outerchamf) outline(cyldiam + cylthick);
    }
    //carve out cylinder holes, then the bottom inner chamfered holes
    translate([0, 0, cylthick + holderheight]) mirror([0, 0, 1]) chamfer(holderheight, 1) circles(cyldiam - 2);
    chamfer(.5, .5) circles(cyldiam - 2.5);
  }
}

//generates lid model
module lid() {
  //carve out holder space + fit tolerance
  difference() {
    translate([0, 0, lidheight]) mirror([0, 0, 1]) chamfer(lidheight, outerchamf) outline(cyldiam + cylthick);
    translate([0, 0, lidheight - cylthick]) mirror([0, 0, 1]) chamfer(lidheight - cylthick, 1) offset(-cylthick + cyltol) outline(cyldiam + cylthick);
  }
}

holder();
translate([0, 20, 0])
  lid();
