// doaks-slides
// An OpenSCAD library to create slides.
// = sliding rails, saddles, and trays =

// © 2021 Daniel Oakley
// This work is licensed under the Creative Commons
// Attribution-ShareAlike 4.0 International License.
// To view a copy of this license, visit
// http://creativecommons.org/licenses/by-sa/4.0/.

// default tolerance in mm.
// I found this works well on my printer with a .3mm nozzle,
// hopefully it works on yours too!  ¯\_(ツ)_/¯
default_slides_tolerance = .33;

// helper function
module copy_mirror(vec=[0,0,0], offset=[0,0,0])
{
    children();
    translate(offset) mirror(vec) children();
}

// this creates a dovetail slide with a tray on top.
// add geometry underneath this to hold up the outer rails.
//
// the pieces look like this:
//
//     ┌─────────────────┐
//     │                 │  <- sliding tray
//     └──             ──┘      (inner)
//       /_____________\
//
//     ┌──             ──┐  <- static base
//     │_/             \_│      (outer)
//
// size is the overall 'bounding box' of the slide, including the tray's height.
// cols are how wide and high the 'rail sections' on either side are.
// cap is the width of the 'cap' at either end of the slide (0 for none).
// angle is the angle of the dovetail (0 is vertical).
// tolerance is the tolerance between rails/tray and caps/fills.
// inner is whether we're rendering the inner or the outer segment of the slide.
module reverse_dovetail_slide(size=[30,10,4], cols=[5,2], cap=0, angle=25, tolerance=default_slides_tolerance, inner=false)
{
    if (inner) {
        // space between the cols
        captolerance = cap == 0 ? 0 : tolerance;
        translate([cols[0],0,0]) cube([size[0]-cols[0]*2,size[1]-cap-captolerance,cols[1]]);
        translate([cols[0]+tolerance,size[1]-cap-captolerance,0]) cube([size[0]-cols[0]*2-tolerance*2,cap+captolerance,cols[1]]);
        
        // front cap
        if (cap != 0) copy_mirror([1,0,0], [size[0],0,0]) cube([cols[0],cap,cols[1]]);
        
        // top plate
        difference() {
            // main plate
            translate([0,0,cols[1]]) cube([size[0],size[1],size[2]-cols[1]]);

            // cut away back cap
            if (cap != 0) copy_mirror([1,0,0], [size[0],0,0]) translate([-1,size[1]-cap-tolerance,1]) cube([cols[0]+1,cap+1,size[2]+1]);
        }
    } else {
        // back cap
        if (cap != -1) copy_mirror([1,0,0], [size[0],0,0]) translate([0,size[1]-cap,0]) cube([cols[0]-tolerance,cap,size[2]]);
    }

    // main columns
    copy_mirror([1,0,0], [size[0],0,0]) difference() {
        // left col
        cube([cols[0],size[1],cols[1]]);

        // main angled cut away
        modifyx = inner ? -cols[0]/2 + tolerance : cols[0]/2;
        newh = cols[1]*5; // expanded height so we can diff this from the actual rail without running out of room, even @ extreme angles
        translate([0,size[1]+1,cols[1]/2]) rotate([0,angle,0]) translate([modifyx,0,-newh/2]) rotate([90,0,0]) linear_extrude(size[1]+2) resize([cols[0],newh]) polygon([[0,0],[0,1],[1,1],[1,0]]);

        if (cap != 0) {
            if (inner) {
                // cut away back cap
                copy_mirror([1,0,0], [size[0],0,0]) translate([-1,size[1]-cap-tolerance,-1]) cube([(cols[0]+1)+1,cap+1+tolerance,size[2]+1]);
            } else {
                // cut away front cap
                copy_mirror([1,0,0], [size[0],0,0]) translate([-1,-1,-1]) cube([cols[0]+1,cap+1+tolerance,size[2]+1]);
            }
        }
    }
}

// this creates a 3d printable test reverse dovetail slide,
// with indented text saying the tolerance in mm
module test_reverse_dovetail_slide(tolerance=default_slides_tolerance)
{
    // bottom (static) segment
    difference() {
        cube([30,20,5]);
        translate([15,10,3]) linear_extrude(3) text(str(tolerance), size=7, font="Liberation Sans Mono:style=Bold", halign="center", valign="center");
    }
    translate([0,0,5]) reverse_dovetail_slide([30,20,4], cap=2, tolerance=tolerance);

    // top (sliding) segment
    difference() {
        translate([30,25,4]) rotate([0,180,0]) reverse_dovetail_slide([30,20,4], cap=2, tolerance=tolerance, inner=true);
        translate([15,35,2]) linear_extrude(3) text(str(tolerance), size=7, font="Liberation Sans Mono:style=Bold", halign="center", valign="center");
    }
}

test_reverse_dovetail_slide();
