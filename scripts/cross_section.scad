/**
 * Module to show a cross section of the object.
 *
 * @param {boolean} showXSection - Show the cross section.
 * @param {number} size - Size of the cross section.
 * @param {string} color - Color of the cross section.
 */

module cross_section(showXSection = false, size = 100, color = "Red") {
  if (showXSection) {
    difference() {
      children();

      translate([-size / 2, -size, -size / 2]) color(color) cube([size, size, size]);
    }
  } else {
    children();
  }
}

use <rounded_box.scad>;

cross_section(true) rounded_box([30, 20, 10], radius=3);
