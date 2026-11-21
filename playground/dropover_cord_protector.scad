use <../scripts/trapezium.scad>

$fn = $preview ? 32 : 64;
z_fight = $preview ? 0.05 : 0;

function circular_array_shift(arr, shift) =
    let (len = len(arr)) [for (i = [0:len - 1]) arr[ (i + shift) % len]];

function square_pts(width, height) =
    [
        [width / 2, 0],
        [width / 2, height],
        [-width / 2, height],
        [-width / 2, 0],
    ];

cord_cross_section_bounding_width = 12;
cord_cross_section_bounding_height = 6;
length = 300;
wall_thickness = 6;

module cord_protector(allow = 0.4, trap_length_factor = 0.95) {

    trap_width = cord_cross_section_bounding_width * 5;
    trap_height = cord_cross_section_bounding_height + wall_thickness;

    trap_pts = trapezium_pts(bottom_width=trap_width, height=trap_height, angle=60);

    shifted_pts = circular_array_shift(trap_pts, 1);

    // prepend points on single shifted trap pts list to insert cut out along bottom edge
    square_cut_pts = square_pts(cord_cross_section_bounding_width, cord_cross_section_bounding_height);
    cut_trap_pts = concat(square_cut_pts, shifted_pts);

    trap_length = (length * trap_length_factor);

    pinched_end_length = length - trap_length;

    module j_conn_local(w, l, h, allowance = 0) {
        // Connector end
        for (i = [0, 1])
            mirror([i, 0, 0])
                translate([w / 2, h, 0])
                    rotate([90, 0, 0])
                        j_connector(w, l, h, allowance);
    }

    //rotate([90, 0, 0])
    union() {
        difference() {
            // Main trapezium body
            linear_extrude(height=trap_length)
                polygon(cut_trap_pts);

            // Cut connectors from other side
            #translate([0, -z_fight / 2, -z_fight / 2])
                j_conn_local(w=cord_cross_section_bounding_width, l=(length * (1 - trap_length_factor)) / 2, h=cord_cross_section_bounding_height / 2, allowance=allow);
        }
        translate([0, 0, trap_length])
            j_conn_local(w=cord_cross_section_bounding_width, l=(length * (1 - trap_length_factor)) / 2, h=cord_cross_section_bounding_height / 2, allowance=allow);
    }
}

module j_connector(width, length, height, allowance = 0) {
    _width_p = width + allowance * 2;
    _length_p = length + allowance;
    _height_p = height + allowance;
    _width_n = width - allowance * 4;
    _length_n = length - allowance;
    _height_n = height - allowance;

    translate([-allowance, 0, -allowance])
        difference() {
            cube([_width_p, _length_p, _height_p]);

            translate([_width_p * 1 / 3 + allowance, -z_fight, -z_fight / 2])
                cube([_width_n * 1 / 3 + z_fight, _length_n * 3 / 4 + z_fight, _height_p + z_fight]);

            translate([-z_fight / 2, -z_fight, -z_fight / 2])
                cube([_width_p * 1 / 3 + allowance + z_fight, _length_n * 1 / 2 + z_fight, _height_p + z_fight]);
        }
}

cord_protector();

// jconn_width = cord_cross_section_bounding_width;
// jconn_length = length * 0.05;
// jconn_height = cord_cross_section_bounding_height;

// j_connector(jconn_width, jconn_length, jconn_height);

/*

    // Pinched end
    if (pinch_end) {
      difference() {
        color("blue")
          translate([0, 0, trap_length])
            linear_extrude(height=pinched_end_length, scale=1 - trap_length_factor)
              polygon(cut_trap_pts);

        // hollow out tips
        translate([0, cord_cross_section_bounding_height / 2 - z_fight / 2, trap_length + pinched_end_length])
          cube([cord_cross_section_bounding_width, cord_cross_section_bounding_height + z_fight, pinched_end_length * 2], center=true);
      }
    }
*/
