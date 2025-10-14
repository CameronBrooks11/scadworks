use <../scripts/rounded_box.scad>;
use <../scripts/internal_corner_fillet.scad>;

$fn = $preview ? 32 : 64; // Smoothness of circles
z_fight = $preview ? 0.05 : 0; // Small offset to prevent z-fighting in preview mode

module main_body(width, height, depth, wall_thickness) {
  fillet_radius = wall_thickness * 1.5;

  outer_width = width + wall_thickness * 2;
  outer_height = height + wall_thickness * 2 + fillet_radius;
  outer_depth = depth;
  translate([0, 0, height / 2])
    rotate([90, 0, 0])

      difference() {
        rounded_box([outer_width, outer_height, outer_depth], radius=fillet_radius);
        translate([0, outer_height / 2 - fillet_radius / 2 + z_fight, outer_depth / 2])
          cube([outer_width, fillet_radius + z_fight, outer_depth + z_fight], center=true);
      }
}

module negative_cut(width, height, depth, wall_thickness, internal_width) {
  fillet_radius = wall_thickness * 1.5;
  translate([0, z_fight / 2, height / 2])
    rotate([90, 0, 0])
      union() {
        color("orange")
          rounded_box([width, height, depth + z_fight], radius=fillet_radius - wall_thickness);

        // Add internal corner fillets
        for (i = [0:1])
          mirror([i, 0, 0])
            color("blue")
              translate([-fillet_radius - internal_width / 2, -height / 2 - fillet_radius / 2, 0])
                linear_extrude(depth + z_fight)
                  internal_corner_fillet(fillet_radius + z_fight, fillet_radius / 2 + z_fight, fillet_fn=32);

        // Main lower cut gap
        color("green")
          translate([-internal_width / 2, -height / 2 - wall_thickness - z_fight / 2, 0])
            linear_extrude(depth + z_fight)
              square([internal_width, wall_thickness + z_fight], center=false);
      }
}

module holder(width, height, depth, wall_thickness, internal_width) {
  difference() {
    main_body(width, height, depth, wall_thickness);

    translate([0, 0, -wall_thickness * 0.75])
      color("red") negative_cut(width, height, depth, wall_thickness, internal_width);

    // holes along the top to mount
    for (j = [-2:2])
      for (i = [-1:1])
        translate([i * (width / 2 - wall_thickness * 4), -depth / 2 * (j / 3) - depth / 2, height])
          cylinder(h=wall_thickness * 2, d=5, center=true, $fn=32);
  }
}

// Example Usage
width_ex = 76;
height_ex = 76;
depth_ex = 150;
wall_thickness_ex = 4;
internal_width_ex = 44;

translate([0, 0, wall_thickness_ex * 1.75])
  holder(width_ex, height_ex, depth_ex, wall_thickness_ex, internal_width_ex);
