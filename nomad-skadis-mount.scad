// Sega Nomad -> IKEA SKÅDIS pegboard mount (single piece).
//
// SPDX-License-Identifier: CC-BY-NC-4.0
// Copyright (c) 2026 James Fryman
// Credits (see README.md): cradle style and hook profile after Schrockwell's
// Analogue Pocket SKÅDIS mount (CC BY); Nomad envelope measured from
// RetroGameRevival's Nomad replacement shell (CC BY-NC, no geometry included).
//
// Frames (see lode/mount/geometry.md):
//   Nomad frame: x = width (D-pad end is +x), y = depth (0 = flat back plane,
//                +y toward the screen), z = up (0 = underside of the Nomad).
//   Mount frame: Nomad frame rotated back by `recline` about the x axis.
//                The pegboard face is the vertical plane y = plate_back_y().

/* [Output] */
// Lay the part on its button end so the hooks print strong (layer lines across the hook profile).
print_orientation = false;
// Show a translucent Nomad envelope in preview (F5 only).
show_nomad = true;

/* [Nomad dimensions] */
nomad_w      = 191.4; // end to end
nomad_h_btn  = 100.0; // height at the button (ABC/XYZ) end
nomad_h_dpad = 107.0; // height at the D-pad end (top edge slopes up toward it)
body_d       = 45.5;  // flat back to screen face
body_r       = 4.0;   // vertical corner radius at the button end
grip_r       = 25.8;  // D-pad grip is ~a vertical cylinder
grip_cy      = 21.8;  // grip axis depth (grip bulges grip_r - grip_cy behind the flat back)
grip_taper_x = 50.0;  // where the body starts flaring into the grip

/* [Cradle] */
clr       = 0.75; // gap between Nomad and cradle on every side
wall      = 2.4;
floor_t   = 2.5;
tray_h    = 40;   // side wall height at the button end; follows the top-edge slope
lip_h     = 5;    // front lip height (Start/Mode buttons begin ~7.4mm up)
wrap_btn  = 10;   // how far the end walls wrap onto the front face
wrap_dpad = 14;
recline   = 3;    // degrees the Nomad leans back into the plate

/* [Port cutout] */
jack_cutout = true; // round port low on the D-pad end
jack_y      = 1.4;
jack_z      = 10.5;
jack_d      = 12;

/* [SKÅDIS hooks] */
hook_w          = 4.8;  // slot is 5mm wide
hook_stem       = 5;    // stem height (rests on bottom of the 15mm slot)
stem_len        = 5.6;  // board is 5mm thick
leg_t           = 5;
hook_drop       = 12.5; // stem top to leg bottom; must be < 15 to insert
hook_top_margin = 7;    // plate top to upper stem top
row_pitch       = 20;   // vertical offset between staggered rows
hooks_upper     = [-40, 0, 40];
hooks_lower     = [-20, 20];

$fn = 96;

big = 400;
x_btn  = -nomad_w / 2;
x_dpad =  nomad_w / 2;
grip_cx = x_dpad - grip_r;
grip_back = grip_r - grip_cy;
x_min = x_btn - clr - wall;
x_max = x_dpad + clr + wall;

function slope() = (nomad_h_dpad - nomad_h_btn) / nomad_w;
function tray_top(x) = tray_h + (x - x_btn) * slope();
function nomad_top(x) = nomad_h_btn + (x - x_btn) * slope();

// Back face of the plate: behind the grip pocket at its highest, reclined point.
function plate_back_y() =
  -(grip_back + clr) * cos(recline) - tray_top(x_max) * sin(recline) - wall;

// ---------- Nomad frame ----------

module footprint() {
  edge = [grip_taper_x, 0];
  hull() {
    translate([x_btn + body_r, body_r]) circle(body_r);
    translate([x_btn + body_r, body_d - body_r]) circle(body_r);
    translate(edge) square([0.01, body_d]);
  }
  hull() {
    translate(edge) square([0.01, body_d]);
    translate([grip_cx, grip_cy]) circle(grip_r);
  }
}

module cavity2d() { offset(r = clr) footprint(); }

module outer2d() {
  offset(r = clr + wall) footprint();
  // Square off the back half so the plate and end walls form flat faces.
  translate([x_min, -grip_back - clr - wall])
    square([x_max - x_min, grip_back + clr + wall + body_d / 2]);
}

// Half-space under a line z = z0 + (x - x0) * slope(), in the XZ plane.
module below_slope(z_at) {
  rotate([90, 0, 0]) linear_extrude(height = big, center = true)
    polygon([[-big, -big], [big, -big], [big, z_at(big)], [-big, z_at(-big)]]);
}

module cavity() { linear_extrude(height = big) cavity2d(); }

module front_opening() {
  x0 = x_min + wrap_btn;
  x1 = x_max - wrap_dpad;
  translate([x0, body_d * 2 / 3, lip_h]) cube([x1 - x0, big, big]);
}

module jack() {
  if (jack_cutout)
    translate([grip_cx, jack_y, jack_z]) rotate([0, 90, 0]) cylinder(d = jack_d, h = big);
}

module tray() {
  intersection() {
    difference() {
      translate([0, 0, -floor_t]) linear_extrude(height = big) outer2d();
      cavity();
      front_opening();
    }
    below_slope(function(x) tray_top(x));
  }
}

// ---------- Mount frame ----------

module reclined() { rotate([recline, 0, 0]) children(); }

module plate() {
  intersection() {
    translate([x_min, plate_back_y(), -big / 2]) cube([x_max - x_min, big, big]);
    reclined() intersection() {
      translate([x_min, -big, -floor_t]) cube([x_max - x_min, big, big]);
      below_slope(function(x) tray_top(x));
    }
  }
}

module hook2d() {
  offset(r = 0.6) offset(delta = -0.6) union() {
    translate([-stem_len, -hook_stem]) square([stem_len + 2, hook_stem]);
    translate([-stem_len - leg_t, -hook_drop]) square([leg_t, hook_drop]);
  }
}

// Stem top at z = 0, plate back face at y = 0, centred on x.
module hook() {
  rotate([90, 0, 90]) linear_extrude(height = hook_w, center = true) hook2d();
}

module hooks() {
  z_up = tray_top(hooks_upper[0]) * cos(recline) - hook_top_margin;
  for (x = hooks_upper) translate([x, plate_back_y(), z_up]) hook();
  for (x = hooks_lower) translate([x, plate_back_y(), z_up - row_pitch]) hook();
}

module mount() {
  difference() {
    union() {
      reclined() tray();
      plate();
    }
    reclined() { cavity(); front_opening(); jack(); }
  }
  hooks();
}

module nomad_ghost() {
  %reclined() intersection() {
    linear_extrude(height = big) footprint();
    below_slope(function(x) nomad_top(x));
  }
}

if (print_orientation) {
  translate([0, 0, -x_min]) rotate([0, -90, 0]) mount();
} else {
  mount();
  if (show_nomad) nomad_ghost();
}
