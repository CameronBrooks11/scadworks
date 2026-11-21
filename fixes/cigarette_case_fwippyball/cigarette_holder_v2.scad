// Parametric cigarette case
// Customizer-ready revision of u/FwippyBall's design,
// extruded-shape math by u/oldesole1. 

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

// The cigarette fixes the closed height, so holderheight alone splits it between parts.
lidheight = 2 * cylthick + ciglength + cigclearance - (holderheight - lidoverlap);
assert(holderheight > lidoverlap, "holderheight must exceed lidoverlap - nothing left for the lid to grip");
assert(lidheight > lidoverlap + cylthick, "lid too short to cover the overlap - lower holderheight or raise lidoverlap");

module circles(diam) {
    for (i = [0:1:cylnumber - 1])
        translate([cyloffset * i, 0, 0])
            circle(d=diam);
}

//the overlapping cylinders blended into one filleted outline
module outline(diam) {
    offset(r=-fildiam)
        offset(delta=fildiam)
            circles(diam);
}

// Chamfers the top of an extrusion, or the bottom when flip is set. roof() does this
// exactly, but is experimental: absent on release builds, off by default on dev ones.
module chamfer(h, chamfer, flip = false) {
    steps = chamfer > 0 ? max(4, ceil(chamfer / 0.1)) : 0;
    translate([0, 0, flip ? h : 0])
        scale([1, 1, flip ? -1 : 1]) {
            if (h > chamfer) linear_extrude(h - chamfer) children();
            for (i = [0:1:steps - 1])
                translate([0, 0, h - chamfer + i * chamfer / steps])
                    linear_extrude(chamfer / steps + 0.001)
                        offset(delta=-(i + 0.5) * chamfer / steps)
                            children();
        }
}

module holder() {
    difference() {
        //the outer holder, and the reduced section the lid slides over
        group() {
            chamfer(holderheight, .3)
                offset(-cylthick)
                    outline(cyldiam + cylthick);
            chamfer(holderheight - lidoverlap, outerchamf, flip=true)
                outline(cyldiam + cylthick);
        }
        //the cylinder holes, then the relief under them
        translate([0, 0, cylthick])
            chamfer(holderheight, 1, flip=true)
                circles(cyldiam - 2);
        chamfer(.5, .5)
            circles(cyldiam - 2.5);
    }
}

module lid() {
    difference() {
        chamfer(lidheight, outerchamf, flip=true)
            outline(cyldiam + cylthick);
        chamfer(lidheight - cylthick, 1, flip=true)
            offset(-cylthick + cyltol)
                outline(cyldiam + cylthick);
    }
}

holder();
translate([0, 20, 0])
    lid();
