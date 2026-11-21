// Zosenerdambrug sign

$fn = $preview ? 32 : 64;

// Parameters
text_str = "ZOSENERDAMBRUG";
fontname = "Liberation Sans";
fontsize = 40;
th = 5;
fillet = 2;
bbox = [600, 100];

// Main module
module bridge_name(bbox_dims, fillet_radius, thickness, text_str, text_size) {
    union() {
        color("Orange")
            plank(bbox_dims, thickness, fillet_radius);
        translate([0, 0, thickness - 0.01])
            color("Teal")
                letters(text_str, text_size, thickness);
    }
}

// Text
module letters(text_str, text_size, thickness) {
    linear_extrude(height=thickness)
        text(text_str, font=fontname, size=text_size, halign="center", valign="center");
}

// Rounded rectangular plank
module plank(bbox_dims, thickness, fillet_radius) {
    translate([-bbox_dims[0] / 2, -bbox_dims[1] / 2, 0])
        minkowski() {
            cube([bbox_dims[0], bbox_dims[1], thickness - 1]);
            cylinder(r=fillet_radius, h=1);
        }
}

// Render the sign
bridge_name(bbox_dims=bbox, fillet_radius=fillet, thickness=th, text_str=text_str, text_size=fontsize);
