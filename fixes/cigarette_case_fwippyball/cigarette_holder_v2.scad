$fn = 128; //make it pretty

cylnumber = 4; //how many cylinders
cyldiam = 12; //diameter of the cylinders
cyloffset = 10.5; //distance between cylinder centers
fildiam = 3; //diameter of fillet circles
holderheight = 65; //inner height of the holder
lidoverlap = 20; //overlap of the lid and holder
lidheight = 45; //inner height of the lid
cylthick = 1; //thickness of plastic surrounding cylinders
cyltol = 0.01; //tolerance of lid fit
outerchamf = .2; //outer chamfer depth

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

//generates chamfers (note: I got this code from a friend and it only chamfers the top of a part, so I have to flip parts to chamfer the bottom)
module chamfer(h, chamfer) {
  if (chamfer > 0)
    intersection() {
      linear_extrude(h) children();
      union() {
        if (h - chamfer > 0) linear_extrude(h - chamfer) children();
        translate([0, 0, h - chamfer]) roof() children();
      }
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
      translate([0, 0, 1 + holderheight])
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
    translate([0, 0, 1 + holderheight])
      mirror([0, 0, 1])
        chamfer(holderheight, 1)
          offset(-cylthick + cyltol) {
            outline(cyldiam + cylthick);
          }
  }
}

holder();
translate([0, 20, 0])
  lid();

//cylinder(84, d=9);
