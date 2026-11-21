use <../scripts/cross_section.scad>;

$fn = $preview ? 32 : 64;
z_fight = $preview ? 0.05 : 0;

// Number 8 threaded rod
rod_diameter = 8;

// Number 8 nut
nut_flat_to_flat = 13;
nut_height = 6.6;

// Connector options
wall_thickness = 2.8;
allowance = 1.0;
num_nuts = 4; // haha get it num nuts

module connecting_rod() {
    connector_height = nut_height * (num_nuts + 1); // nuts height gap before and after

    pocket_height = connector_height - nut_height * 1 + allowance * 2;

    difference() {
        cylinder(d=nut_flat_to_flat + 2 * wall_thickness, h=connector_height, center=true, $fn=6);

        cylinder(d=nut_flat_to_flat + allowance * 2, h=pocket_height + z_fight, center=true, $fn=6);

        // Rod hole
        cylinder(d=rod_diameter + allowance, h=connector_height + z_fight, center=true);
    }
}

cross_section($preview)
    connecting_rod();
