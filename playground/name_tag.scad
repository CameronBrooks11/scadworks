// Name Tag Generator
//
// TODO:
// - Holes for sewing on (optional toggle)
// - Properly parameterize the text size to fit within the name tag dimensions in both directions

$fn = $preview ? 32 : 128;
z_fight = $preview ? 0.05 : 0.0;

width = 100;
height = 50;
thickness = 0.8; // 4 layers at 0.2mm each
corner_radius = 5;
outline_thickness = 2;

name_line_text = "Big D.";
sub_line_text = "Lab Tech";

difference() {
    tag_body();

    translate([0, 0, thickness / 2 + z_fight])
        labelling();
}

translate([0, 0, thickness / 2 + z_fight])
    color("black")
        labelling();

// create a arounded rectangle for the name tag and extrude it to give it thickness
// Text size scales to fit within the 80% of the width and 40% the height (to fit two lines) of the name tag
module tag_body() {
    // Create the rounded rectangle
    difference() {
        linear_extrude(height=thickness) {
            offset(r=corner_radius) {
                square([width, height], center=true);
            }
        }
    }
}

// part 2 is a diff object so print in diff color for multi mat.
module labelling() {
    union() {
        // Create the name line text
        translate([0, height * 0.1, 0]) {
            linear_extrude(height=thickness / 2) {
                text(name_line_text, size=height * 0.4, valign="center", halign="center");
            }
        }

        // Create the sub line text
        translate([0, -height * 0.3, 0]) {
            linear_extrude(height=thickness / 2) {
                text(sub_line_text, size=height * 0.2, valign="center", halign="center");
            }
        }

        // Border outline around the name tag
        linear_extrude(height=thickness / 2) {
            difference() {
                offset(r=corner_radius) {
                    square([width, height], center=true);
                }
                offset(r=corner_radius - outline_thickness / 2) {
                    square([width - outline_thickness, height - outline_thickness], center=true);
                }
            }
        }
    }
}
