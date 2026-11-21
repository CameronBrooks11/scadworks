module internal_corner_fillet(dim_x, dim_y, fillet_fn = 64) {
    difference() {
        translate([dim_x / 2, dim_y / 2, 0])
            square([dim_x, dim_y], center=true);
        color("red")
            resize([dim_x * 2, dim_y * 2]) circle(d=1, $fn=fillet_fn);
    }
}

dim_x_ex = 30;
dim_y_ex = 20;

fillet_fn_ex = 64;

// Example Usage
linear_extrude(10)
    internal_corner_fillet(dim_x_ex, dim_y_ex, fillet_fn=fillet_fn_ex);
