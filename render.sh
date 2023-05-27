#!/usr/bin/env bash

set -ex

for DIR in */; do
	MODEL=${DIR%/}

	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
		--enable fast-csg \
		--enable fast-csg-safer \
		--enable lazy-union \
		-o $MODEL/preview.png \
		$MODEL/$MODEL.scad

	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
		--enable fast-csg \
		--enable fast-csg-safer \
		--enable lazy-union \
		-o $MODEL/$MODEL.stl \
		$MODEL/$MODEL.scad
done
