// OpenSCAD Dremel Bit Holder - by Roelax - https://makerworld.com/en/@FP3D
// The row width dynamically controls the padding around the shaft.
// Be careful with the number of bit holes you add. If you add too many, you'll need to make the row thinner.

/////////////////////////////////
// Bit Row Settings this is going to help control the actual bit rows, so this is the height, depth of bits, etc. I want to eventually make it so that you can control each and every section of the bit holder. From independent depth, to style, and format. 
/////////////////////////////////

$fn = $preview ? 32 : 64; // Smoothness of circles
z_fight = $preview ? 0.05 : 0; // Small offset to prevent z-fighting in preview mode

/* [Bit Row Settings] */

bit_rows = 7; // Number of bit rows to display [1:10]

/////////////////////////////////
// Other Dimensions
/////////////////////////////////

// Consistent width of each row
row_width = 100;

// Diameter of the drill bit holders Recommend 3.7
shaft_diameter = 3.7;

// Depth of the drill bit holders
shaft_depth = 11;

// Depth of the radius around the shaft
indentation_depth = 1;

/* [Shaft Row Options] */

/////////////////////////////////
// Bit Shaft Per Row controls the number of bit slots that you're going to have per row, the more bits you have, the wider you're going to have to make the rows or the thinner (depth) will need to be in order to fit the bits
/////////////////////////////////

//How many bits would you like to fit on rows?
shaft_row_1 = 9; // [1:20]
shaft_row_2 = 10; // [1:20]
shaft_row_3 = 7; // [1:20]
shaft_row_4 = 7; // [1:20]
shaft_row_5 = 10; // [1:20]
shaft_row_6 = 8; // [1:20]
shaft_row_7 = 8; // [1:20]
shaft_row_8 = 10; // [1:20]
shaft_row_9 = 6; // [1:20]
shaft_row_10 = 10; // [1:20]

// Combine the individual sliders into an array for shafts
shafts_per_row = [shaft_row_1, shaft_row_2, shaft_row_3, shaft_row_4, shaft_row_5, shaft_row_6, shaft_row_7, shaft_row_8, shaft_row_9, shaft_row_10];

/* [Individual Shaft Row Depth] */

/////////////////////////////////
// Bit Shaft Row Depth is what controls your individual row depth - how thin / skinny the rows are
/////////////////////////////////

//How deep yould you like this row to be? Padding is correlated to the depth
depth_row_1 = 10; // [10:30]
depth_row_2 = 10; // [10:30]
depth_row_3 = 15; // [10:30]
depth_row_4 = 15; // [10:30]
depth_row_5 = 10; // [10:30]
depth_row_6 = 15; // [10:30]
depth_row_7 = 10; // [10:30]
depth_row_8 = 20; // [10:30]
depth_row_9 = 15; // [10:30]
depth_row_10 = 20; // [10:30]

// Combine the individual sliders into an array for depths
depth_per_row = [depth_row_1, depth_row_2, depth_row_3, depth_row_4, depth_row_5, depth_row_6, depth_row_7, depth_row_8, depth_row_9, depth_row_10];

/* [Individual Shaft Row Height] */

/////////////////////////////////
// Bit Shaft Row Height is what controls your individual row height - how tall each row is
/////////////////////////////////

// How tall do you want the row to be? Minimum is 15mm
height_row_1 = 15; // [15:150]
height_row_2 = 15; // [15:150]
height_row_3 = 25; // [15:150]
height_row_4 = 35; // [15:150]
height_row_5 = 45; // [15:150]
height_row_6 = 55; // [15:150]
height_row_7 = 60; // [15:150]
height_row_8 = 70; // [15:150]
height_row_9 = 80; // [15:150]
height_row_10 = 90; // [15:150]

// Combine the individual sliders into an array for heights
height_per_row = [height_row_1, height_row_2, height_row_3, height_row_4, height_row_5, height_row_6, height_row_7, height_row_8, height_row_9, height_row_10];

// Function to calculate the radius based on the depth of the row and the number of shafts
function calc_radius(row_depth, shafts) = (row_depth - shaft_diameter) / 2;

// Function to calculate the spacing between shafts based on the settings
function calc_shaft_spacing(shafts, row_width, shaft_diameter, radius) = (row_width - shafts * (shaft_diameter + 2 * radius)) / (shafts + 1);

// Function to create the Dremel drill bit holder
module dremel_holder(bit_rows) {
  for (i = [0:bit_rows - 1]) {
    translate([0, sum(depth_per_row, i), 0])
      row_with_shafts(shafts_per_row[i], calc_radius(depth_per_row[i], shafts_per_row[i]), height_per_row[i], depth_per_row[i]);
  }
}

// Function to create a single row with drill bit holders and lips
module row_with_shafts(shafts, radius, height, row_depth) {
  shaft_spacing = calc_shaft_spacing(shafts, row_width, shaft_diameter, radius);

  difference() {
    // Row
    cube([row_width, row_depth, height]);
    // Drill bit holders and indentations
    for (j = [0:shafts - 1]) {
      // Calculate the position of each shaft
      shaft_position = (j + 1) * shaft_spacing + j * (shaft_diameter + 2 * radius) + (shaft_diameter + 2 * radius) / 2;

      // Box indentation
      translate([shaft_position - (shaft_diameter + radius) / 2, row_depth / 2 - (shaft_diameter + radius) / 2, height - indentation_depth])
        cube([shaft_diameter + radius, shaft_diameter + radius, indentation_depth + z_fight]);
      // Drill bit holder
      translate([shaft_position, row_depth / 2, height - shaft_depth])
        cylinder(shaft_depth, shaft_diameter / 2, shaft_diameter / 2, $fn=100);
      // Increase / Decrease $fn for smoother circles
    }
  }
}

// Function to calculate the height of each row
function getHeight(row) = row == 0 ? first_row_height : first_row_height + row * row_height;

// Generate the Dremel drill bit holder
dremel_holder(bit_rows);

// Helper function to sum elements of an array up to index n
function sum(arr, n) = n == 0 ? 0 : arr[n - 1] + sum(arr, n - 1);
