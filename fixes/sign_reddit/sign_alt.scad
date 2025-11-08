// Zosenerdambrug sign

text_str = "ZOSENERDAMBRUG";
thickness = 5;
radius = 12;
fontname = "Liberation Sans";
bbox = [580, 50];

module bridge_name() {
  // Text (extruded in 3D)
  color("DarkSalmon")
    linear_extrude(height=thickness)
      text(text_str, font=fontname, size=40, halign="center");

  // Background plank with rounded corners
  color("Teal")
    linear_extrude(thickness - 1)
      translate([-bbox[0] / 2, -6])
        offset(radius)
          offset(-radius)
            square([bbox[0], bbox[1]]);
}

// Call module
bridge_name();
