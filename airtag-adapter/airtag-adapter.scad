include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/screws.scad>

AIRTAG_HEIGHT = 8;
AIRTAG_DIAMETER = 31.9;

$fn = $preview ? 32 : 128;
$tolerance = 0.25;
$slop = 0.05;

fwd(35) airtag_case(base=0.75, hide="case", anchor=BOTTOM);

back(35) diff("remove") credit_card(thickness=0.75) {
	position(CENTER+BOTTOM) down(0.01) right(15) {
		tag("keep") airtag_case(base=0.75, hide="lid", anchor=BOTTOM);

		tag("remove") {
			airtag_case(base=0.75, anchor=BOTTOM);
			airtag(shell=$tolerance);
		};
	};
}

module airtag_case(hide="", base=1, anchor, spin, orient=UP) {
	attachable(anchor, spin, orient, d=38, h=7.5) {
		down(7.5/2) tag_diff($tag, "airtag") hide(hide) tag("airtag") airtag(shell=$tolerance, anchor=BOTTOM) {
				tag("case") position(BOTTOM) {
					up(0.01) cyl(h=base, d=mean(struct_val(thread_specification(screw_info("M36x1.5")), "d_minor")), anchor=BOTTOM) {
						position(TOP) screw("M36x1.5", l=4.5, anchor=BOTTOM, bevel=false) {
							position(BOTTOM) tag("lid") {
								tag_diff($tag) cyl(d=38, h=7.5-base, anchor=BOTTOM, teardrop=true, rounding=3) {
									position(CENTER) cyl(d=38, h=(7.5-base)/2, anchor=TOP);

									tag("remove") {
										position(BOTTOM) screw_hole("M36x1.5", l=4.5, anchor=BOTTOM, bevel=false, thread=true);
									}
								}
							};
						};
					};
				};
			}
		children();
	}
}

module credit_card(thickness=1, anchor, spin, orient=UP) {
	attachable(anchor, spin, orient, size=[3.375*INCH+0.25, 2.125*INCH+0.25, thickness]) {
		down(thickness/2) linear_extrude(thickness) rect([3.375*INCH+0.25, 2.125*INCH+0.25], rounding=4);
		children();
	}
}

module airtag(shell=0, anchor, spin, orient=UP) {
	// TODO: this is attachable as a cylinder right now which isn't quite right
	// as all faces are rounded to some degree.
	attachable(anchor, spin, orient, d=AIRTAG_DIAMETER+(shell*2), l=AIRTAG_HEIGHT+(shell*2)) {
		yrot(180)
			rotate_extrude(convexity=10)
				right_half(planar=true)
					left(AIRTAG_DIAMETER/2)
						offset(delta=shell) {
							import ("./airtag.svg", convexity=10, center=true);
						};
		children();
	}
}
