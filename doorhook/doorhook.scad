include <BOSL2/std.scad>

$fn = $preview ? 32 : 128;

thickness = 2;
door_width = 34.5 + 0.25; // Actual width + some tolerance
diameter = 30;

body = [[0, 0], [0, diameter/2], [door_width, diameter/2]];
hook = arc(points=[[door_width, -diameter/2], [door_width+(diameter/2), -diameter], [door_width+diameter, -diameter/2]]);
support = [[door_width, -diameter/2], [door_width, -diameter], [door_width+(diameter/2), -diameter]];

linear_extrude(diameter/2) {
	stroke(offset(concat(body, hook), thickness/2), width=thickness);
	stroke(offset(support, thickness/2), width=thickness);
}
