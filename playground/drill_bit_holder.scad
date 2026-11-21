// hinge_body_cap.scad — fully refactored, idiomatic version
// Identical geometry and behavior to original
// Naming now uses snake_case throughout

$fn = $preview ? 32 : 64;
z_fight = $preview ? 0.05 : 0;

// Render control
show_base = true;
show_lid = true;

// Tolerances
extra_clearance = 0.3;

// Hex parameters
hex_diameter = 7.62;
hex_floor_height = 1;
hex_thickness = 2;

// Overall body dimensions
body_width = 100;
body_length = 80;
body_height = 12;
body_min_wall_thickness = 2;

lid_height = 20;
lid_thickness = 2;

gap_distance = 0.5; // gap between body and lid when closed

// Derived constants
hex_spacing = hex_diameter * (gap_distance + 2 * sin(30)) / 2 + hex_thickness / 2;

n_hex = floor((body_width - 2 * body_min_wall_thickness) / hex_diameter);
m_hex = floor((body_length - 2 * body_min_wall_thickness) / hex_spacing);
echo(str("n_hex: ", n_hex, " m_hex: ", m_hex));

real_wall_thickness_x = (body_length - (m_hex - 1) * hex_spacing - hex_diameter) / 2;
echo(str("real_wall_thickness_x: ", real_wall_thickness_x));

// ------------------------------------------------------
// Build
// ------------------------------------------------------
if (show_base)
    body();
if (show_lid)
    lid();

// ------------------------------------------------------
// Modules
// ------------------------------------------------------

module body() {
    difference() {
        // main body
        union() {
            // base cube for body
            translate([-hex_spacing, -body_width / 2])
                cube([body_length, body_width, 11]);
            // add hinge pins
            hinge_pin();
        }

        // cut out the hex holes
        block();

        // chamfer off from edges
        for (i = [0, 1])
            mirror([0, i, 0])
                translate([body_length - hex_spacing, body_width / 2 - hex_diameter / sqrt(2), -z_fight / 2])
                    rotate([0, 0, 45])
                        cube([hex_diameter, hex_diameter, body_height + z_fight]);
    }
}

module lid() {
    difference() {
        translate([0, 0, lid_height]) {
            translate([-hex_spacing, -body_width / 2 - 2])
                cube([body_length, body_width + lid_thickness * 2, lid_thickness]);

            // mirrored side flanges
            for (m = [0, 1])
                mirror([0, m, 0])
                    translate([-hex_spacing, body_width / 2 + 0.5, -lid_height])
                        cube([body_length, 2, lid_height + 2]);
        }

        slice_cut();
        hinge_pin(negative=true);
    }

    // mirrored washers
    for (m = [0, 1])
        mirror([0, m, 0])
            translate([-1, body_width / 2 + 3, body_height / 2])
                washer();
}

module hinge_pin(negative = false) {
    translate([-1, 0, body_height / 2])
        rotate([90, 0, 0]) if (negative) {
            cylinder(d=7 + extra_clearance, h=body_width + 4, center=true);
            cylinder(d=3 + extra_clearance, h=body_width + 20, center=true);
        } else {
            difference() {
                cylinder(d=7, h=body_width + 4, center=true);
                cylinder(d=3, h=body_width + 20, center=true);
            }
        }
}

module washer() {
    rotate([90, 0, 0])
        difference() {
            cylinder(d=9, h=2, center=true);
            cylinder(d=3, h=3, center=true);
        }
}

module slice_cut() {
    translate([-12, 0, -5])
        rotate([0, 45, 0])
            cube([21, body_width + 10, 21], center=true);
}

module block() {
    translate([0, real_wall_thickness_x / 2])for (col = [0:m_hex - 1])
        translate([col * hex_spacing, (col % 2) * 3.8])
            cell_column();
}

module cell_column() {
    range = [0 - round((n_hex + 0.1) / 2):n_hex - round((n_hex + 0.1) / 2) - 1];
    for (row = range)
        translate([0, hex_diameter * row, 0])
            cell();
}

module cell(negative = true) {
    if (negative) {
        inner_hollow();
    } else {
        difference() {
            cylinder(d=hex_diameter + hex_thickness, h=body_height - hex_floor_height, $fn=6);
            inner_hollow();
        }
    }
}

module inner_hollow() {
    translate([0, 0, 2])
        cylinder(d=hex_diameter, h=body_height - hex_floor_height, $fn=6);
    translate([0, 0, -0.01])
        cylinder(d=3, h=3);
}
