// hinge_body_cap.scad — fully refactored, idiomatic version
// Identical geometry and behavior to original
// Naming now uses snake_case throughout

$fn = 30;
extra_clearance = 0.3;

// Hex parameters
hex_diameter = 7.62;
hex_height = 12;
hex_thickness = 2;

// Overall body dimensions
body_height = 86;
body_width = 61;
cap_depth = 28;

// Derived constants
hex_spacing = hex_diameter * (0.5 + 2 * sin(30)) / 2 + hex_thickness / 2;

// ------------------------------------------------------
// Build
// ------------------------------------------------------
body();
//cap();

// ------------------------------------------------------
// Modules
// ------------------------------------------------------

module body() {
  difference() {
    union() {
      translate([-hex_spacing, -body_height / 2])
        cube([body_width, body_height, 11]);
      hinge_pin();
    }
    block();
  }
}

module cap() {
  difference() {
    translate([0, 0, cap_depth]) {
      translate([-hex_spacing, -body_height / 2 - 2])
        cube([body_width, body_height + 4, 2]);

      // mirrored side flanges
      for (m = [0, 1])
        mirror([0, m, 0])
          translate([-hex_spacing, body_height / 2 + 0.5, -cap_depth])
            cube([body_width, 2, cap_depth + 2]);
    }

    slice_cut();
    hinge_pin(negative=true);
  }

  // mirrored washers
  for (m = [0, 1])
    mirror([0, m, 0])
      translate([-1, body_height / 2 + 3, hex_height / 2])
        washer();
}

module hinge_pin(negative = false) {
  translate([-1, 0, hex_height / 2])
    rotate([90, 0, 0]) if (negative) {
      cylinder(d=7 + extra_clearance, h=body_height + 4, center=true);
      cylinder(d=3 + extra_clearance, h=body_height + 20, center=true);
    } else {
      difference() {
        cylinder(d=7, h=body_height + 4, center=true);
        cylinder(d=3, h=body_height + 20, center=true);
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
      cube([21, body_height + 10, 21], center=true);
}

module block() {
  translate([0, 3.8 / 2])for (col = [0:7])
    translate([col * hex_spacing, (col % 2) * 3.8])
      cell_column();
}

module cell_column() {
  for (row = [-5:4])
    translate([0, hex_diameter * row, 0])
      cell();
}

module cell(negative = true) {
  if (negative) {
    inner_hollow();
  } else {
    difference() {
      cylinder(d=hex_diameter + hex_thickness, h=hex_height, $fn=6);
      inner_hollow();
    }
  }
}

module inner_hollow() {
  translate([0, 0, 2])
    cylinder(d=hex_diameter, h=hex_height, $fn=6);
  translate([0, 0, -0.01])
    cylinder(d=3, h=3);
}
