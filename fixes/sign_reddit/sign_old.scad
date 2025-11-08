 // Zosenerdambrug sign

text_str = "ZOSENERDAMBRUG";

thickness = 5;

radius = 2;

fontname = "Liberation Sans";

module bridge_name() {

// Text (extruded in 3D)

letters = linear_extrude(height = thickness)

text(text_str, font = fontname, size = 40, halign = "center")

;

// Background plank with rounded corners

bbox = [260, 50];

plank = translate([-bbox[0]/2, -bbox[1]/2, 0])

minkowski() {

cube([bbox[0], bbox[1], thickness - 1]);

cylinder(r = radius, h = 1);

}

;

// Combine plank + letters

union() {

plank;

letters;

}

}

// Call module

bridge_name(); 