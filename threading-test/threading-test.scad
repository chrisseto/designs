include <BOSL2/std.scad>
include <BOSL2/screws.scad>

/* $slop = 0.05; */
$fn = $preview ? 32 : 128;

start = 0.05;
end = 0.2;
step = 0.05;

base_spec = screw_info("M10x2,25",head="flat");

cases = [for (i = [start:step:end]) i];
nut_tolerances = ["6E", "6H"];

d = struct_val(base_spec, "diameter");
h = struct_val(base_spec, "length");

for(i = [0:(end-start)/step]) {
	slop = cases[i];

	right(struct_val(base_spec, "head_size") * 1.1 * i) {

		back(d) diff() screw(base_spec, $slop=slop) {
			tag("remove") position(TOP) down(1) linear_extrude(2) text(
				text=format_fixed(slop, 2),
				size=struct_val(base_spec, "head_size")/4,
				halign="center",
				valign="center"
			);
		}

		fwd(d) {
			diff() cuboid([d*1.35, d*4, h*0.5], anchor=BACK) {
				tag("remove") position(FRONT) back(1) xrot(90)
					linear_extrude(2) text(
						text=format_fixed(slop, 2),
						size=d*0.4,
						halign="center",
						valign="center"
					);

				position(BACK) down(0.01)
					for (j = [0, 1, 2]) {
						tolerance = nut_tolerances[j];

						fwd((d*.75) + (j * d * 1.25)) screw_hole(base_spec, tolerance="6H", thread=true, $slop=slop);
					}
			}
		}
	}
};
