/**
 * rounded_box.scad
 *
 * Create a rounded box with rounded corners.
 *
 * @param size [x, y, z] - The size of the box.
 * @param radius - The radius of the corners.
 * @param center - Center the box at the origin.
 * @param fn - The number of facets to use for the cylinder.
 *
 * @return {object} - A rounded box with rounded corners.
 */
module rounded_box(size = [ 10, 10, 10 ], radius = 2, center = false, fn = 64)
{
    hull()
    {
        for (x = [ -1, 1 ], y = [ -1, 1 ])
        {
            translate([ x * (size[0] / 2 - radius), y * (size[1] / 2 - radius), 0 ])
                cylinder(h = size[2], r = radius, center = center, $fn = fn);
        }
    }
}

// Example Usage
rounded_box([ 30, 20, 10 ], radius = 3);