include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/structs.scad>

// Set facetting to an acceptably high level. Set it higher when actually
// rendering.
$fn = $preview ? 32 : 64;

tolerance = 0.5; // TODO??
wall_thickness = 2;

resevoir = [
	["height", 6*INCH],
	["radius", 6*INCH/2],
];

water_tube = [
	["height", struct_val(resevoir, "height")*.9],
	["radius", struct_val(resevoir, "radius")*.3],
	["offset", [wall_thickness, 0, struct_val(resevoir, "height")/4]],
];

insert = [
	["height", struct_val(resevoir, "height")*1.15],
	["radius", struct_val(resevoir, "radius")-wall_thickness-tolerance],
];

water_resevoir(resevoir, water_tube, anchor=BOTTOM);
up(wall_thickness) soil_insert(insert, water_tube, anchor=BOTTOM);

module water_resevoir(resevoir_spec, water_tube_spec, anchor, orient=UP, spin=0) {
	rounding = .5;
	height = struct_val(resevoir_spec, "height");
	radius = struct_val(resevoir_spec, "radius");
	inner_radius = radius-wall_thickness;

	water_tube_rounding = 1;
	water_tube_height = struct_val(water_tube_spec, "height");
	water_tube_radius = struct_val(water_tube_spec, "radius");
	water_tube_offset = struct_val(water_tube_spec, "offset");

	attachable(anchor, spin, orient, r=radius, h=height) {
		diff() rounded_tube(h=height, r=radius, rounding=rounding) {
			position(LEFT) translate(water_tube_offset) rounded_cylinder(h=water_tube_height, r=water_tube_radius, rounding=water_tube_rounding, teardrop=false) {
				tag("remove") {
					position(BOTTOM)
						up(wall_thickness) rounded_cylinder(h=water_tube_height, r=water_tube_radius-wall_thickness, rounding=water_tube_rounding, teardrop=false, orient=UP, anchor=BOTTOM);
				}
			}

			tag("remove") position(BOTTOM) up(wall_thickness) intersect() rounded_cylinder(r=inner_radius, h=height, rounding=rounding, anchor=BOTTOM) {
				tag("intersect") position(BOTTOM) rounded_cylinder(r=inner_radius, h=height/4, rounding=rounding, anchor=BOTTOM) {
					tag("intersect") position(TOP) onion(r=inner_radius, ang=55, anchor=CENTER);
				}
			};
		};
		children();
	}
}

module soil_insert(insert_spec, water_tube_spec, anchor, orient=UP, spin=0) {
	height = struct_val(insert_spec, "height");
	radius = struct_val(insert_spec, "radius");

	water_tube_height = struct_val(water_tube_spec, "height");
	water_tube_radius = struct_val(water_tube_spec, "radius") + (1.5*wall_thickness) + tolerance;
	water_tube_offset = [
		-struct_val(water_tube_spec, "offset")[0],
		-struct_val(water_tube_spec, "offset")[1],
		0, // Ignore z changes
	];

	attachable(anchor, spin, orient, r=radius, h=height) {
		diff("holes", "") diff("remove", "keep holes") funnel(r2=radius, r1=radius/3, h=height, anchor=CENTER) {
			tag("keep") tag_scope() diff() intersect() funnel(r2=radius, r1=radius/3, h=height, anchor=CENTER) {
				tag("intersect") position(LEFT+TOP) translate(water_tube_offset) cyl(r=water_tube_radius, h=height, anchor=TOP) {
					tag("remove") position(BOTTOM) up(wall_thickness) cyl(r=water_tube_radius-wall_thickness, h=height, anchor=BOTTOM);
				}
			};

			tag("remove") {
				position(LEFT+TOP) up(1) translate(water_tube_offset) cyl(r=water_tube_radius, h=height, anchor=TOP);

				position(BOTTOM) up(wall_thickness) funnel(r2=radius-wall_thickness, r1=(radius/3)-wall_thickness, h=height, anchor=BOTTOM);
			};

			tag("holes") position(BOTTOM) {
				layers=2;
				hole_size=height/40;

				up(height/12+wall_thickness)
					zcopies(l=height/8, n=layers)
						zrot($idx*180/8)
						zrot_copies(n=6, r=radius/2)
							zrot(90) teardrop(r=hole_size, l=radius, anchor=BOTTOM+CENTER);

				// Cone holes.
				up(height/4+height/30*2) zrot_copies(n=6, r=radius/2)
					zrot(90) xrot(36) teardrop(r=hole_size, l=radius/2, anchor=CENTER);
			};
		};
		children();
	};
}

module funnel(h, r1, r2, anchor, spin=0, orient=UP) {
	attachable(anchor, spin, orient, r1=r1, r2=r2, l=h) {
			cyl(r=r2, h=h/2, anchor=BOTTOM) {
				attach(BOTTOM, to=TOP, overlap=0.01) cyl(r1=r1, r2=r2, h=h/4) {
					attach(BOTTOM, to=TOP, overlap=0.01) cyl(r=r1, h/4);
				};
			};
		children();
	}
}

module rounded_cylinder(h, r, anchor, rounding=.25, teardrop=true, spin=0, orient=UP) {
    attachable(anchor, spin, orient, r=r, l=h) {
		tag_scope() {
			diff() {
				cyl(r=r, l=h, anchor=CENTER) {
					tag("keep") {
						position(TOP)
							rotate_extrude() down(wall_thickness) left(r-wall_thickness/2) circle(r=wall_thickness/2);
					}

					tag("remove") {
						if (teardrop) {
							position(BOT)
								rotate_extrude() left(r) mask2d_teardrop(r=rounding*r);
						} else {
							position(BOT) 
								rotate_extrude() left(r) mask2d_roundover(r=rounding*r);
						}
					}
				}
			}
		};
        children();
    }
}

module rounded_tube(h, r, rounding, anchor, spin=0, orient=UP) {
    attachable(anchor, spin, orient, r=r, l=h) {
		tag_scope() {
			diff() {
				rounded_cylinder(h=h, r=r, rounding=rounding, anchor=CENTER) {
					tag("remove") {
						position(BOTTOM)
							up(wall_thickness) rounded_cylinder(h=h, r=r-wall_thickness, rounding=rounding, orient=UP, anchor=BOTTOM);
					}
				}
			}
		};
		children();
	}
}
